import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kjstudy/DataHolder.dart';

import '../insLib/BotBarStyle.dart';

class Kanjidetailview extends StatelessWidget{
  Dataholder dh = Dataholder.instance;

  @override
  Widget build(BuildContext context) {
    // Los kanjis comunitarios pueden no pertenecer a una lección.
    final leccion = dh.kanji.leccion;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text("KANJI"),
      ),
      body: Column(
        children: [
          Text(dh.kanji.caracter),
          Text("Significado: " + dh.kanji.significado),
          Text("Lecturas kunyomi: " + dh.kanji.lecturasKun.toString()),
          Text("Lecturas onyomi: " + dh.kanji.lecturasOn.toString()),
          Text(dh.kanji.nivelJLPT),
          if (leccion != null) Text("Lección: $leccion"),
        ],
      ),
      bottomNavigationBar: Botbarstyle(
        iBarIndex: dh.iBarIndex,
      ),
    );
  }
}
