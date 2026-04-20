/// Use-case: classify disease in a single image.
library;

import 'dart:typed_data';

import '../entities/disease_result.dart';
import '../repositories/disease_detection_repository.dart';

/// Thin facade over [DiseaseDetectionRepository.classifyImage].
final class RunDiseaseDetectionUseCase {
  const RunDiseaseDetectionUseCase(this._repository);

  final DiseaseDetectionRepository _repository;

  Future<DiseaseResult> call(Uint8List imageBytes) =>
      _repository.classifyImage(imageBytes);
}
