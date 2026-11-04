import 'package:flutter/material.dart';
import 'package:kjstudy/views/BusquedaView.dart';
import 'package:kjstudy/views/CrearKanjiView.dart';
import 'package:kjstudy/views/CrearVocabularioView.dart';
import 'package:kjstudy/views/KanjiDetailView.dart';
import 'package:kjstudy/views/OnBoardingView.dart';
import 'package:kjstudy/views/PerfilView.dart';
import 'package:kjstudy/views/VocabularioDetailView.dart';
import 'package:kjstudy/views/credenciales/CrearPerfilView.dart';
import 'package:kjstudy/views/credenciales/LoginView.dart';
import 'package:kjstudy/views/credenciales/RegisterView.dart';
import 'package:kjstudy/views/listas/MisKanjisListView.dart';
import 'package:kjstudy/views/listas/MiVocabularioListView.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9E3B3B),
          surface: const Color(0xFFFFFBF8),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBF8),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Color(0xFF272120),
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF272120),
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF272120),
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(color: Color(0xFF332B2A)),
          bodyMedium: TextStyle(color: Color(0xFF332B2A)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFBF8),
          foregroundColor: Color(0xFF272120),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF272120),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFF0E4E0)),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9E3B3B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8C3030),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8C3030),
            side: const BorderSide(color: Color(0xFFBAA6A3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBAA6A3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF9E3B3B), width: 2),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFFFFFBF8),
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF9E3B3B),
          foregroundColor: Colors.white,
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Color(0xFF765955),
          textColor: Color(0xFF332B2A),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE6DAD7),
          thickness: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF41302E),
          contentTextStyle: const TextStyle(color: Colors.white),
          actionTextColor: const Color(0xFFFFDAD4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
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
        AppRoutes.busqueda: (context) => Busquedaview(),
        AppRoutes.misKanjis: (context) => Miskanjislistview(),
        AppRoutes.crearKanji: (context) => Crearkanjiview(),
        AppRoutes.perfilView: (context) => Perfilview(),
        AppRoutes.crearVocabulario: (context) => Crearvocabularioview(),
        AppRoutes.miVocabulario: (context) => const MiVocabularioListView(),
      },
      home: const Onboardingview(),
    );
  }
}
