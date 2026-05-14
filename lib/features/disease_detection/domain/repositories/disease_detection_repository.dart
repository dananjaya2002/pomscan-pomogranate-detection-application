library;

import 'dart:typed_data';

import '../entities/disease_result.dart';

abstract interface class DiseaseDetectionRepository {
  Future<void> initialise();
  Future<void> dispose();

  Future<DiseaseResult> classifyImage(Uint8List imageBytes);
}
