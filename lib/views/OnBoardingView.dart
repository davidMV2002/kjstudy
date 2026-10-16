import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../DataHolder.dart';
import '../objects/Perfil.dart';

class Onboardingview extends StatefulWidget {
  const Onboardingview({super.key});

  @override
  State<Onboardingview> createState() => _Onboardingview();
}

class _Onboardingview extends State<Onboardingview> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  var fa = FirebaseAuth.instance;
  Dataholder dh = Dataholder.instance;

  int _iProgress = 0;

  @override
  void initState() {
    super.initState();

    cargarRecursos();
  }

  void cargarRecursos() async {
    await recursos1();
    if (!mounted) return;
    setState(() {
      _iProgress = 20;
    });

    await recursos2();
    if (!mounted) return;
    setState(() {
      _iProgress = 100;
    });

    if (fa.currentUser == null) {
      Navigator.popAndPushNamed(context, "/LoginView");
    } else {
      String uid = fa.currentUser!.uid;

      final docRef = db
          .collection("perfil")
          .doc(uid)
          .withConverter(
            fromFirestore: Perfil.fromFirestore,
            toFirestore: (Perfil perfil, _) => perfil.toFirestore(),
          );

      try {
        final docSnap = await docRef.get();
        if (!mounted) return;
        final perfil = docSnap.data();

        if (perfil == null || perfil.nombre.trim().isEmpty || perfil.nivel.trim().isEmpty) {
          Navigator.popAndPushNamed(context, "/CrearPerfilView");
        } else {
          dh.perfilUsuario = perfil;
          Navigator.popAndPushNamed(context, "/HomeView");
        }
      } on FirebaseException catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No se pudo cargar el perfil. Comprueba el acceso a Firestore.',
            ),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: cargarRecursos,
            ),
          ),
        );
      }
    }
  }

  Future<void> recursos1() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> recursos2() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              //  Implementar logo de la app
              Padding(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: CircularProgressIndicator(value: _iProgress / 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
