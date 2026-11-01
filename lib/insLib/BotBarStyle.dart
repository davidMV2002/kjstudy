import 'package:flutter/material.dart';
import '../AppRoutes.dart';
import '../DataHolder.dart';

class Botbarstyle extends StatelessWidget{
  final int iBarIndex;

  const Botbarstyle({super.key, required this.iBarIndex});

  void seleccionNavegador(BuildContext context, int index){
    switch(index){
      case 0: {
        // La nueva pantalla leerá el índice actualizado del DataHolder.
        Dataholder.instance.iBarIndex = index;
        Navigator.popAndPushNamed(context, AppRoutes.home);
      }

      case 1:{
        Dataholder.instance.iBarIndex = index;
        Navigator.popAndPushNamed(context, AppRoutes.busqueda);
      }

      case 2:{
        debugPrint("PROXIMAMENTE");
        //Dataholder.instance.iBarIndex = index;
        //Navigator.popAndPushNamed(context, "/XXX");
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return NavigationBar(
      onDestinationSelected: (index) => seleccionNavegador(context, index),
      indicatorColor: Colors.redAccent,
      selectedIndex: iBarIndex,
      destinations: [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Buscar'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Perfil')
      ],
    );
  }
}
