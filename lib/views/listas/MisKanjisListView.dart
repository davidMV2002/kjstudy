import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kjstudy/DataHolder.dart';
import 'package:kjstudy/AppRoutes.dart';

import '../../admin/FirebaseAdmin.dart';
import '../../insLib/BotBarStyle.dart';
import '../../objects/Kanji.dart';

class Miskanjislistview extends StatefulWidget {
  @override
  State<Miskanjislistview> createState() => _MiskanjisviewState();
}

class _MiskanjisviewState extends State<Miskanjislistview> {
  late BuildContext miContext;
  Dataholder dh = Dataholder.instance;

  late Future<List<Kanji>> _kanji = Firebaseadmin().verKanjisPropios();

  @override
  Widget build(BuildContext context) {
    miContext = context;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Kanjis')),
      body: FutureBuilder<List<Kanji>>(
        future: _kanji,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se han podido cargar los kanjis.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final kanji = snapshot.data!;

          if (kanji.isEmpty) {
            return const Center(child: Text('Todavía no hay kanjis propios.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kanji.length,
            itemBuilder: (context, index) {
              final palabra = kanji[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  title: Text(
                    palabra.caracter,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8C3030),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(palabra.significado),
                        const SizedBox(height: 4),
                        Text(
                          palabra.lecturasKun.join(', '),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          palabra.lecturasOn.join(', '),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  // Aquí añadiremos la navegación a los detalles más adelante.
                  onTap: () {
                    Navigator.pushNamed(miContext, "/KanjiDetailView");
                    Dataholder.instance.kanji = palabra;
                    print("PULSADO");
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final creado = await Navigator.pushNamed(
            context,
            AppRoutes.crearKanji,
          );
          if (creado == true && mounted) {
            setState(() => _kanji = Firebaseadmin().verKanjisPropios());
          }
        },
        tooltip: 'Crear kanji',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Botbarstyle(iBarIndex: dh.iBarIndex),
    );
  }
}
