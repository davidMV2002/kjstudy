"""Unifica kanjiids en kanjiIds. Sin --apply solo inspecciona los cambios."""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tmp" / "firestore-import-deps"))

from google.cloud import firestore
from google.oauth2 import service_account


def merged_ids(data):
    result = []
    for field in ("kanjiIds", "kanjiids"):
        values = data.get(field, [])
        if not isinstance(values, list) or any(not isinstance(v, str) for v in values):
            raise ValueError(f"{field} debe ser una lista de cadenas")
        for value in values:
            if value not in result:
                result.append(value)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("credential_path")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    credentials = service_account.Credentials.from_service_account_file(args.credential_path)
    if credentials.project_id != "kjstudy-a6d86":
        raise RuntimeError("La credencial no pertenece a kjstudy-a6d86")
    db = firestore.Client(project=credentials.project_id, credentials=credentials)
    documents = list(db.collection("vocabulario").stream())
    changes = []
    # Valida todos los documentos antes de comenzar a escribir.
    for document in documents:
        data = document.to_dict()
        if "kanjiids" in data:
            try:
                ids = merged_ids(data)
            except ValueError as error:
                raise ValueError(f"Documento {document.id}: {error}") from error
            changes.append((document, ids))
    print(f"Inspeccionados: {len(documents)}. Con campo antiguo: {len(changes)}.")
    if not args.apply:
        print("Sin cambios. Usa --apply para ejecutar la migración.")
        return
    for document, ids in changes:
        # La precondición evita sobrescribir una edición concurrente.
        document.reference.update(
            {"kanjiIds": ids, "kanjiids": firestore.DELETE_FIELD,
             "fechamodificacion": firestore.SERVER_TIMESTAMP},
            option=db.write_option(last_update_time=document.update_time),
        )
    remaining = sum("kanjiids" in doc.to_dict() for doc in db.collection("vocabulario").stream())
    print(f"Actualizados: {len(changes)}. Documentos con kanjiids restantes: {remaining}.")
    if remaining:
        raise RuntimeError("Quedan documentos por normalizar")


if __name__ == "__main__":
    main()
