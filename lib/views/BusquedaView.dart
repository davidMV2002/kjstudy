import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kjstudy/DataHolder.dart';

import '../insLib/BotBarStyle.dart';

class Busquedaview extends StatefulWidget{
  
  @override
  State<Busquedaview> createState() => _BusquedaviewState();
}

class _BusquedaviewState extends State<Busquedaview> {
  Dataholder dh = Dataholder.instance;
  
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('BUSCAR', textAlign: TextAlign.center),
        backgroundColor: Colors.blue[200],
      ),
      body: Column(
        children: [
          Text("EN PROCESO"),
        ],
      ),
      bottomNavigationBar: Botbarstyle(
        iBarIndex: dh.iBarIndex,
      ),
    );
  }
}