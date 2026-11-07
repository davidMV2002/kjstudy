import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _cambiando = false;

  Future<void> _compartir(Kanji kanji) async {
    if (kanji.id == null || _cambiando) return;
    setState(() => _cambiando = true);
    try {
      final admin = Firebaseadmin();
      await admin.compartirKanji(kanji.id!, !kanji.compartido);
      if (!mounted) return;
      setState(() { _kanji = admin.verKanjisPropios(); });
      await _kanji;
    } on FirebaseException catch (error, stack) {
      debugPrint('Error al compartir kanji: $error\n$stack');
      if (!mounted) return;
      final mensaje = error.code == 'permission-denied'
          ? 'Firestore ha denegado el acceso. Revisa las reglas publicadas.'
          : error.code == 'unavailable'
              ? 'No hay conexión con Firestore. Comprueba tu conexión.'
              : 'No se ha podido actualizar el kanji (${error.code}).';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (error, stack) {
      debugPrint('Error al compartir kanji: $error\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido cambiar el estado del kanji. Inténtalo de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _cambiando = false);
    }
  }

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
                        Text(palabra.compartido ? 'Compartido' : 'Privado'),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: palabra.compartido
                        ? 'Dejar de compartir'
                        : 'Compartir',
                    onPressed: _cambiando ? null : () => _compartir(palabra),
                    icon: Icon(
                      palabra.compartido ? Icons.public_off : Icons.share,
                    ),
                  ),
                  onTap: () {
                    Dataholder.instance.kanji = palabra;
                    Navigator.pushNamed(miContext, AppRoutes.kanjiDetail);
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
            setState(() { _kanji = Firebaseadmin().verKanjisPropios(); });
          }
        },
        tooltip: 'Crear kanji',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Botbarstyle(iBarIndex: dh.iBarIndex),
    );
  }
}
