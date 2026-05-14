library;

import 'dart:typed_data';

import '../entities/disease_result.dart';
import '../repositories/disease_detection_repository.dart';

final class RunDiseaseDetectionUseCase {
  const RunDiseaseDetectionUseCase(this._repository);

  final DiseaseDetectionRepository _repository;

  Future<DiseaseResult> call(Uint8List imageBytes) =>
      _repository.classifyImage(imageBytes);
}
