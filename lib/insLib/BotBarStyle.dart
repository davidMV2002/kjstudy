import 'package:flutter/material.dart';

import '../AppRoutes.dart';
import '../DataHolder.dart';

class Botbarstyle extends StatelessWidget {
  final int iBarIndex;

  const Botbarstyle({super.key, required this.iBarIndex});

  void seleccionNavegador(BuildContext context, int index) {
    switch (index) {
      case 0:
        {
          // La nueva pantalla leerá el índice actualizado del DataHolder.
          Dataholder.instance.iBarIndex = index;
          Navigator.popAndPushNamed(context, AppRoutes.home);
        }

      case 1:
        {
          Dataholder.instance.iBarIndex = index;
          Navigator.popAndPushNamed(context, AppRoutes.busqueda);
        }

      case 2:
        {
          Dataholder.instance.iBarIndex = index;
          Navigator.popAndPushNamed(context, AppRoutes.perfilView);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (index) => seleccionNavegador(context, index),
      indicatorColor: const Color(0xFFF4D8D2),
      selectedIndex: iBarIndex,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_rounded),
          label: 'Buscar',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}
