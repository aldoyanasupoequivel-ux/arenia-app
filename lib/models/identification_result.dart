// lib/models/identification_result.dart

import '../data/species_data.dart';

class IdentificationResult {
  /// La especie encontrada en la base de datos local, o null si no se encuentra.
  final Species? species;

  /// Nivel de confianza devuelto por la IA (0.0 – 1.0).
  final double confidence;

  /// Nombre común sugerido por la IA (siempre presente incluso si no hay coincidencia en la BD).
  final String suggestedName;

  /// Nombre científico devuelto por la IA.
  final String? scientificName;

  /// Indica si la especie identificada existe en nuestra base de datos local.
  bool get isInDatabase => species != null;

  const IdentificationResult({
    this.species,
    required this.confidence,
    required this.suggestedName,
    this.scientificName,
  });

  factory IdentificationResult.notFound({
    String suggestedName = '',
    String? scientificName,
    double confidence = 0.0,
  }) {
    return IdentificationResult(
      species: null,
      confidence: confidence,
      suggestedName: suggestedName,
      scientificName: scientificName,
    );
  }
}
