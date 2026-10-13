import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un documento de la colección `kanjis` en Firestore.
class Kanji {

  final String? id;
  final String caracter;
  final List<String> lecturasKun;
  final List<String> lecturasOn;
  final String nivelJLPT;
  final String significado;
  final DateTime fechaModificacion;

  const Kanji({
    this.id,
    required this.caracter,
    required this.lecturasKun,
    required this.lecturasOn,
    required this.nivelJLPT,
    required this.significado,
    required this.fechaModificacion,
  });

  factory Kanji.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
    SnapshotOptions? options,
  ) {
    final data = document.data() ?? {};

    return Kanji(
      id: document.id,
      caracter: data['caracter'] as String? ?? '',
      lecturasKun: List<String>.from(data['lecturasKun'] ?? []),
      lecturasOn: List<String>.from(data['lecturasOn'] ?? []),
      nivelJLPT: data['nivelJLPT'] as String? ?? '',
      significado: data['significado'] as String? ?? '',
      fechaModificacion:
          (data['fechamodificacion'] as Timestamp?)?.toDate() ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'caracter': caracter,
      'lecturasKun': lecturasKun,
      'lecturasOn': lecturasOn,
      'nivelJLPT': nivelJLPT,
      'significado': significado,
      'fechamodificacion': Timestamp.fromDate(fechaModificacion),
    };
  }
}
