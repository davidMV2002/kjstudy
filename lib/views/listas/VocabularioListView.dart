import 'package:flutter/material.dart';

import '../../DataHolder.dart';
import '../../objects/Vocabulario.dart';
import '../../services/VocabularioRepository.dart';

class VocabularioListView extends StatefulWidget {
  const VocabularioListView({super.key});

  @override
  State<VocabularioListView> createState() => _VocabularioListViewState();
}

class _VocabularioListViewState extends State<VocabularioListView> {
  late BuildContext miContext;

  final VocabularioRepository _vocabularioRepository =
      VocabularioRepository();

  @override
  Widget build(BuildContext context) {
    miContext = context;

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de vocabulario')),
      body: StreamBuilder<List<Vocabulario>>(
        stream: _vocabularioRepository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se ha podido cargar el vocabulario.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final vocabulario = snapshot.data!;

          if (vocabulario.isEmpty) {
            return const Center(child: Text('Todavía no hay vocabulario.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vocabulario.length,
            itemBuilder: (context, index) {
              final palabra = vocabulario[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    palabra.palabra,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(palabra.lectura),
                        const SizedBox(height: 2),
                        Text(palabra.significado),
                      ],
                    ),
                  ),
                  // Aquí añadiremos la navegación a los detalles más adelante.
                  onTap: () {
                    Navigator.pushNamed(miContext, "/VocabularioDetailView",);
                    Dataholder.instance.vocabulario = palabra;
                    print("PULSADO");
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
