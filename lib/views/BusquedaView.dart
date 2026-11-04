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
  late final Future<List<Vocabulario>> _vocabulario = _admin
      .verVocabularioParaBusqueda();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explora tu contenido',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Busca kanjis y vocabulario.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (valor) =>
                      setState(() => _busqueda = valor.trim().toLowerCase()),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Kanji>>(
              future: _kanjis,
              builder: (context, kanjis) => FutureBuilder<List<Kanji>>(
                future: _compartidos,
                builder: (context, compartidos) =>
                    FutureBuilder<List<Vocabulario>>(
                      future: _vocabulario,
                      builder: (context, vocabulario) {
                        if (kanjis.hasError ||
                            compartidos.hasError ||
                            vocabulario.hasError) {
                          return const Center(
                            child: Text(
                              'No se han podido cargar los resultados.',
                            ),
                          );
                        }
                        if (!kanjis.hasData ||
                            !compartidos.hasData ||
                            !vocabulario.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Unimos los resultados antes de ordenarlos: la fecha manda
                        // independientemente de la colección de la que procedan.
                        final resultados = <_Resultado>[
                          ...kanjis.data!.map(
                            (kanji) => _Resultado.kanji(kanji, false),
                          ),
                          ...compartidos.data!.map(
                            (kanji) => _Resultado.kanji(kanji, true),
                          ),
                          ...vocabulario.data!.map(
                            (palabra) => _Resultado.vocabulario(palabra),
                          ),
                        ]..sort((a, b) => b.fecha.compareTo(a.fecha));
                        final filtrados = resultados
                            .where((r) => r.textoBusqueda.contains(_busqueda))
                            .toList();
                        if (filtrados.isEmpty) {
                          return const Center(
                            child: Text('No hay resultados.'),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: filtrados.length,
                          itemBuilder: (context, index) {
                            final resultado = filtrados[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                title: Text(
                                  resultado.titulo,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resultado.tipo,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(resultado.detalle),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // Reutilizamos las pantallas de detalle existentes.
                                  if (resultado.kanji != null) {
                                    dh.kanji = resultado.kanji!;
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.kanjiDetail,
                                    );
                                  } else {
                                    dh.vocabulario = resultado.palabra!;
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.vocabularioDetail,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Botbarstyle(iBarIndex: dh.iBarIndex),
    );
  }
}

// Adaptador común para poder ordenar y mostrar modelos diferentes juntos.
class _Resultado {
  late final Kanji? kanji;
  final Vocabulario? palabra;
  final String tipo;
  _Resultado.kanji(Kanji valor, bool compartido)
    : kanji = valor,
      palabra = null,
      tipo = compartido
          ? 'Kanji compartido'
          : 'Kanji de la lección: ${valor!.leccion}';
  _Resultado.vocabulario(Vocabulario valor)
    : kanji = null,
      palabra = valor,
      tipo = 'Vocabulario';
  DateTime get fecha => kanji?.fechaModificacion ?? palabra!.fechaModificacion;
  String get titulo => kanji?.caracter ?? palabra!.palabra;
  String get detalle => kanji != null
      ? '${kanji!.significado}\n${[...kanji!.lecturasKun, ...kanji!.lecturasOn].join(', ')}'
      : '${palabra!.lectura}\n${palabra!.significado}';
  String get textoBusqueda => '$titulo $detalle $tipo'.toLowerCase();
}
