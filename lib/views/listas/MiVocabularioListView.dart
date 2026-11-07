import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../AppRoutes.dart';
import '../../DataHolder.dart';
import '../../admin/FirebaseAdmin.dart';
import '../../insLib/BotBarStyle.dart';
import '../../objects/Vocabulario.dart';

class MiVocabularioListView extends StatefulWidget {
  const MiVocabularioListView({super.key});

  @override
  State<MiVocabularioListView> createState() => _MiVocabularioListViewState();
}

class _MiVocabularioListViewState extends State<MiVocabularioListView> {
  final _admin = Firebaseadmin();
  late Future<List<Vocabulario>> _vocabulario = _admin.verMiVocabulario();
  bool _cambiando = false;

  Future<void> _compartir(Vocabulario palabra) async {
    if (palabra.id == null || _cambiando) return;
    setState(() => _cambiando = true);
    try {
      await _admin.compartirVocabulario(palabra.id!, !palabra.compartido);
      if (!mounted) return;
      setState(() { _vocabulario = _admin.verMiVocabulario(); });
      await _vocabulario;
    } on FirebaseException catch (error, stack) {
      debugPrint('Error al compartir vocabulario: $error\n$stack');
      if (!mounted) return;
      final mensaje = error.code == 'permission-denied'
          ? 'Firestore ha denegado el acceso. Revisa las reglas publicadas.'
          : error.code == 'unavailable'
              ? 'No hay conexión con Firestore. Comprueba tu conexión.'
              : 'No se ha podido actualizar la palabra (${error.code}).';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (error, stack) {
      debugPrint('Error al compartir vocabulario: $error\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido cambiar el estado de la palabra. Inténtalo de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _cambiando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi vocabulario')),
      body: FutureBuilder<List<Vocabulario>>(
        future: _vocabulario,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se ha podido cargar tu vocabulario.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final palabras = snapshot.data!;
          if (palabras.isEmpty) {
            return const Center(
              child: Text('Todavía no tienes vocabulario propio.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: palabras.length,
            itemBuilder: (context, index) {
              final palabra = palabras[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  title: Text(
                    palabra.palabra,
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
                        Text(
                          palabra.lectura,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(palabra.significado),
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
                    Dataholder.instance.vocabulario = palabra;
                    Navigator.pushNamed(context, AppRoutes.vocabularioDetail);
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
            AppRoutes.crearVocabulario,
          );
          if (creado == true && mounted) {
            setState(() { _vocabulario = _admin.verMiVocabulario(); });
          }
        },
        tooltip: 'Crear vocabulario',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Botbarstyle(
        iBarIndex: Dataholder.instance.iBarIndex,
      ),
    );
  }
}
