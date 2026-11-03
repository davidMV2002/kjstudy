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
  CollectionReference<Kanji> get kanjisComunitarios => _kanjis('kanjiscomunitarios');
  CollectionReference<Kanji> get misKanjis => _kanjis('perfil/${fa.currentUser!.uid}/kanjispropios');
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



  Future<Perfil?> descargarPerfil() async =>
      (await perfiles.doc(fa.currentUser!.uid).get()).data();



  Future<Kanji?> descargarKanji(String id) async =>
      (await kanjis.doc(id).get()).data();

  Future<List<Kanji>> verKanjis() async => (await kanjis
      .orderBy('fechamodificacion', descending: true)
      .get())
      .docs.map((doc) => doc.data()).toList();

  Future<List<Kanji>> verKanjisPorLeccion(int leccion) async =>
      (await kanjis.where('leccion', isEqualTo: leccion).get())
          .docs.map((doc) => doc.data()).toList();

  Future<List<Kanji>> verKanjisParaBusqueda() async =>
      (await kanjis.get()).docs.map((doc) => doc.data()).toList();

  Future<List<Kanji>> verKanjisComunitarios() async =>
      (await kanjisComunitarios.get()).docs.map((doc) => doc.data()).toList();

  Future<List<Kanji>> verKanjisPropios() async =>
      (await misKanjis.get()).docs.map((doc) => doc.data()).toList();

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
          .docs.map((doc) => doc.data()).toList();

  Future<List<Vocabulario>> verVocabulario() async => (await vocabulario
      .orderBy('fechamodificacion', descending: true)
      .get())
      .docs.map((doc) => doc.data()).toList();

  Future<List<Vocabulario>> verVocabularioParaBusqueda() async =>
      (await vocabulario.get()).docs.map((doc) => doc.data()).toList();
}
