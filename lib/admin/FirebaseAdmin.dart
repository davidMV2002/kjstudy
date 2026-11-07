import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../objects/Perfil.dart';
import '../objects/Vocabulario.dart';
import '../objects/Kanji.dart';

class Firebaseadmin {
  Firebaseadmin({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : db = firestore ?? FirebaseFirestore.instance,
      fa = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore db;
  final FirebaseAuth fa;

  CollectionReference<Perfil> get perfiles => db
      .collection('perfil')
      .withConverter<Perfil>(
        fromFirestore: Perfil.fromFirestore,
        toFirestore: (perfil, _) => perfil.toFirestore(),
      );

  CollectionReference<Kanji> get kanjis => _kanjis('kanjis');
  CollectionReference<Kanji> get kanjisComunitarios =>
      _kanjis('kanjiscomunitarios');
  CollectionReference<Kanji> get misKanjis =>
      _kanjis('perfil/${fa.currentUser!.uid}/kanjispropios');
  CollectionReference<Kanji> _kanjis(String coleccion) => db
      .collection(coleccion)
      .withConverter<Kanji>(
        fromFirestore: Kanji.fromFirestore,
        toFirestore: (kanji, _) => kanji.toFirestore(),
      );

  CollectionReference<Vocabulario> get vocabulario => db
      .collection('vocabulario')
      .withConverter<Vocabulario>(
        fromFirestore: Vocabulario.fromFirestore,
        toFirestore: (palabra, _) => palabra.toFirestore(),
      );

  CollectionReference<Vocabulario> get miVocabulario => db
      .collection('perfil/${fa.currentUser!.uid}/vocabulariopropio')
      .withConverter<Vocabulario>(
        fromFirestore: Vocabulario.fromFirestore,
        toFirestore: (palabra, _) => palabra.toFirestore(),
      );

  CollectionReference<Vocabulario> get vocabulariosComunitarios => db
      .collection('vocabularioscomunitarios')
      .withConverter<Vocabulario>(
        fromFirestore: Vocabulario.fromFirestore,
        toFirestore: (palabra, _) => palabra.toFirestore(),
      );

  Future<Perfil?> descargarPerfil() async =>
      (await perfiles.doc(fa.currentUser!.uid).get()).data();

  Future<Perfil?> descargarPerfilPorUid(String uid) async =>
      (await perfiles.doc(uid).get()).data();

  Future<Kanji?> descargarKanji(String id) async =>
      (await kanjis.doc(id).get()).data();

  // Los IDs del vocabulario también pueden referirse a tarjetas personales
  // o comunitarias que se hayan creado después de guardar la palabra.
  Future<Kanji?> descargarKanjiParaVocabulario(String id) async {
    final general = await descargarKanji(id);
    if (general != null) return general;
    if (fa.currentUser == null) return null;
    final propio = (await misKanjis.doc(id).get()).data();
    if (propio != null) return propio;
    final porId = (await kanjisComunitarios.doc(id).get()).data();
    if (porId != null) return porId;
    final porCaracter = await kanjisComunitarios
        .where('caracter', isEqualTo: id)
        .limit(1)
        .get();
    return porCaracter.docs.isEmpty ? null : porCaracter.docs.first.data();
  }

  Future<List<Kanji>> verKanjisParaVocabulario() async {
    final listas = await Future.wait([
      verKanjisParaBusqueda(),
      verKanjisPropios(),
      verKanjisComunitarios(),
    ]);
    final porId = <String, Kanji>{};
    for (final lista in listas) {
      for (final kanji in lista) {
        if (kanji.caracter.isNotEmpty)
          porId.putIfAbsent(kanji.caracter, () => kanji);
      }
    }
    return porId.values.toList();
  }

  Future<List<Kanji>> verKanjis() async =>
      (await kanjis.orderBy('fechamodificacion', descending: true).get()).docs
          .map((doc) => doc.data())
          .toList();

  Future<List<Kanji>> verKanjisPorLeccion(int leccion) async =>
      (await kanjis.where('leccion', isEqualTo: leccion).get()).docs
          .map((doc) => doc.data())
          .toList();

  Future<List<Kanji>> verKanjisParaBusqueda() async =>
      (await kanjis.get()).docs.map((doc) => doc.data()).toList();

  Future<List<Kanji>> verKanjisComunitarios() async =>
      (await kanjisComunitarios.get()).docs.map((doc) => doc.data()).toList();

  Future<List<Kanji>> verKanjisPropios() async =>
      (await misKanjis.get()).docs.map((doc) => doc.data()).toList();

  Future<void> compartirKanji(String id, bool compartir) => _cambiarCompartido(
    'kanjispropios',
    'kanjiscomunitarios',
    id,
    compartir,
    buscarAnterior: true,
  );

  Future<void> compartirVocabulario(String id, bool compartir) =>
      _cambiarCompartido(
        'vocabulariopropio',
        'vocabularioscomunitarios',
        id,
        compartir,
      );

  Future<void> _cambiarCompartido(
    String personal,
    String comunidad,
    String id,
    bool compartir, {
    bool buscarAnterior = false,
  }) async {
    final uid = fa.currentUser?.uid;
    if (uid == null) throw StateError('Es necesario iniciar sesión.');
    final origen = db
        .collection('perfil')
        .doc(uid)
        .collection(personal)
        .doc(id);
    final destino = db.collection(comunidad).doc('${uid}_$id');
    final anterior = buscarAnterior ? db.collection(comunidad).doc(id) : null;
    await db.runTransaction((transaction) async {
      final original = await transaction.get(origen);
      final publicado = await transaction.get(destino);
      final legado = anterior == null ? null : await transaction.get(anterior);
      final datos = original.data();
      if (datos == null) throw StateError('El elemento ya no existe.');
      if (publicado.exists && publicado.data()?['creador'] != uid) {
        throw StateError('La publicación pertenece a otro usuario.');
      }
      transaction.update(origen, {'compartido': compartir});
      if (compartir) {
        transaction.set(destino, {
          ...datos,
          'compartido': true,
          'creador': uid,
          'fechamodificacion': FieldValue.serverTimestamp(),
        });
      } else if (publicado.exists) {
        transaction.delete(destino);
      }
      if (legado != null && legado.exists && legado.data()?['creador'] == uid) {
        transaction.delete(anterior!);
      }
    });
  }

  Future<void> crearKanjiPropio(Kanji kanji) async {
    final referencia = misKanjis.doc(kanji.caracter);
    await db.runTransaction((transaction) async {
      if ((await transaction.get(referencia)).exists) {
        throw StateError('Este kanji ya existe.');
      }
      transaction.set(referencia, kanji);
    });
  }

  Future<Vocabulario?> descargarVocabulario(String id) async =>
      (await vocabulario.doc(id).get()).data();

  Future<void> crearVocabulario(Vocabulario palabra) async {
    await miVocabulario.add(palabra);
  }

  Future<List<Vocabulario>> verMiVocabulario() async =>
      (await miVocabulario.orderBy('fechamodificacion', descending: true).get())
          .docs
          .map((doc) => doc.data())
          .toList();

  Future<List<Vocabulario>> verVocabulario() async =>
      (await vocabulario.orderBy('fechamodificacion', descending: true).get())
          .docs
          .map((doc) => doc.data())
          .toList();

  Future<List<Vocabulario>> verVocabularioParaBusqueda() async =>
      (await vocabulario.get()).docs.map((doc) => doc.data()).toList();

  Future<List<Vocabulario>> verVocabulariosComunitarios() async =>
      (await vocabulariosComunitarios.get()).docs
          .map((doc) => doc.data())
          .toList();
}
