import 'package:flutter/material.dart';

import '../../DataHolder.dart';
import '../../objects/Kanji.dart';
import '../../services/KanjiRepository.dart';

class KanjiListView extends StatefulWidget {
  const KanjiListView({super.key});

  @override
  State<KanjiListView> createState() => _KanjiListViewState();
}

class _KanjiListViewState extends State<KanjiListView> {
  final KanjiRepository _kanjiRepository = KanjiRepository();
  late BuildContext miContext;

  @override
  Widget build(BuildContext context) {
    miContext = context;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Kanjis')),
      body: StreamBuilder<List<Kanji>>(
        stream: _kanjiRepository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('No se han podido cargar los kanjis.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final kanjis = snapshot.data!;

          if (kanjis.isEmpty) {
            return const Center(child: Text('Todavía no hay kanjis.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kanjis.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              // Creo el objeto kanji para
              final kanji = kanjis[index];

              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  // Navegar a los detalles del Kanji
                  onTap: () {
                    Navigator.pushNamed(miContext, "/KanjiDetailView",);
                    Dataholder.instance.kanji = kanji;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          kanji.caracter,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kanji.significado,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
