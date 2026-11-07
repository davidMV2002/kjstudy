import 'package:flutter/material.dart';

import '../admin/FirebaseAdmin.dart';
import '../objects/Kanji.dart';
import '../objects/Vocabulario.dart';

class Crearvocabularioview extends StatefulWidget {
  const Crearvocabularioview({super.key});

  @override
  State<Crearvocabularioview> createState() => _CrearvocabularioviewState();
}

class _CrearvocabularioviewState extends State<Crearvocabularioview> {
  final _form = GlobalKey<FormState>();
  final _palabra = TextEditingController();
  final _lectura = TextEditingController();
  final _significado = TextEditingController();
  final _kanjiManual = TextEditingController();
  final _admin = Firebaseadmin();
  final Set<String> _kanjiIds = {};
  late Future<List<Kanji>> _kanjis = _admin.verKanjisParaVocabulario();
  bool _guardando = false;

  @override
  void dispose() {
    _palabra.dispose();
    _lectura.dispose();
    _significado.dispose();
    _kanjiManual.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await _admin.crearVocabulario(
        Vocabulario(
          palabra: _palabra.text.trim(),
          lectura: _lectura.text.trim(),
          significado: _significado.text.trim(),
          kanjiIds: _kanjiIds.toList(),
          fechaModificacion: DateTime.now(),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido guardar el vocabulario. Inténtalo de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String? _obligatorio(String? valor) => valor == null || valor.trim().isEmpty
      ? 'Este campo es obligatorio'
      : null;

  void _agregarKanji() {
    final caracter = _kanjiManual.text.trim();
    if (caracter.runes.length != 1 ||
        caracter == '/' ||
        !_palabra.text.contains(caracter)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Introduce un solo carácter que aparezca en la palabra.',
          ),
        ),
      );
      return;
    }
    setState(() => _kanjiIds.add(caracter));
    _kanjiManual.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear vocabulario')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8EAE5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text(
                    '語',
                    style: TextStyle(fontSize: 42, color: Color(0xFF963F38)),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu colección',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: const Color(0xFF963F38)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Añade una palabra',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Guarda una palabra y sus lecturas para repasarlas.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Datos principales',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _palabra,
              decoration: const InputDecoration(labelText: 'Palabra'),
              validator: _obligatorio,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lectura,
              decoration: const InputDecoration(labelText: 'Lectura'),
              validator: _obligatorio,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _significado,
              decoration: const InputDecoration(labelText: 'Significado'),
              validator: _obligatorio,
            ),
            const SizedBox(height: 24),
            Text(
              'Kanjis que componen la palabra (opcional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Selecciona una tarjeta o añade un carácter aunque aún no tenga tarjeta.',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kanjiManual,
                    enabled: !_guardando,
                    decoration: const InputDecoration(
                      labelText: 'Añadir kanji manualmente',
                    ),
                    onSubmitted: (_) => _agregarKanji(),
                  ),
                ),
                IconButton(
                  onPressed: _guardando ? null : _agregarKanji,
                  tooltip: 'Añadir kanji',
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_kanjiIds.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _kanjiIds
                    .map(
                      (id) => InputChip(
                        label: Text(id),
                        onDeleted: _guardando
                            ? null
                            : () => setState(() => _kanjiIds.remove(id)),
                      ),
                    )
                    .toList(),
              ),
            FutureBuilder<List<Kanji>>(
              future: _kanjis,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return TextButton(
                    onPressed: () => setState(() {
                      _kanjis = _admin.verKanjisParaVocabulario();
                    }),
                    child: const Text(
                      'No se han podido cargar los kanjis. Reintentar',
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final disponibles = snapshot.data!
                    .where(
                      (kanji) =>
                          kanji.id != null &&
                          _palabra.text.contains(kanji.caracter) &&
                          kanji.caracter.isNotEmpty,
                    )
                    .toList();
                if (disponibles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No hay tarjetas disponibles para esta palabra. Puedes añadir sus kanjis manualmente.',
                    ),
                  );
                }
                return Column(
                  children: disponibles
                      .map(
                        (kanji) => CheckboxListTile(
                          value: _kanjiIds.contains(kanji.caracter),
                          title: Text(
                            '${kanji.caracter} — ${kanji.significado}',
                          ),
                          onChanged: _guardando
                              ? null
                              : (seleccionado) {
                                  setState(() {
                                    if (seleccionado == true) {
                                      _kanjiIds.add(kanji.caracter);
                                    } else {
                                      _kanjiIds.remove(kanji.caracter);
                                    }
                                  });
                                },
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_guardando ? 'Guardando…' : 'Guardar vocabulario'),
            ),
          ],
        ),
      ),
    );
  }
}
