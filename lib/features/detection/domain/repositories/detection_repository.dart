library;

import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../entities/detection.dart';

abstract interface class DetectionRepository {
  Future<List<Detection>> detect(
    CameraImage frame, {
    double? confidenceThreshold,
    int? maxDetections,
    int? preprocessSize,
  });

  Future<List<Detection>> detectOnImage(
    Uint8List imageBytes,
    int width,
    int height, {
    double? confidenceThreshold,
    int? maxDetections,
  });

  Future<void> initialise();

  Future<void> dispose();
}
