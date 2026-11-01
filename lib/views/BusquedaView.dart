import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  // Cada colección se escucha en tiempo real y se convierte a su modelo.
  // Los kanjis compartidos se interpretan con los mismos campos que los kanjis.
  late final Stream<QuerySnapshot<Kanji>> _kanjis = FirebaseFirestore.instance
      .collection('kanjis')
      .withConverter<Kanji>(fromFirestore: Kanji.fromFirestore,
          toFirestore: (kanji, _) => kanji.toFirestore())
      .snapshots();
  late final Stream<QuerySnapshot<Kanji>> _compartidos = FirebaseFirestore.instance
      .collection('kanjiscomunitarios')
      .withConverter<Kanji>(fromFirestore: Kanji.fromFirestore,
          toFirestore: (kanji, _) => kanji.toFirestore())
      .snapshots();
  late final Stream<QuerySnapshot<Vocabulario>> _vocabulario = FirebaseFirestore.instance
      .collection('vocabulario')
      .withConverter<Vocabulario>(fromFirestore: Vocabulario.fromFirestore,
          toFirestore: (palabra, _) => palabra.toFirestore())
      .snapshots();

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
        Expanded(child: StreamBuilder<QuerySnapshot<Kanji>>(
          stream: _kanjis,
          builder: (context, kanjis) => StreamBuilder<QuerySnapshot<Kanji>>(
            stream: _compartidos,
            builder: (context, compartidos) => StreamBuilder<QuerySnapshot<Vocabulario>>(
              stream: _vocabulario,
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
                  ...kanjis.data!.docs.map((doc) => _Resultado.kanji(doc.data(), false)),
                  ...compartidos.data!.docs.map((doc) => _Resultado.kanji(doc.data(), true)),
                  ...vocabulario.data!.docs.map((doc) => _Resultado.vocabulario(doc.data())),
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

