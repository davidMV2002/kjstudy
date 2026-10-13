import 'package:cloud_firestore/cloud_firestore.dart';

import '../objects/Vocabulario.dart';

/// Encargado de leer y guardar vocabulario en Firestore.
class VocabularioRepository {
  VocabularioRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Vocabulario> get _vocabulario =>
      _firestore.collection('vocabulario').withConverter<Vocabulario>(
            fromFirestore: Vocabulario.fromFirestore,
            toFirestore: (vocabulario, _) => vocabulario.toFirestore(),
          );

  /// Escucha las palabras con la última modificación primero.
  Stream<List<Vocabulario>> watchAll() {
    return _vocabulario
        .orderBy('fechamodificacion', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((document) => document.data()).toList(),
        );
  }

  /// Crea o actualiza una palabra y guarda la hora del servidor.
  Future<void> save(Vocabulario vocabulario) {
    final documentId = vocabulario.id ?? _vocabulario.doc().id;
    final data = vocabulario.toFirestore();
    data['fechamodificacion'] = FieldValue.serverTimestamp();

    return _firestore.collection('vocabulario').doc(documentId).set(data);
  }
}
