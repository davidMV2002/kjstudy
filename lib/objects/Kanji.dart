import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un documento de la colección `kanjis` en Firestore.
class Kanji {

  final String? id;
  final String caracter;
  final List<String> lecturasKun;
  final List<String> lecturasOn;
  final String nivelJLPT;
  final String significado;
  final int? leccion;
  final bool compartido;
  final String? creador;
  final DateTime fechaModificacion;

  const Kanji({
    this.id,
    required this.caracter,
    required this.lecturasKun,
    required this.lecturasOn,
    required this.nivelJLPT,
    required this.significado,
    this.leccion,
    this.compartido = false,
    this.creador,
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
      leccion: (data['leccion'] as num?)?.toInt(),
      compartido: data['compartido'] as bool? ?? false,
      creador: data['creador'] as String?,
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
      'leccion': leccion,
      'compartido': compartido,
      if (creador != null) 'creador': creador,
      'fechamodificacion': Timestamp.fromDate(fechaModificacion),
    };
  }
}
