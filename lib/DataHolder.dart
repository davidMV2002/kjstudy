import 'objects/Kanji.dart';
import 'objects/Vocabulario.dart';

class Dataholder {
  Dataholder._();

  static final Dataholder instance = Dataholder._();

  late Kanji kanji;
  late Vocabulario vocabulario;
}