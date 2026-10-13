import 'package:flutter/material.dart';

class KanjiListView extends StatelessWidget {
  const KanjiListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Kanjis')),
      body: const Center(child: Text('Lista de kanjis en preparación.')),
    );
  }
}
//