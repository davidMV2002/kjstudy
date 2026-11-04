import 'package:flutter/material.dart';
import 'package:kjstudy/DataHolder.dart';

import '../insLib/BotBarStyle.dart';
import 'StudyDetailComponents.dart';

class Perfilview extends StatelessWidget {
  Dataholder dh = Dataholder.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          StudyHero(
            label: 'Tu espacio de estudio',
            title: dh.perfilUsuario.nombre,
          ),
          const SizedBox(height: 16),
          StudySection(
            title: 'Nivel de japonés',
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dh.perfilUsuario.nivel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Botbarstyle(iBarIndex: dh.iBarIndex),
    );
  }
}
