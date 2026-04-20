/// Abstract repository contract for the detection feature.
library;

import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../entities/detection.dart';

/// Defines what the domain layer expects from a detection data source.
abstract interface class DetectionRepository {
  /// Runs inference on a single [CameraImage] frame and returns
  /// a list of [Detection] results.
  ///
  /// Optional [confidenceThreshold] and [maxDetections] override app defaults,
  /// allowing the caller to pass per-session settings.
  ///
  /// Returns an empty list when no detections meet the confidence threshold.
  /// Throws a [StateError] (wrapped as a [ModelFailure] at the data layer)
  /// if the model is not initialised.
  Future<List<Detection>> detect(
    CameraImage frame, {
    double? confidenceThreshold,
    int? maxDetections,
    /// Intermediate preprocessing resolution (320 / 416 / 640).
    /// Controls speed vs quality of the YUV→RGB conversion.
    /// Defaults to [AppConstants.inputSize] (640) when null.
    int? preprocessSize,
  });

  /// Runs inference on a single static image and returns
  /// a list of [Detection] results.
  Future<List<Detection>> detectOnImage(
    Uint8List imageBytes,
    int width,
    int height, {
    double? confidenceThreshold,
    int? maxDetections,
  });

  /// Loads the TFLite model and allocates tensors.
  /// Must be called once before [detect].
  Future<void> initialise();

  /// Releases interpreter and native resources.
  Future<void> dispose();
}
