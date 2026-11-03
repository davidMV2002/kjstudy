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
  final _admin = Firebaseadmin();
  final Set<String> _kanjiIds = {};
  late Future<List<Kanji>> _kanjis = _admin.verKanjisParaBusqueda();
  bool _guardando = false;

  @override
  void dispose() {
    _palabra.dispose();
    _lectura.dispose();
    _significado.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await _admin.crearVocabulario(Vocabulario(
        palabra: _palabra.text.trim(),
        lectura: _lectura.text.trim(),
        significado: _significado.text.trim(),
        kanjiIds: _kanjiIds.toList(),
        fechaModificacion: DateTime.now(),
      ));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha podido guardar el vocabulario. Inténtalo de nuevo.')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String? _obligatorio(String? valor) =>
      valor == null || valor.trim().isEmpty ? 'Este campo es obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear vocabulario')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _palabra,
              decoration: const InputDecoration(labelText: 'Palabra'),
              validator: _obligatorio,
              onChanged: (_) => setState(() => _kanjiIds.clear()),
            ),
            TextFormField(
              controller: _lectura,
              decoration: const InputDecoration(labelText: 'Lectura'),
              validator: _obligatorio,
            ),
            TextFormField(
              controller: _significado,
              decoration: const InputDecoration(labelText: 'Significado'),
              validator: _obligatorio,
            ),
            const SizedBox(height: 24),
            Text('Kanjis que componen la palabra (opcional)',
                style: Theme.of(context).textTheme.titleMedium),
            const Text('Selecciona los kanjis que aparecen en la palabra.'),
            FutureBuilder<List<Kanji>>(
              future: _kanjis,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return TextButton(
                    onPressed: () => setState(() => _kanjis = _admin.verKanjisParaBusqueda()),
                    child: const Text('No se han podido cargar los kanjis. Reintentar'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final disponibles = snapshot.data!.where((kanji) =>
                    kanji.id != null && _palabra.text.contains(kanji.caracter) && kanji.caracter.isNotEmpty).toList();
                if (disponibles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No hay kanjis disponibles para esta palabra.'),
                  );
                }
                return Column(
                  children: disponibles.map((kanji) => CheckboxListTile(
                    value: _kanjiIds.contains(kanji.id),
                    title: Text('${kanji.caracter} — ${kanji.significado}'),
                    onChanged: _guardando ? null : (seleccionado) {
                      setState(() {
                        if (seleccionado == true) {
                          _kanjiIds.add(kanji.id!);
                        } else {
                          _kanjiIds.remove(kanji.id);
                        }
                      });
                    },
                  )).toList(),
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
