import 'package:flutter/material.dart';

import '../../DataHolder.dart';
import '../../AppRoutes.dart';
import '../../insLib/BotBarStyle.dart';
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
  final Dataholder dh = Dataholder.instance;
  // Conserva la lección con la que se abrió esta pantalla.
  late final int _leccion = dh.leccion;
  late final Stream<List<Kanji>> _kanjis =
      _kanjiRepository.watchByLeccion(_leccion);

  @override
  Widget build(BuildContext context) {
    miContext = context;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lección $_leccion',
        ),
      ),
      body: StreamBuilder<List<Kanji>>(
        stream: _kanjis,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se han podido cargar los kanjis.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final kanjis = snapshot.data!;

          if (kanjis.isEmpty) {
            return const Center(
              child: Text('Todavía no hay kanjis en esta lista.'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('${kanjis.length} kanjis'),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kanjis.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    // Creo el objeto kanji
                    final kanji = kanjis[index];

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        // Navegar a los detalles del Kanji
                        onTap: () {
                          Dataholder.instance.kanji = kanji;
                          Navigator.pushNamed(miContext, AppRoutes.kanjiDetail);
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
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Botbarstyle(
        iBarIndex: dh.iBarIndex,
      ),
    );
  }
}
