"""Importa en Firestore el vocabulario extraído de Basic Kanji Book Vol. 2.

El listado se crea antes con ``extract_basic_kanji_book_2_vocabulario.cjs``.
Solo crea o actualiza documentos de ``vocabulario``.

Uso:
  python tools/import_basic_kanji_book_2_vocabulario.py --dry-run
  python tools/import_basic_kanji_book_2_vocabulario.py RUTA_CREDENCIAL.json
"""

import hashlib
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


ROOT = Path(__file__).resolve().parents[1]
WORDS_PATH = ROOT / "tmp" / "bkb2-ocr" / "vocabulario-del-libro.json"
TRANSLATION_URL = "https://api.mymemory.translated.net/get"


def download_text(url: str) -> str:
    request = Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def chunks(values: list[str], max_characters: int = 200):
    current = []
    current_length = 0
    for value in values:
        added_length = len(value) + (1 if current else 0)
        if current and current_length + added_length > max_characters:
            yield current
            current = []
            current_length = 0
        current.append(value)
        current_length += added_length
    if current:
        yield current


def load_words() -> list[dict[str, str]]:
    words = json.loads(WORDS_PATH.read_text(encoding="utf-8"))
    if not words:
        raise RuntimeError("No hay vocabulario preparado para importar.")
    return words


def translate_to_spanish(words: list[dict[str, str]]) -> None:
    """Traduce por lotes y conserva una traducción por cada palabra."""
    translations = []
    for batch in chunks([word["meaning_en"] for word in words]):
        query = urlencode({"q": "\n".join(batch), "langpair": "en|es"}, encoding="utf-8")
        result = json.loads(download_text(f"{TRANSLATION_URL}?{query}"))
        translated = result["responseData"]["translatedText"].splitlines()
        if len(translated) != len(batch):
            raise RuntimeError("La traducción no conservó una línea por palabra.")
        translations.extend(value.strip() for value in translated)

    if len(translations) != len(words):
        raise RuntimeError("Falta alguna traducción.")
    for word, translation in zip(words, translations):
        word["significado"] = translation


def document_id(word: dict[str, str]) -> str:
    identity = f"{word['palabra']}\0{word['lectura']}".encode("utf-8")
    return f"bkb2_{hashlib.sha1(identity).hexdigest()[:20]}"


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

    created = 0
    updated = 0
    operations = []
    for word in words:
        key = (word["palabra"], word["lectura"])
        reference = existing.get(key)
        if reference is None:
            reference = db.collection("vocabulario").document(document_id(word))
            created += 1
        else:
            updated += 1

        operations.append(
            (
                reference,
                {
                    "palabra": word["palabra"],
                    "lectura": word["lectura"],
                    "significado": word["significado"],
                    "kanjiIds": [character for character in word["palabra"] if character in kanji_ids],
                    "fechamodificacion": firestore.SERVER_TIMESTAMP,
                },
            )
        )

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
            "Uso: python tools/import_basic_kanji_book_2_vocabulario.py "
            "RUTA_CREDENCIAL.json o --dry-run"
        )

    words = load_words()
    translate_to_spanish(words)
    if dry_run:
        for word in words[:15]:
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
