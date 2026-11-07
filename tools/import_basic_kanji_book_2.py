"""Importa los kanjis de Basic Kanji Book Vol. 2 en Firestore.

Solo escribe en la colección ``kanjis``. Las lecciones del libro se guardan
como 23 a 45, inmediatamente después de las 22 del primer volumen.

Uso:
  python tools/import_basic_kanji_book_2.py RUTA_CREDENCIAL.json
  python tools/import_basic_kanji_book_2.py --dry-run
"""

import json
import shutil
import subprocess
import sys
from pathlib import Path

DEPS = Path(__file__).resolve().parents[1] / "tmp" / "firestore-import-deps"
sys.path.insert(0, str(DEPS))

from google.cloud import firestore
from google.oauth2 import service_account

sys.stdout.reconfigure(encoding="utf-8")


LESSONS = {
    23: "映画写真音楽料組思色白黒赤",
    24: "起寝遊立座使始終貸借返送",
    25: "結婚離席欠予定洋式和活",
    26: "春夏秋冬暑熱寒冷暖温涼天",
    27: "仕事者運転選記議員商業農",
    28: "良悪点正違同適当難次形味",
    29: "試験面接説果合格受落残念",
    30: "指折払投打深洗流消決",
    31: "旅約案準備相談連絡泊特急",
    32: "線発到交機関局信路故注意",
    33: "押引割担自由取求願知",
    34: "台窓具器用服紙辞雑誌",
    35: "銀資品個価産期々報告",
    36: "心感情悲泣笑頭覚忘考",
    37: "伝代呼焼曲脱別集並喜驚",
    38: "細太重軽狭弱眠苦簡単",
    39: "空港飛階建設完成費放",
    40: "位置横向原平野風両橋",
    41: "老族配術退効民訪顔歯",
    42: "卒論実調必要類得失礼",
    43: "増加減変移続過進以美",
    44: "比較反対賛共直表現初",
    45: "全最無非第的性法制課",
}
SPECIAL_RECORDS = {
    "々": {
        "lecturasKun": [],
        "lecturasOn": [],
        "nivelJLPT": "",
        "meaning_en": "repetition mark",
        "significado": "repetición",
    }
}
SPANISH_MEANINGS = {
    "映": "reflejar", "画": "dibujo", "写": "copiar", "真": "verdadero", "音": "sonido",
    "楽": "diversión", "料": "tarifa", "組": "grupo", "思": "pensar", "色": "color",
    "白": "blanco", "黒": "negro", "赤": "rojo",
    "起": "levantarse", "寝": "dormir", "遊": "jugar", "立": "ponerse de pie", "座": "sentarse",
    "使": "usar", "始": "comenzar", "終": "terminar", "貸": "prestar", "借": "pedir prestado",
    "返": "devolver", "送": "enviar",
    "結": "unir", "婚": "matrimonio", "離": "separar", "席": "asiento", "欠": "faltar",
    "予": "previo", "定": "decidir", "洋": "occidental", "式": "estilo", "和": "armonía", "活": "vivir",
    "春": "primavera", "夏": "verano", "秋": "otoño", "冬": "invierno", "暑": "caluroso",
    "熱": "calor", "寒": "frío", "冷": "frío", "暖": "cálido", "温": "temperatura", "涼": "fresco", "天": "cielo",
    "仕": "servir", "事": "asunto", "者": "persona", "運": "llevar", "転": "girar", "選": "elegir",
    "記": "anotar", "議": "deliberar", "員": "miembro", "商": "comercio", "業": "negocio", "農": "agricultura",
    "良": "bueno", "悪": "malo", "点": "punto", "正": "correcto", "違": "diferir", "同": "mismo",
    "適": "adecuado", "当": "acertar", "難": "difícil", "次": "siguiente", "形": "forma", "味": "sabor",
    "試": "probar", "験": "prueba", "面": "cara", "接": "tocar", "説": "explicar", "果": "resultado",
    "合": "encajar", "格": "estatus", "受": "recibir", "落": "caer", "残": "permanecer", "念": "deseo",
    "指": "dedo", "折": "doblar", "払": "pagar", "投": "lanzar", "打": "golpear", "深": "profundo",
    "洗": "lavar", "流": "fluir", "消": "apagar", "決": "decidir",
    "旅": "viaje", "約": "promesa", "案": "plan", "準": "estándar", "備": "preparar", "相": "mutuo",
    "談": "hablar", "連": "conectar", "絡": "enredar", "泊": "alojarse", "特": "especial", "急": "urgente",
    "線": "línea", "発": "salir", "到": "llegar", "交": "mezclar", "機": "máquina", "関": "relación",
    "局": "oficina", "信": "creer", "路": "camino", "故": "motivo", "注": "verter", "意": "idea",
    "押": "empujar", "引": "tirar", "割": "dividir", "担": "cargo", "自": "uno mismo", "由": "motivo",
    "取": "tomar", "求": "buscar", "願": "deseo", "知": "saber",
    "台": "pedestal", "窓": "ventana", "具": "herramienta", "器": "utensilio", "用": "uso", "服": "ropa",
    "紙": "papel", "辞": "renunciar", "雑": "variado", "誌": "revista",
    "銀": "plata", "資": "recursos", "品": "producto", "個": "unidad", "価": "valor", "産": "producir",
    "期": "periodo", "々": "repetición", "報": "informar", "告": "anunciar",
    "心": "corazón", "感": "sentir", "情": "emoción", "悲": "triste", "泣": "llorar", "笑": "reír",
    "頭": "cabeza", "覚": "recordar", "忘": "olvidar", "考": "pensar",
    "伝": "transmitir", "代": "sustituir", "呼": "llamar", "焼": "quemar", "曲": "curva", "脱": "quitar",
    "別": "separar", "集": "reunir", "並": "alinear", "喜": "alegría", "驚": "sorprender",
    "細": "delgado", "太": "grueso", "重": "pesado", "軽": "ligero", "狭": "estrecho", "弱": "débil",
    "眠": "dormir", "苦": "sufrir", "簡": "simple", "単": "solo",
    "空": "cielo", "港": "puerto", "飛": "volar", "階": "piso", "建": "construir", "設": "instalar",
    "完": "completo", "成": "lograr", "費": "coste", "放": "liberar",
    "位": "rango", "置": "colocar", "横": "lateral", "向": "dirección", "原": "origen", "平": "plano",
    "野": "campo", "風": "viento", "両": "ambos", "橋": "puente",
    "老": "viejo", "族": "familia", "配": "distribuir", "術": "técnica", "退": "retirarse", "効": "efecto",
    "民": "pueblo", "訪": "visitar", "顔": "cara", "歯": "diente",
    "卒": "graduarse", "論": "teoría", "実": "verdad", "調": "investigar", "必": "necesario", "要": "necesario",
    "類": "tipo", "得": "obtener", "失": "perder", "礼": "cortesía",
    "増": "aumentar", "加": "añadir", "減": "disminuir", "変": "cambiar", "移": "mover", "続": "continuar",
    "過": "pasar", "進": "avanzar", "以": "desde", "美": "belleza",
    "比": "comparar", "較": "contrastar", "反": "contrario", "対": "opuesto", "賛": "aprobar", "共": "juntos",
    "直": "directo", "表": "expresar", "現": "aparecer", "初": "inicio",
    "全": "todo", "最": "máximo", "無": "nada", "非": "no", "第": "número", "的": "objetivo",
    "性": "naturaleza", "法": "ley", "制": "sistema", "課": "sección",
}


def load_kanji_data() -> list[dict]:
    characters = "".join(LESSONS.values())
    if len(characters) != 249 or len(set(characters)) != 249:
        raise RuntimeError("La lista de kanjis del segundo libro no contiene 249 entradas únicas.")

    module_path = (
        Path(__file__).resolve().parents[1]
        / "tmp"
        / "kanji-data"
        / "node_modules"
        / "kanji-data"
    )
    node = shutil.which("node") or (
        r"C:\Users\david\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
    )
    node_program = "const db=require(process.argv[1]); console.log(JSON.stringify([...process.argv[2]].map(c=>db.get(c))));"
    result = subprocess.run(
        [node, "-e", node_program, str(module_path), characters],
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    source_records = json.loads(result.stdout)

    lesson_for_character = {
        character: lesson
        for lesson, lesson_characters in LESSONS.items()
        for character in lesson_characters
    }
    records = []
    for character, source in zip(characters, source_records):
        if character in SPECIAL_RECORDS:
            record = {"caracter": character, **SPECIAL_RECORDS[character]}
        else:
            if source is None:
                raise RuntimeError(f"No hay datos disponibles para {character}.")
            record = {
                "caracter": character,
                "lecturasKun": source["kun_readings"],
                "lecturasOn": source["on_readings"],
                "nivelJLPT": f"N{source['jlpt']}" if source["jlpt"] else "",
                "meaning_en": source["heisig_en"] or source["meanings"][0],
            }
        record["leccion"] = lesson_for_character[character]
        records.append(record)

    missing_meanings = set(characters) - set(SPANISH_MEANINGS)
    if missing_meanings:
        raise RuntimeError(f"Faltan significados: {''.join(sorted(missing_meanings))}")
    for record in records:
        record["significado"] = SPANISH_MEANINGS[record["caracter"]]
    return records


def import_records(credential_path: Path, records: list[dict]) -> tuple[int, int]:
    credentials = service_account.Credentials.from_service_account_file(str(credential_path))
    if credentials.project_id != "kjstudy-a6d86":
        raise RuntimeError("La credencial no pertenece al proyecto kjstudy-a6d86.")

    db = firestore.Client(project=credentials.project_id, credentials=credentials)
    existing_ids = {document.id for document in db.collection("kanjis").stream()}
    created = 0
    updated = 0
    for start in range(0, len(records), 500):
        batch = db.batch()
        for record in records[start : start + 500]:
            if record["caracter"] in existing_ids:
                updated += 1
            else:
                created += 1
            batch.set(
                db.collection("kanjis").document(record["caracter"]),
                {
                    "caracter": record["caracter"],
                    "lecturasKun": record["lecturasKun"],
                    "lecturasOn": record["lecturasOn"],
                    "nivelJLPT": record["nivelJLPT"],
                    "significado": record["significado"],
                    "leccion": record["leccion"],
                    "fechamodificacion": firestore.SERVER_TIMESTAMP,
                },
                merge=True,
            )
        batch.commit()
    return created, updated


def main():
    dry_run = len(sys.argv) == 2 and sys.argv[1] == "--dry-run"
    if not dry_run and len(sys.argv) != 2:
        raise SystemExit(
            "Uso: python tools/import_basic_kanji_book_2.py "
            "RUTA_CREDENCIAL.json o --dry-run"
        )

    records = load_kanji_data()
    if dry_run:
        for record in records[:10]:
            print(
                f"L{record['leccion']} {record['caracter']} | "
                f"kun={record['lecturasKun']} | on={record['lecturasOn']} | "
                f"{record['nivelJLPT']} | {record['significado']}"
            )
        print(f"Preparados {len(records)} kanjis: lecciones 23 a 45.")
        return

    created, updated = import_records(Path(sys.argv[1]), records)
    print(f"Importados {created} kanjis nuevos y actualizados {updated} existentes.")


if __name__ == "__main__":
    main()
