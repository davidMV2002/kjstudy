import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kjstudy/HomeView.dart';
import 'package:kjstudy/KanjiListView.dart';
import 'package:kjstudy/TestView.dart';
import 'package:kjstudy/VocabularioListView.dart';

class Myapp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "KJ STUDY",
      routes: {
        "/HomeView" : (context) => Homeview(),
        "/KanjiListView": (context) => Kanjilistview(),
        "/VocabularioListView": (context) => Vocabulariolistview(),
        "TestView": (context) => Testview(),
       },
      initialRoute: "Homeview()",
    );
  }
}