/// Immutable value object holding all user-configurable app settings.
library;

import 'package:camera/camera.dart';

/// Performance preset that maps to a frame-skip value.
enum PerformanceMode {
  smooth(frameSkip: 2, label: 'Smooth', hint: 'Best quality, higher battery'),
  balanced(
    frameSkip: 3,
    label: 'Balanced',
    hint: 'Recommended for most phones',
  ),
  aggressive(frameSkip: 5, label: 'Fast', hint: 'Best speed, lower quality');

  const PerformanceMode({
    required this.frameSkip,
    required this.label,
    required this.hint,
  });

  final int frameSkip;
  final String label;
  final String hint;
}

/// Camera quality preset shown to the user.
enum CameraQuality {
  low(preset: ResolutionPreset.low, label: 'Low', hint: 'Fastest, less detail'),
  medium(preset: ResolutionPreset.medium, label: 'Medium', hint: 'Balanced'),
  high(preset: ResolutionPreset.high, label: 'High', hint: 'Sharpest, slower');

  const CameraQuality({
    required this.preset,
    required this.label,
    required this.hint,
  });

  final ResolutionPreset preset;
  final String label;
  final String hint;
}

/// Preprocessing resolution that controls speed vs. quality of the
/// YUV→RGB conversion step running in the background isolate.
///
/// Lower values sample fewer camera pixels (step-based downscaling) so
/// the conversion loop runs faster, trading a small amount of detail
/// for a meaningful FPS improvement on CPU-only devices.
enum ModelInputSize {
  fast(
    pixels: 320,
    label: '320',
    hint: 'Fastest, lower quality',
  ),
  balanced(
    pixels: 416,
    label: '416',
    hint: 'Balanced',
  ),
  quality(
    pixels: 640,
    label: '640',
    hint: 'Best quality, slower',
  );

  const ModelInputSize({
    required this.pixels,
    required this.label,
    required this.hint,
  });

  final int pixels;
  final String label;
  final String hint;
}


final class AppSettings {
  const AppSettings({
    this.cameraQuality = CameraQuality.high,
    this.performanceMode = PerformanceMode.balanced,
    this.confidenceThreshold = 0.45,
    this.maxDetections = 10,
    this.modelInputSize = ModelInputSize.balanced,
  });

  final CameraQuality cameraQuality;
  final PerformanceMode performanceMode;

  /// Minimum confidence score [0.0–1.0] to show a detection box.
  final double confidenceThreshold;

  /// Maximum number of bounding boxes shown on screen at once.
  final int maxDetections;

  /// Preprocessing resolution — controls YUV→RGB sampling speed.
  final ModelInputSize modelInputSize;

  AppSettings copyWith({
    CameraQuality? cameraQuality,
    PerformanceMode? performanceMode,
    double? confidenceThreshold,
    int? maxDetections,
    ModelInputSize? modelInputSize,
  }) => AppSettings(
    cameraQuality: cameraQuality ?? this.cameraQuality,
    performanceMode: performanceMode ?? this.performanceMode,
    confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
    maxDetections: maxDetections ?? this.maxDetections,
    modelInputSize: modelInputSize ?? this.modelInputSize,
  );
}
