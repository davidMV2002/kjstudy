"""Añade leccion según las agrupaciones originales de Basic Kanji Book vol. 1."""

import argparse

from import_kanjis import CHAPTERS, firestore, service_account


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("credential_path")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    lessons = {c: n for n, chapter in enumerate(CHAPTERS, 1) for c in chapter}
    if len(lessons) != 251 or sum(map(len, CHAPTERS)) != 251:
        raise RuntimeError("La correspondencia debe contener 251 kanjis únicos")
    credentials = service_account.Credentials.from_service_account_file(args.credential_path)
    if credentials.project_id != "kjstudy-a6d86":
        raise RuntimeError("Proyecto incorrecto")
    db = firestore.Client(project=credentials.project_id, credentials=credentials)
    documents = list(db.collection("kanjis").stream())
    changes = []
    for doc in documents:
        data = doc.to_dict()
        character = data.get("caracter", doc.id)
        if character not in lessons:
            raise RuntimeError(f"Sin lección conocida: {doc.id}")
        if data.get("leccion") != lessons[character]:
            changes.append((doc, lessons[character]))
    print(f"Kanjis: {len(documents)}; lecciones: {len(CHAPTERS)}; cambios: {len(changes)}.")
    if not args.apply:
        return
    for doc, lesson in changes:
        doc.reference.update(
            {"leccion": lesson, "fechamodificacion": firestore.SERVER_TIMESTAMP},
            option=db.write_option(last_update_time=doc.update_time),
        )
    verified = list(db.collection("kanjis").stream())
    for doc in verified:
        data = doc.to_dict()
        if data.get("leccion") != lessons[data.get("caracter", doc.id)]:
            raise RuntimeError(f"Verificación fallida: {doc.id}")
    print(f"Verificados {len(verified)} kanjis con su leccion correcta.")


if __name__ == "__main__":
    main()
