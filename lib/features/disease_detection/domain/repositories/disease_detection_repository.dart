/// Abstract repository interface for disease classification.
library;

import 'dart:typed_data';

import '../entities/disease_result.dart';

abstract interface class DiseaseDetectionRepository {
  Future<void> initialise();
  Future<void> dispose();

  /// Classifies the disease visible in [imageBytes] (JPEG or PNG).
  Future<DiseaseResult> classifyImage(Uint8List imageBytes);
}
