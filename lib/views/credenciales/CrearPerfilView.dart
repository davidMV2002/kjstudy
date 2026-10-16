import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../DataHolder.dart';
import '../../AppRoutes.dart';
import '../../objects/Perfil.dart';

class Crearperfilview extends StatelessWidget {
  late BuildContext miContext;
  TextEditingController nivelController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;

  void funConfirmar() async {
    final nombre = nombreController.text.trim();
    final nivel = nivelController.text.trim();
    if (nombre.isEmpty || nivel.isEmpty) {
      ScaffoldMessenger.of(miContext).showSnackBar(
        const SnackBar(
          content: Text('Introduce tu nombre y tu nivel de japonés.'),
        ),
      );
      return;
    }


    final perfiles = db.collection("perfil");
    final perfil = new Perfil(
      uid: FirebaseAuth.instance.currentUser!.uid,
      nombre: nombre,
      nivel: nivel,
    );


    try {
      await perfiles.doc(perfil.uid).set(perfil.toFirestore());
      Dataholder.instance.perfilUsuario = perfil;
      if (!miContext.mounted) return;
      Navigator.popAndPushNamed(miContext, AppRoutes.onboarding);
    } catch (_) {
      if (!miContext.mounted) return;
      ScaffoldMessenger.of(miContext).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el perfil. Inténtalo de nuevo.'),
        ),
      );
    }
  }

  void funSalir() {
    Navigator.popAndPushNamed(miContext, "/LoginView");
  }

  @override
  Widget build(BuildContext context) {
    miContext = context;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(hintText: "Nombre"),
            ),
            TextField(
              controller: nivelController,
              decoration: InputDecoration(hintText: "Nivel del japonés"),
            ),
            Row(
              mainAxisAlignment: .center,
              children: [
                TextButton(onPressed: funConfirmar, child: Text("Confirmar")),
                TextButton(onPressed: funSalir, child: Text("Salir")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
