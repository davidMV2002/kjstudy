import 'package:flutter/material.dart';

import '../../DataHolder.dart';
import '../../AppRoutes.dart';
import '../../insLib/BotBarStyle.dart';
import '../../objects/Kanji.dart';
import '../../admin/FirebaseAdmin.dart';

class KanjiListView extends StatefulWidget {
  const KanjiListView({super.key});

  @override
  State<KanjiListView> createState() => _KanjiListViewState();
}

class _KanjiListViewState extends State<KanjiListView> {
  final Firebaseadmin _admin = Firebaseadmin();
  late BuildContext miContext;
  final Dataholder dh = Dataholder.instance;
  // Conserva la lección con la que se abrió esta pantalla.
  late final int _leccion = dh.leccion;
  late final Future<List<Kanji>> _kanjis = _admin.verKanjisPorLeccion(_leccion);

  @override
  Widget build(BuildContext context) {
    miContext = context;

    return Scaffold(
      appBar: AppBar(title: Text('Lección $_leccion')),
      body: FutureBuilder<List<Kanji>>(
        future: _kanjis,
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${kanjis.length} kanjis',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
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
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        // Navegar a los detalles del Kanji
                        onTap: () {
                          dh.kanji = kanji;
                          Navigator.pushNamed(miContext, AppRoutes.kanjiDetail);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                kanji.caracter,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8C3030),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                kanji.significado,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
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
      bottomNavigationBar: Botbarstyle(iBarIndex: dh.iBarIndex),
    );
  }
}
