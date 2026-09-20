"""Carga en Firestore los 251 kanji de Basic Kanji Book vol. 1.

Uso local: no guarda ni incluye credenciales. Requiere pasar la ruta del JSON
de la cuenta de servicio como único argumento.
"""

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

DEPS = Path(__file__).resolve().parents[1] / "tmp" / "firestore-import-deps"
sys.path.insert(0, str(DEPS))

from google.cloud import firestore
from google.oauth2 import service_account


CHAPTERS = [
    "日月木山川田人口車門", "火水金土子女学生先私", "一二三四五六七八九十百千万円年",
    "上下中大小本半分力何", "明休体好男林森間畑岩", "目耳手足雨竹米貝石糸",
    "花茶肉文字物牛馬鳥魚", "新古長短高安低暗多少", "行来帰食飲見聞読書話買教",
    "朝昼夜晩夕方午前後毎週曜", "作泳油海酒待校時言計語飯", "宅客室家英薬会今雪雲電売",
    "広店度病疲痛屋国回困開閉", "近遠速遅道青晴静寺持荷歌", "友父母兄姉弟妹夫妻彼主奥",
    "元気有名親切便利不若早忙", "出入乗降着渡通走歩止動働", "右左東西北南外内部駅社院",
    "地鉄工場図館公園住所番号", "市町村区都府県島京様", "練習勉強研究留質問題答宿",
    "政治経済歴史育化理科数医",
]

# Significados deliberadamente cortos para las tarjetas de estudio.
MEANINGS = """
日=día
月=luna
木=árbol
山=montaña
川=río
田=arrozal
人=persona
口=boca
車=coche
門=puerta
火=fuego
水=agua
金=oro
土=tierra
子=niño
女=mujer
学=estudio
生=vida
先=antes
私=yo
一=uno
二=dos
三=tres
四=cuatro
五=cinco
六=seis
七=siete
八=ocho
九=nueve
十=diez
百=cien
千=mil
万=diez mil
円=yen
年=año
上=arriba
下=abajo
中=dentro
大=grande
小=pequeño
本=libro
半=mitad
分=parte
力=fuerza
何=qué
明=brillante
休=descanso
体=cuerpo
好=gusto
男=hombre
林=bosque
森=selva
間=intervalo
畑=huerto
岩=roca
目=ojo
耳=oreja
手=mano
足=pie
雨=lluvia
竹=bambú
米=arroz
貝=concha
石=piedra
糸=hilo
花=flor
茶=té
肉=carne
文=frase
字=letra
物=cosa
牛=vaca
馬=caballo
鳥=ave
魚=pez
新=nuevo
古=antiguo
長=largo
短=corto
高=alto
安=barato
低=bajo
暗=oscuro
多=mucho
少=poco
行=ir
来=venir
帰=volver
食=comer
飲=beber
見=ver
聞=escuchar
読=leer
書=escribir
話=hablar
買=comprar
教=enseñar
朝=mañana
昼=mediodía
夜=noche
晩=anochecer
夕=tarde
方=dirección
午=mediodía
前=antes
後=después
毎=cada
週=semana
曜=día semanal
作=hacer
泳=nadar
油=aceite
海=mar
酒=alcohol
待=esperar
校=escuela
時=hora
言=decir
計=calcular
語=idioma
飯=comida
宅=casa
客=huésped
室=sala
家=hogar
英=inglés
薬=medicina
会=reunión
今=ahora
雪=nieve
雲=nube
電=electricidad
売=vender
広=amplio
店=tienda
度=grado
病=enfermedad
疲=cansancio
痛=dolor
屋=techo
国=país
回=vez
困=problema
開=abrir
閉=cerrar
近=cerca
遠=lejos
速=rápido
遅=lento
道=camino
青=azul
晴=despejado
静=tranquilo
寺=templo
持=sostener
荷=equipaje
歌=canción
友=amigo
父=padre
母=madre
兄=hermano
姉=hermana
弟=hermano menor
妹=hermana menor
夫=marido
妻=esposa
彼=él
主=señor
奥=interior
元=origen
気=energía
有=existir
名=nombre
親=padre
切=cortar
便=comodidad
利=beneficio
不=no
若=joven
早=temprano
忙=ocupado
出=salir
入=entrar
乗=montar
降=descender
着=llegar
渡=cruzar
通=pasar
走=correr
歩=caminar
止=parar
動=mover
働=trabajar
右=derecha
左=izquierda
東=este
西=oeste
北=norte
南=sur
外=fuera
内=dentro
部=sección
駅=estación
社=sociedad
院=institución
地=suelo
鉄=hierro
工=industria
場=lugar
図=mapa
館=edificio
公=público
園=jardín
住=vivir
所=lugar
番=número
号=número
市=ciudad
町=pueblo
村=aldea
区=distrito
都=capital
府=prefectura
県=prefectura
島=isla
京=capital
様=forma
練=practicar
習=aprender
勉=esfuerzo
強=fuerte
研=investigar
究=investigar
留=permanecer
質=calidad
問=pregunta
題=tema
答=respuesta
宿=posada
政=política
治=gobernar
経=economía
済=terminar
歴=historia
史=historia
育=criar
化=cambio
理=lógica
科=ciencia
数=número
医=médico
"""


def parse_meanings():
    return dict(line.split("=", 1) for line in MEANINGS.strip().splitlines())


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Uso: python tools/import_kanjis.py RUTA_A_CREDENCIAL.json")

    credential_path = Path(sys.argv[1])
    if not credential_path.is_file():
        raise SystemExit("No se ha encontrado la credencial indicada.")

    kanji = "".join(CHAPTERS)
    meanings = parse_meanings()
    if len(kanji) != 251 or len(set(kanji)) != 251 or set(kanji) != set(meanings):
        raise RuntimeError("La lista de kanji y los significados no coinciden.")

    credentials = service_account.Credentials.from_service_account_file(str(credential_path))
    project_id = credentials.project_id
    if project_id != "kjstudy-a6d86":
        raise RuntimeError("La credencial no pertenece al proyecto kjstudy-a6d86.")

    db = firestore.Client(project=project_id, credentials=credentials)
    if os.environ.get("VERIFY_KANJIS") == "1":
        documents = list(db.collection("kanjis").stream())
        sample = db.collection("kanjis").document("日").get().to_dict()
        print(f"Verificados {len(documents)} documentos en kanjis: {', '.join(doc.id for doc in documents[:5])}")
        print(f"Muestra 日: {sample['significado']} | on={sample['lecturasOn']} | kun={sample['lecturasKun']} | {sample['nivelJLPT']}")
        return

    node = shutil.which("node") or r"C:\Users\david\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
    module_path = Path(__file__).resolve().parents[1] / "tmp" / "kanji-data" / "node_modules" / "kanji-data"
    node_program = "const db=require(process.argv[1]); console.log(JSON.stringify([...process.argv[2]].map(c=>db.get(c))));"
    result = subprocess.run(
        [node, "-e", node_program, str(module_path), kanji],
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    source_records = json.loads(result.stdout)
    if len(source_records) != 251 or any(record is None for record in source_records):
        raise RuntimeError("No se han encontrado los datos de todos los kanji.")
    if os.environ.get("PREVIEW_KANJIS") == "1":
        levels = {}
        for record in source_records:
            levels[record["jlpt"]] = levels.get(record["jlpt"], 0) + 1
        print(f"Datos listos para {len(source_records)} kanji. Niveles: {levels}")
        return

    records = []
    for order, (character, source) in enumerate(zip(kanji, source_records), start=1):
        records.append({
            "caracter": character,
            "significado": meanings[character],
            "lecturasOn": source["on_readings"],
            "lecturasKun": source["kun_readings"],
            # El JLPT no publica una tabla oficial carácter por carácter;
            # es la clasificación habitual del diccionario de origen.
            "nivelJLPT": f"N{source['jlpt']}" if source["jlpt"] else None,
            "nivelJLPTEsAproximado": True,
            "ordenLibro": order,
            "leccionLibro": next(i + 1 for i, lesson in enumerate(CHAPTERS) if character in lesson),
            "fuente": "Basic Kanji Book Vol. 1",
        })

    for start in range(0, len(records), 500):
        batch = db.batch()
        for record in records[start : start + 500]:
            batch.set(db.collection("kanjis").document(record["caracter"]), record)
        batch.commit()

    print(f"Importados {len(records)} documentos en kanjis del proyecto {project_id}.")


if __name__ == "__main__":
    main()
