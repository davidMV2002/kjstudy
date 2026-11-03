import 'package:flutter/material.dart';

import '../admin/FirebaseAdmin.dart';
import '../AppRoutes.dart';
import '../DataHolder.dart';
import '../insLib/BotBarStyle.dart';
import '../objects/Kanji.dart';
import '../objects/Vocabulario.dart';

class Busquedaview extends StatefulWidget {
  const Busquedaview({super.key});

  @override
  State<Busquedaview> createState() => _BusquedaviewState();
}

class _BusquedaviewState extends State<Busquedaview> {
  final dh = Dataholder.instance;
  String _busqueda = '';

  final Firebaseadmin _admin = Firebaseadmin();
  late final Future<List<Kanji>> _kanjis = _admin.verKanjisParaBusqueda();
  late final Future<List<Kanji>> _compartidos = _admin.verKanjisComunitarios();
  late final Future<List<Vocabulario>> _vocabulario = _admin.verVocabularioParaBusqueda();

  @override
  void initState() {

    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BUSCAR'), backgroundColor: Colors.blue[200]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(labelText: 'Buscar', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
            onChanged: (valor) => setState(() => _busqueda = valor.trim().toLowerCase()),
          ),
        ),
        Expanded(child: FutureBuilder<List<Kanji>>(
          future: _kanjis,
          builder: (context, kanjis) => FutureBuilder<List<Kanji>>(
            future: _compartidos,
            builder: (context, compartidos) => FutureBuilder<List<Vocabulario>>(
              future: _vocabulario,
              builder: (context, vocabulario) {
                if (kanjis.hasError || compartidos.hasError || vocabulario.hasError) {
                  return const Center(child: Text('No se han podido cargar los resultados.'));
                }
                if (!kanjis.hasData || !compartidos.hasData || !vocabulario.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Unimos los resultados antes de ordenarlos: la fecha manda
                // independientemente de la colección de la que procedan.
                final resultados = <_Resultado>[
                  ...kanjis.data!.map((kanji) => _Resultado.kanji(kanji, false)),
                  ...compartidos.data!.map((kanji) => _Resultado.kanji(kanji, true)),
                  ...vocabulario.data!.map((palabra) => _Resultado.vocabulario(palabra)),
                ]..sort((a, b) => b.fecha.compareTo(a.fecha));
                final filtrados = resultados.where((r) => r.textoBusqueda.contains(_busqueda)).toList();
                if (filtrados.isEmpty) {
                  return const Center(child: Text('No hay resultados.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtrados.length,
                  itemBuilder: (context, index) {
                    final resultado = filtrados[index];
                    return Card(child: ListTile(
                      title: Text(resultado.titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      subtitle: Text('${resultado.tipo}\n${resultado.detalle}'),
                      isThreeLine: true,
                      onTap: () {
                        // Reutilizamos las pantallas de detalle existentes.
                        if (resultado.kanji != null) {
                          dh.kanji = resultado.kanji!;
                          Navigator.pushNamed(context, AppRoutes.kanjiDetail);
                        } else {
                          dh.vocabulario = resultado.palabra!;
                          Navigator.pushNamed(context, AppRoutes.vocabularioDetail);
                        }
                      },
                    ));
                  },
                );
              },
            ),
          ),
        )),
      ]),
      bottomNavigationBar: Botbarstyle(iBarIndex: dh.iBarIndex),
    );
  }
}

// Adaptador común para poder ordenar y mostrar modelos diferentes juntos.
class _Resultado {
  final Kanji? kanji;
  final Vocabulario? palabra;
  final String tipo;
  _Resultado.kanji(Kanji valor, bool compartido)
      : kanji = valor, palabra = null, tipo = compartido ? 'Kanji compartido' : 'Kanji';
  _Resultado.vocabulario(Vocabulario valor)
      : kanji = null, palabra = valor, tipo = 'Vocabulario';
  DateTime get fecha => kanji?.fechaModificacion ?? palabra!.fechaModificacion;
  String get titulo => kanji?.caracter ?? palabra!.palabra;
  String get detalle => kanji != null
      ? '${kanji!.significado}\n${[...kanji!.lecturasKun, ...kanji!.lecturasOn].join(', ')}'
      : '${palabra!.lectura}\n${palabra!.significado}';
  String get textoBusqueda => '$titulo $detalle $tipo'.toLowerCase();
}

