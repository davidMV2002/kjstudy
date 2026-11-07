"""Importa el vocabulario de Basic Kanji Book Vol. 1 a Firestore.

Obtiene las 764 palabras de la colección digital correspondiente al libro,
traduce sus significados al español y solo escribe en la colección
``vocabulario``. No crea ni modifica documentos de ``kanjis``.

Uso:
  python tools/import_basic_kanji_book_vocabulario.py RUTA_CREDENCIAL.json
  python tools/import_basic_kanji_book_vocabulario.py --dry-run
"""

import hashlib
import html
import json
import re
import sys
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

DEPS = Path(__file__).resolve().parents[1] / "tmp" / "firestore-import-deps"
sys.path.insert(0, str(DEPS))

from google.cloud import firestore
from google.oauth2 import service_account

sys.stdout.reconfigure(encoding="utf-8")


BASE_URL = "https://kanjidraw.com/collections/basic-kanji-book-1"
TRANSLATION_URL = "https://api.mymemory.translated.net/get"
EXPECTED_WORDS = 764
# El traductor interpreta 木 aislado como la abreviatura japonesa de jueves,
# mientras que en el libro esta entrada significa "tree".
MANUAL_TRANSLATIONS = {"木": "árbol"}

CARD_PATTERN = re.compile(
    r'<a class="collection-verb-card collection-verb-card--inset" '
    r'href="/dictionary/[^"]+/">.*?'
    r'<span class="collection-verb-word">(.*?)</span>.*?'
    r'<span class="collection-verb-reading">(.*?)</span>.*?'
    r'<span class="collection-verb-meaning">(.*?)</span>',
    re.DOTALL,
)


def download_text(url: str) -> str:
    request = Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def clean(value: str) -> str:
    return html.unescape(re.sub(r"<.*?>", "", value)).strip()


def load_words() -> list[dict[str, str]]:
    words = []
    for page in range(1, 8):
        url = f"{BASE_URL}/" if page == 1 else f"{BASE_URL}/page/{page}/"
        content = download_text(url)
        for word, reading, meaning_en in CARD_PATTERN.findall(content):
            words.append(
                {
                    "palabra": clean(word),
                    "lectura": clean(reading),
                    "meaning_en": clean(meaning_en),
                }
            )

    if len(words) != EXPECTED_WORDS:
        raise RuntimeError(
            f"Se esperaban {EXPECTED_WORDS} palabras, pero se extrajeron {len(words)}."
        )
    return words


def chunks(values: list[str], max_characters: int = 200):
    current = []
    current_length = 0
    for value in values:
        additional = len(value) + (1 if current else 0)
        if current and current_length + additional > max_characters:
            yield current
            current = []
            current_length = 0
        current.append(value)
        current_length += additional
    if current:
        yield current


def translate_to_spanish(words: list[dict[str, str]]) -> None:
    """Traduce las palabras japonesas en lotes, conservando una línea por término."""
    translations = []
    for batch in chunks([word["palabra"] for word in words]):
        query = urlencode(
            {"q": "\n".join(batch), "langpair": "ja|es"}, encoding="utf-8"
        )
        result = json.loads(download_text(f"{TRANSLATION_URL}?{query}"))
        translated = result["responseData"]["translatedText"].splitlines()
        if len(translated) != len(batch):
            raise RuntimeError("La traducción por lotes no conservó todas las líneas.")
        translations.extend(item.strip() for item in translated)

    if len(translations) != len(words):
        raise RuntimeError("Falta alguna traducción.")

    for word, translation in zip(words, translations):
        word["significado"] = MANUAL_TRANSLATIONS.get(word["palabra"], translation)


def document_id(word: dict[str, str]) -> str:
    identity = f"{word['palabra']}\0{word['lectura']}".encode("utf-8")
    return f"bkb1_{hashlib.sha1(identity).hexdigest()[:20]}"


def import_words(credential_path: Path, words: list[dict[str, str]]) -> tuple[int, int]:
    credentials = service_account.Credentials.from_service_account_file(str(credential_path))
    if credentials.project_id != "kjstudy-a6d86":
        raise RuntimeError("La credencial no pertenece al proyecto kjstudy-a6d86.")

    db = firestore.Client(project=credentials.project_id, credentials=credentials)
    kanji_ids = {document.id for document in db.collection("kanjis").stream()}
    existing = {
        (document.to_dict().get("palabra", ""), document.to_dict().get("lectura", "")): document.reference
        for document in db.collection("vocabulario").stream()
    }

    operations = []
    updated = 0
    created = 0
    for word in words:
        key = (word["palabra"], word["lectura"])
        reference = existing.get(key)
        if reference is None:
            reference = db.collection("vocabulario").document(document_id(word))
            created += 1
        else:
            updated += 1

        data = {
            "palabra": word["palabra"],
            "lectura": word["lectura"],
            "significado": word["significado"],
            "kanjiIds": [character for character in word["palabra"] if character in kanji_ids],
            "fechamodificacion": firestore.SERVER_TIMESTAMP,
        }
        operations.append((reference, data))

    for start in range(0, len(operations), 500):
        batch = db.batch()
        for reference, data in operations[start : start + 500]:
            batch.set(reference, data, merge=True)
        batch.commit()

    return created, updated


def main():
    dry_run = len(sys.argv) == 2 and sys.argv[1] == "--dry-run"
    if not dry_run and len(sys.argv) != 2:
        raise SystemExit(
            "Uso: python tools/import_basic_kanji_book_vocabulario.py "
            "RUTA_CREDENCIAL.json o --dry-run"
        )

    words = load_words()
    translate_to_spanish(words)
    if dry_run:
        for word in words[:10]:
            print(
                f"{word['palabra']} | {word['lectura']} | "
                f"{word['significado']} ({word['meaning_en']})"
            )
        print(f"Preparadas {len(words)} palabras.")
        return

    created, updated = import_words(Path(sys.argv[1]), words)
    print(f"Importadas {created} nuevas palabras y actualizadas {updated} existentes.")


if __name__ == "__main__":
    main()
