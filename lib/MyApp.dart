import 'package:flutter/material.dart';
import 'package:kjstudy/views/KanjiDetailView.dart';
import 'package:kjstudy/views/OnBoardingView.dart';
import 'package:kjstudy/views/VocabularioDetailView.dart';
import 'package:kjstudy/views/credenciales/CrearPerfilView.dart';
import 'package:kjstudy/views/credenciales/LoginView.dart';
import 'package:kjstudy/views/credenciales/RegisterView.dart';

import 'AppRoutes.dart';
import 'views/HomeView.dart';
import 'views/listas/KanjiListView.dart';
import 'views/listas/LeccionesView.dart';
import 'views/TestView.dart';
import 'views/listas/VocabularioListView.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "KJ STUDY",
      routes: {
        AppRoutes.lecciones: (context) => const Leccionesview(),
        AppRoutes.kanjis: (context) => const KanjiListView(),
        AppRoutes.vocabulario: (context) => const VocabularioListView(),
        AppRoutes.test: (context) => TestView(),
        AppRoutes.home: (context) => HomeView(),
        AppRoutes.kanjiDetail: (context) => Kanjidetailview(),
        AppRoutes.vocabularioDetail: (context) => Vocabulariodetailview(),
        AppRoutes.login: (context) => Loginview(),
        AppRoutes.register: (context) => Registerview(),
        AppRoutes.onboarding: (context) => Onboardingview(),
        AppRoutes.crearperfil: (context) => Crearperfilview(),
      },
      home: const Onboardingview(),
    );
  }
}
