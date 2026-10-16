import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un documento de la colección `kanjis` en Firestore.
class Perfil {

  final String? id;
  final String nombre;
  final String nivel;

  const Perfil({
    this.id,
    required this.nombre,
    required this.nivel,
  });

  factory Perfil.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      SnapshotOptions? options,
      ) {
    final data = document.data() ?? {};

    return Perfil(
      id: document.id,
      nombre: data['nombre'] as String? ?? '',
      nivel: data['nivel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'nivel': nivel,
    };
  }
}