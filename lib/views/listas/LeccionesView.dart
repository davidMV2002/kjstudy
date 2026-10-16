import 'package:flutter/material.dart';
import '../../DataHolder.dart';
import '../../AppRoutes.dart';
import '../../insLib/BotBarStyle.dart';
import '../../objects/Kanji.dart';
import '../../services/KanjiRepository.dart';

class Leccionesview extends StatefulWidget{
  const Leccionesview({super.key});

  @override
  State<Leccionesview> createState() => _LeccionesState();
}

class _LeccionesState extends State<Leccionesview> {
  // Conserva el stream para no volver a suscribirse en cada build.
  late final Stream<List<Kanji>> _kanjis = KanjiRepository().watchAll();
  final Dataholder dh = Dataholder.instance;


  void clicLeccion(int leccion) {
    dh.leccion = leccion;
    Navigator.pushNamed(context, AppRoutes.kanjis);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Lecciones')),
      body: StreamBuilder<List<Kanji>>(
        stream: _kanjis,
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
              cantidades.update(leccion, (cantidad) => cantidad + 1,
                  ifAbsent: () => 1);
            }
          }
          final lecciones = cantidades.keys.toList()..sort();
          if (lecciones.isEmpty) {
            return const Center(child: Text('Todavía no hay lecciones.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lecciones.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final leccion = lecciones[index];
              final cantidad = cantidades[leccion]!;
              return ListTile(
                onTap: () => clicLeccion(leccion),
                leading: CircleAvatar(child: Text('$leccion')),
                title: Text('Lección $leccion'),
                subtitle: Text('$cantidad ${cantidad == 1 ? 'kanji' : 'kanjis'}'),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Botbarstyle(
        iBarIndex: dh.iBarIndex,
      ),
    );
  }
}
