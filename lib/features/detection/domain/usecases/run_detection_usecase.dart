/// Use-case: run detection on a single camera frame.
library;

import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../entities/detection.dart';
import '../repositories/detection_repository.dart';

/// Thin use-case that delegates to [DetectionRepository.detect].
///
/// Provides a clean boundary between the presentation layer and data sources.
final class RunDetectionUseCase {
  const RunDetectionUseCase(this._repository);

  final DetectionRepository _repository;

  /// Processes [frame] and returns detected pomegranate regions.
  ///
  /// Optional [confidenceThreshold] and [maxDetections] are forwarded to NMS
  /// to apply per-session user settings instead of the compile-time defaults.
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
