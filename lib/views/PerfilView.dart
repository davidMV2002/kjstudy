import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kjstudy/DataHolder.dart';

import '../insLib/BotBarStyle.dart';

class Perfilview extends StatelessWidget{
  Dataholder dh = Dataholder.instance;

  @override
  Widget build(BuildContext context) {

    return Scaffold(


      bottomNavigationBar: Botbarstyle(
        iBarIndex: dh.iBarIndex,
      ),
    );
  }
}