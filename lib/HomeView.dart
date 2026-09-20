import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Homeview extends StatelessWidget{
 late BuildContext miContext;

 funKanjis(){
  Navigator.popAndPushNamed(miContext, "/KanjiListView");
 }

 funVocabulario(){
   Navigator.popAndPushNamed(miContext, "/VocabularioListView");
 }

 funTest(){
   Navigator.popAndPushNamed(miContext, "/TestView");
 }

 @override
  Widget build(BuildContext context) {
    miContext=context;
    return Scaffold(
      appBar: AppBar(
        title: Text("KJ STUDY", textAlign: TextAlign.center,),
        backgroundColor: Colors.blue[200],),
      body: Column(
        children: [
          TextButton(onPressed: funKanjis, child: Text("Lista de Kanjis")),
          TextButton(onPressed: funVocabulario, child: Text("Lista de Vocabulario")),
          TextButton(onPressed: funTest, child: Text("Test")),
        ],
      ),
    );
  }
}