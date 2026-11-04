import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../DataHolder.dart';
import '../admin/FirebaseAdmin.dart';

class Onboardingview extends StatefulWidget {
  const Onboardingview({super.key});

  @override
  State<Onboardingview> createState() => _Onboardingview();
}

class _Onboardingview extends State<Onboardingview> {
  final Firebaseadmin admin = Firebaseadmin();
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
      try {
        final perfil = await admin.descargarPerfil();
        if (!mounted) return;

        if (perfil == null ||
            perfil.nombre.trim().isEmpty ||
            perfil.nivel.trim().isEmpty) {
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
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  '学',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'KJ STUDY',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu camino hacia el japonés',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  value: _iProgress / 100,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Preparando tu espacio…',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
