import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kjstudy/views/HomeView.dart';
import 'package:kjstudy/views/listas/KanjiListView.dart';
import 'package:kjstudy/MyApp.dart';
import 'package:kjstudy/views/TestView.dart';
import 'package:kjstudy/views/listas/VocabularioListView.dart';

void main() {
  testWidgets('La aplicación inicia en el menú principal', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text('KJ STUDY'), findsOneWidget);
    expect(find.byType(TextButton), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  for (final destination in <String, Type>{
    'Lista de Kanjis': KanjiListView,
    'Lista de Vocabulario': VocabularioListView,
    'Test': TestView,
  }.entries) {
    testWidgets('Abre ${destination.key} y vuelve al menú', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text(destination.key));
      await tester.pumpAndSettle();

      expect(find.byType(destination.value), findsOneWidget);
      expect(find.byType(HomeView), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(HomeView), findsOneWidget);
      expect(find.byType(destination.value), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
