import 'package:flutter/material.dart';

class VocabularioListView extends StatelessWidget {
  const VocabularioListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Vocabulario')),
      body: const Center(child: Text('Lista de vocabulario en preparación.')),
    );
  }
}
