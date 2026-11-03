import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kjstudy/DataHolder.dart';

import '../insLib/BotBarStyle.dart';

class Perfilview extends StatelessWidget{
  Dataholder dh = Dataholder.instance;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          Text("Nombre: " + dh.perfilUsuario.nombre),
          Text("Nivel de japonés: " + dh.perfilUsuario.nivel)
        ],
      ),
      bottomNavigationBar: Botbarstyle(
        iBarIndex: dh.iBarIndex,
      ),
    );
  }
}