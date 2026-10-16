import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kjstudy/DataHolder.dart';

import '../AppRoutes.dart';
import '../insLib/BotBarStyle.dart';
import '../services/KanjiRepository.dart';

class Vocabulariodetailview extends StatelessWidget{
  late BuildContext miContext;
  Dataholder dh = Dataholder.instance;

  Future<void> funClickKanji(String kanjiId) async {
    final kanji = await KanjiRepository().getById(kanjiId);

    if (kanji == null) {
      return;
    }

    dh.kanji = kanji;
    Navigator.pushNamed(miContext, AppRoutes.kanjiDetail);
  }

  @override
  Widget build(BuildContext context) {
    miContext = context;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text("VOCABULARIO"),
      ),
      body: Column(
        children: [
          Text(dh.vocabulario.palabra),
          Text(dh.vocabulario.lectura),
          Text(dh.vocabulario.significado),
          Wrap(
            children: [
              for (final kanjiId in dh.vocabulario.kanjiIds)
                TextButton(
                  onPressed: () => funClickKanji(kanjiId),
                  child: Text(kanjiId),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Botbarstyle(
        iBarIndex: dh.iBarIndex,
      ),
    );
  }
}
