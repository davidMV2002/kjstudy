import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'views/home_view.dart';
import 'views/kanji_list_view.dart';
import 'views/test_view.dart';
import 'views/vocabulario_list_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "KJ STUDY",
      routes: {
        AppRoutes.kanjis: (context) => const KanjiListView(),
        AppRoutes.vocabulario: (context) => const VocabularioListView(),
        AppRoutes.test: (context) => const TestView(),
        AppRoutes.home: (context) => const HomeView(),
      },
      home: const HomeView(),
    );
  }
}
