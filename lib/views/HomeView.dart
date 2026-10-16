import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../AppRoutes.dart';
import '../DataHolder.dart';
import '../insLib/BotBarStyle.dart';

class HomeView extends StatelessWidget {
  late BuildContext miContext;
  Dataholder dh = Dataholder.instance;

  HomeView({super.key});

  void cerrarSesion(){
    FirebaseAuth.instance.signOut();
    Navigator.popAndPushNamed(miContext, "/LoginView");
  }

  @override
  Widget build(BuildContext context) {
    miContext = context;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KJ STUDY', textAlign: TextAlign.center),
        backgroundColor: Colors.blue[200],
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.test),
            child: const Text('Test'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.lecciones),
            child: const Text('Lecciones'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.vocabulario),
            child: const Text('Vocabulario'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.vocabulario),  // Cambiar la ruta
            child: const Text('Listas Personalizadas'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.vocabulario),  // Cambiar la ruta
            child: const Text('Mis Kanjis'),
          ),
          TextButton(onPressed: cerrarSesion, child: Text("Cerrar Sesion")),
        ],
      ),
      bottomNavigationBar: Botbarstyle(
        iBarIndex: dh.iBarIndex,
      ),
    );
  }
}
