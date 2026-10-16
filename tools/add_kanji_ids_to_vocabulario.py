"""Completa kanjiIds a partir de los caracteres de cada palabra japonesa.

Uso local: no guarda credenciales; recibe la ruta de la cuenta de servicio.
"""

import sys
from pathlib import Path

DEPS = Path(__file__).resolve().parents[1] / "tmp" / "firestore-import-deps"
sys.path.insert(0, str(DEPS))

from google.cloud import firestore
from google.oauth2 import service_account


def main():
    if len(sys.argv) != 2:
        raise SystemExit(
            "Uso: python tools/add_kanji_ids_to_vocabulario.py RUTA_A_CREDENCIAL.json"
        )

    credential_path = Path(sys.argv[1])
    credentials = service_account.Credentials.from_service_account_file(
        str(credential_path)
    )
    if credentials.project_id != "kjstudy-a6d86":
        raise RuntimeError("La credencial no pertenece al proyecto kjstudy-a6d86.")

    db = firestore.Client(project=credentials.project_id, credentials=credentials)
    kanji_ids = {document.id for document in db.collection("kanjis").stream()}
    updated = 0

    for document in db.collection("vocabulario").stream():
        palabra = document.to_dict().get("palabra", "")
        ids = [character for character in palabra if character in kanji_ids]

        if ids:
            document.reference.update(
                {
                    "kanjiIds": ids,
                    "fechamodificacion": firestore.SERVER_TIMESTAMP,
                }
            )
            updated += 1

    print(f"Actualizadas {updated} palabras con kanjiIds.")


if __name__ == "__main__":
    main()
