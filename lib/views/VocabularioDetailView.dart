import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kjstudy/DataHolder.dart';

import '../AppRoutes.dart';
import '../insLib/BotBarStyle.dart';
import '../admin/FirebaseAdmin.dart';

class Vocabulariodetailview extends StatelessWidget{
  late BuildContext miContext;
  Dataholder dh = Dataholder.instance;

  Future<void> funClickKanji(String kanjiId) async {
    try {
      final kanji = await Firebaseadmin().descargarKanjiParaVocabulario(kanjiId);
      if (!miContext.mounted) return;
      if (kanji == null) {
        ScaffoldMessenger.of(miContext).showSnackBar(
          const SnackBar(content: Text('Este kanji todavía no tiene tarjeta.')),
        );
        return;
      }
      dh.kanji = kanji;
      Navigator.pushNamed(miContext, AppRoutes.kanjiDetail);
    } catch (_) {
      if (!miContext.mounted) return;
      ScaffoldMessenger.of(miContext).showSnackBar(
        const SnackBar(content: Text('No se ha podido cargar la tarjeta del kanji.')),
      );
    }
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
