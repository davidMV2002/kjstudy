import 'package:flutter/material.dart';

import '../../DataHolder.dart';
import '../../AppRoutes.dart';
import '../../insLib/BotBarStyle.dart';
import '../../objects/Kanji.dart';
import '../../admin/FirebaseAdmin.dart';

class Leccionesview extends StatefulWidget {
  const Leccionesview({super.key});

  @override
  State<Leccionesview> createState() => _LeccionesState();
}

class _LeccionesState extends State<Leccionesview> {
  // Conserva la consulta para no repetirla en cada build.
  late final Future<List<Kanji>> _kanjis = Firebaseadmin().verKanjis();
  final Dataholder dh = Dataholder.instance;

  void clicLeccion(int leccion) {
    dh.leccion = leccion;
    Navigator.pushNamed(context, AppRoutes.kanjis);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecciones')),
      body: FutureBuilder<List<Kanji>>(
        future: _kanjis,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se han podido cargar las lecciones.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Agrupa por lección sin crear ni duplicar documentos en Firestore.
          final cantidades = <int, int>{};
          for (final kanji in snapshot.data!) {
            final leccion = kanji.leccion;
            if (leccion != null && leccion > 0) {
              cantidades.update(
                leccion,
                (cantidad) => cantidad + 1,
                ifAbsent: () => 1,
              );
            }
          }
          final lecciones = cantidades.keys.toList()..sort();
          if (lecciones.isEmpty) {
            return const Center(child: Text('Todavía no hay lecciones.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: lecciones.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TU CAMINO DE ESTUDIO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF963F38),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aprende paso a paso',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Elige una lección para explorar sus kanjis.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }
              final leccion = lecciones[index - 1];
              final cantidad = cantidades[leccion]!;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  onTap: () => clicLeccion(leccion),
                  leading: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8EAE5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '$leccion',
                      style: const TextStyle(
                        color: Color(0xFF963F38),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'Lección $leccion',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '$cantidad ${cantidad == 1 ? 'kanji' : 'kanjis'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Botbarstyle(iBarIndex: dh.iBarIndex),
    );
  }
}
