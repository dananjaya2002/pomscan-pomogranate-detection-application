library;

import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../entities/detection.dart';
import '../repositories/detection_repository.dart';

final class RunDetectionUseCase {
  const RunDetectionUseCase(this._repository);

  final DetectionRepository _repository;

  Future<List<Detection>> call(
    CameraImage frame, {
    double? confidenceThreshold,
    int? maxDetections,
    int? preprocessSize,
  }) =>
      _repository.detect(
        frame,
        confidenceThreshold: confidenceThreshold,
        maxDetections: maxDetections,
        preprocessSize: preprocessSize,
      );

  Future<List<Detection>> callStatic(
    Uint8List imageBytes,
    int width,
    int height, {
    double? confidenceThreshold,
    int? maxDetections,
  }) =>
      _repository.detectOnImage(
        imageBytes,
        width,
        height,
        confidenceThreshold: confidenceThreshold,
        maxDetections: maxDetections,
      );
}
