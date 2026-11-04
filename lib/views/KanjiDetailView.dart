import 'package:flutter/material.dart';
import 'package:kjstudy/DataHolder.dart';

import '../insLib/BotBarStyle.dart';
import 'StudyDetailComponents.dart';

class Kanjidetailview extends StatelessWidget {
  Dataholder dh = Dataholder.instance;

  @override
  Widget build(BuildContext context) {
    // Los kanjis comunitarios pueden no pertenecer a una lección.
    final leccion = dh.kanji.leccion;

    return Scaffold(
      appBar: AppBar(title: const Text("Kanji")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          StudyHero(
            label: 'Kanji',
            title: dh.kanji.caracter,
            subtitle: dh.kanji.significado,
          ),
          const SizedBox(height: 16),
          StudySection(
            title: 'Lectura kunyomi',
            child: Text(
              dh.kanji.lecturasKun.join(', '),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          StudySection(
            title: 'Lectura onyomi',
            child: Text(
              dh.kanji.lecturasOn.join(', '),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          StudySection(
            title: 'Información',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(dh.kanji.nivelJLPT)),
                if (leccion != null) Chip(label: Text('Lección $leccion')),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Botbarstyle(iBarIndex: dh.iBarIndex),
    );
  }
}
