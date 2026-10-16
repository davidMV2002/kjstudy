"""Añade fechamodificacion a los documentos existentes de vocabulario.

Uso local: no guarda credenciales; recibe la ruta de la cuenta de servicio.
"""

import sys
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

DEPS = Path(__file__).resolve().parents[1] / "tmp" / "firestore-import-deps"
sys.path.insert(0, str(DEPS))

from google.cloud import firestore
from google.oauth2 import service_account


# Misma fecha inicial que los kanji: 12/10/2026, 00:00, hora de Madrid.
MODIFICATION_DATE = datetime(2026, 10, 12, 0, 0, 0, tzinfo=ZoneInfo("Europe/Madrid"))


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Uso: python tools/add_vocabulario_modification_date.py RUTA_A_CREDENCIAL.json")

    credential_path = Path(sys.argv[1])
    credentials = service_account.Credentials.from_service_account_file(str(credential_path))
    if credentials.project_id != "kjstudy-a6d86":
        raise RuntimeError("La credencial no pertenece al proyecto kjstudy-a6d86.")

    db = firestore.Client(project=credentials.project_id, credentials=credentials)
    documents = list(db.collection("vocabulario").stream())

    for start in range(0, len(documents), 500):
        batch = db.batch()
        for document in documents[start : start + 500]:
            batch.update(document.reference, {"fechamodificacion": MODIFICATION_DATE})
        batch.commit()

    print(f"Actualizados {len(documents)} documentos de vocabulario.")


if __name__ == "__main__":
    main()
