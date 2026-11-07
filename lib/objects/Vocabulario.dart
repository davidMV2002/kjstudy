import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un documento de la colección `vocabulario` en Firestore.
class Vocabulario {
  final String? id;
  final List<String> kanjiIds;
  final String lectura;
  final String palabra;
  final String significado;
  final bool compartido;
  final String? creador;
  final DateTime fechaModificacion;

  const Vocabulario({
    this.id,
    this.kanjiIds = const [],
    required this.lectura,
    required this.palabra,
    required this.significado,
    this.compartido = false,
    this.creador,
    required this.fechaModificacion,
  });

  factory Vocabulario.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
    SnapshotOptions? options,
  ) {
    final data = document.data() ?? {};

    return Vocabulario(
      id: document.id,
      kanjiIds: List<String>.from(data['kanjiIds'] ?? []),
      lectura: data['lectura'] as String? ?? '',
      palabra: data['palabra'] as String? ?? '',
      significado: data['significado'] as String? ?? '',
      compartido: data['compartido'] as bool? ?? false,
      creador: data['creador'] as String?,
      fechaModificacion:
          (data['fechamodificacion'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'kanjiIds': kanjiIds,
      'lectura': lectura,
      'palabra': palabra,
      'significado': significado,
      'compartido': compartido,
      if (creador != null) 'creador': creador,
      'fechamodificacion': Timestamp.fromDate(fechaModificacion),
    };
  }
}
