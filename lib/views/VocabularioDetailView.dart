import 'package:flutter/material.dart';
import 'package:kjstudy/DataHolder.dart';

import '../AppRoutes.dart';
import '../insLib/BotBarStyle.dart';
import '../admin/FirebaseAdmin.dart';
import 'StudyDetailComponents.dart';

class Vocabulariodetailview extends StatelessWidget {
  late BuildContext miContext;
  Dataholder dh = Dataholder.instance;

  Future<void> funClickKanji(String kanjiId) async {
    try {
      final kanji = await Firebaseadmin().descargarKanjiParaVocabulario(
        kanjiId,
      );
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
        const SnackBar(
          content: Text('No se ha podido cargar la tarjeta del kanji.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    miContext = context;

    return Scaffold(
      appBar: AppBar(title: const Text("Vocabulario")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          StudyHero(
            label: 'Vocabulario',
            title: dh.vocabulario.palabra,
            subtitle: dh.vocabulario.lectura,
          ),
          const SizedBox(height: 16),
          StudySection(
            title: 'Significado',
            child: Text(
              dh.vocabulario.significado,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (dh.vocabulario.kanjiIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            StudySection(
              title: 'Kanjis relacionados',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kanjiId in dh.vocabulario.kanjiIds)
                    OutlinedButton(
                      onPressed: () => funClickKanji(kanjiId),
                      child: Text(kanjiId),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Botbarstyle(iBarIndex: dh.iBarIndex),
    );
  }
}
