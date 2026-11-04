import 'package:flutter/material.dart';

import '../admin/FirebaseAdmin.dart';
import '../objects/Kanji.dart';

class Crearkanjiview extends StatefulWidget {
  const Crearkanjiview({super.key});

  @override
  State<Crearkanjiview> createState() => _CrearkanjiviewState();
}

class _CrearkanjiviewState extends State<Crearkanjiview> {
  // Permite validar los campos del formulario antes de guardar.
  final _form = GlobalKey<FormState>();

  final _caracter = TextEditingController();
  final _significado = TextEditingController();
  final _nivel = TextEditingController();
  final _kun = TextEditingController();
  final _on = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _caracter.dispose();
    _significado.dispose();
    _nivel.dispose();
    _kun.dispose();
    _on.dispose();
    super.dispose();
  }

  List<String> _lecturas(String texto) => texto
      .split(RegExp(r'[,、]'))
      .map((lectura) => lectura.trim())
      .where((lectura) => lectura.isNotEmpty)
      .toList();

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await Firebaseadmin().crearKanjiPropio(
        Kanji(
          caracter: _caracter.text.trim(),
          significado: _significado.text.trim(),
          nivelJLPT: _nivel.text.trim(),
          lecturasKun: _lecturas(_kun.text),
          lecturasOn: _lecturas(_on.text),
          fechaModificacion: DateTime.now(),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on StateError {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya tienes guardado este kanji.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido guardar el kanji. Inténtalo de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear kanji')),
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
                    '字',
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
                          'Añade un kanji',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Guarda su significado y lecturas para repasarlos.',
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
              controller: _caracter,
              decoration: const InputDecoration(labelText: 'Kanji'),
              validator: (valor) => valor == null || valor.trim().isEmpty
                  ? 'Introduce un kanji'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _significado,
              decoration: const InputDecoration(labelText: 'Significado'),
              validator: (valor) => valor == null || valor.trim().isEmpty
                  ? 'Introduce un significado'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nivel,
              decoration: const InputDecoration(
                labelText: 'Nivel JLPT (opcional)',
                hintText: 'Por ejemplo, N5',
              ),
            ),
            const SizedBox(height: 28),
            Text('Lecturas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            TextFormField(
              controller: _kun,
              decoration: const InputDecoration(
                labelText: 'Lecturas kun (opcional)',
                helperText: 'Separa las lecturas con comas',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _on,
              decoration: const InputDecoration(
                labelText: 'Lecturas on (opcional)',
                helperText: 'Separa las lecturas con comas',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_guardando ? 'Guardando…' : 'Guardar kanji'),
            ),
          ],
        ),
      ),
    );
  }
}
