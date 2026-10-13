import 'package:flutter/material.dart';
import 'package:kjstudy/views/KanjiDetailView.dart';
import 'package:kjstudy/views/VocabularioDetailView.dart';

import 'AppRoutes.dart';
import 'views/HomeView.dart';
import 'views/KanjiListView.dart';
import 'views/TestView.dart';
import 'views/VocabularioListView.dart';

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
        AppRoutes.kanjiDetail: (context) => Kanjidetailview(),
        AppRoutes.vocabularioDetail: (context) => Vocabulariodetailview(),
      },
      home: const HomeView(),
    );
  }
}
