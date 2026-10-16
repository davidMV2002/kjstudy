import 'package:flutter/material.dart';

import '../AppRoutes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.pushNamed(context, AppRoutes.kanjis),  // Cambiar la ruta
            child: const Text('Listas'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.vocabulario),  // Cambiar la ruta
            child: const Text('Personalizadas'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.vocabulario),  // Cambiar la ruta
            child: const Text('Mis Kanjis'),
          ),
        ],
      ),
    );
  }
}
