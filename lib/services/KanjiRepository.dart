import 'package:cloud_firestore/cloud_firestore.dart';

import '../objects/Kanji.dart';

/// Encargado de leer y guardar kanjis en Firestore.
class KanjiRepository {
  KanjiRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Kanji> get _kanjis =>
      _firestore.collection('kanjis').withConverter<Kanji>(
            fromFirestore: Kanji.fromFirestore,
            toFirestore: (kanji, _) => kanji.toFirestore(),
          );

  /// Escucha los kanjis con la última modificación primero.
  Stream<List<Kanji>> watchAll() {
    return _kanjis
        .orderBy('fechamodificacion', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((document) => document.data()).toList(),
        );
  }

  /// Obtiene un kanji concreto a partir del ID guardado en una palabra.
  Future<Kanji?> getById(String id) async {
    final document = await _kanjis.doc(id).get();
    return document.data();
  }

  /// Crea o actualiza un kanji. Si no tiene ID, usa el propio carácter como ID.
  Future<void> save(Kanji kanji) {
    final documentId = kanji.id ?? kanji.caracter;
    final data = kanji.toFirestore();
    data['fechamodificacion'] = FieldValue.serverTimestamp();

    return _firestore.collection('kanjis').doc(documentId).set(data);
  }
}
