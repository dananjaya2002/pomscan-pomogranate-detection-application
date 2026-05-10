/// Central configuration constants for the pomegranate detection app.
library;

import 'package:flutter/material.dart';

abstract final class AppConstants {
  // ── Ripeness detection model ───────────────────────────────────────────────
  /// Low-latency quantized model used for real-time camera detection.
  static const String realtimeDetectionModelAssetPath =
      'assets/models/pomegranate_detection_best_int8.tflite';

  /// Higher-accuracy model used for static image scanning.
  static const String staticDetectionModelAssetPath =
      'assets/models/pomegranate_detection_best_float32.tflite';

  /// Input tensor spatial size (width == height).
  static const int inputSize = 640;

  /// Number of detection classes.
  static const int numClasses = 3;

  /// Class label index → name mapping (matches training order).
  static const List<String> classLabels = ['ripe', 'semi_ripe', 'unripe'];

  // ── Disease classification model ───────────────────────────────────────────
  static const String diseaseModelAssetPath =
      'assets/models/pomegranate_disease.tflite';

  /// Default input spatial size for the disease classifier.
  /// The actual size is read from the interpreter tensor shape at runtime.
  static const int diseaseInputSize = 224;

  /// Number of disease classification classes.
  static const int diseaseNumClasses = 5;

  /// Class label index → name mapping (matches disease model training order).
  static const List<String> diseaseLabels = [
    'Alternaria',
    'Anthracnose',
    'Bacterial_Blight',
    'Cercospora',
    'healthy',
  ];

  /// Maps model class name → diseases.json item id.
  /// Empty string means no knowledge-base entry (healthy).
  static const Map<String, String> diseaseLabelToInfoId = {
    'Alternaria': 'fruit_rot',
    'Anthracnose': 'anthracnose',
    'Bacterial_Blight': 'bacterial_blight',
    'Cercospora': 'cercospora_blight',
    'healthy': '',
  };

  static const Map<String, Color> diseaseColors = {
    'Alternaria': Color(0xFFE67E22), // orange-brown
    'Anthracnose': Color(0xFF8E44AD), // purple
    'Bacterial_Blight': Color(0xFFE74C3C), // red
    'Cercospora': Color(0xFFD4AC0D), // amber
    'healthy': Color(0xFF27AE60), // green
  };

  // ── Inference thresholds ───────────────────────────────────────────────────
  /// Minimum class score to retain a box before NMS.
  static const double confidenceThreshold = 0.45;

  /// Static image scan threshold.
  /// Kept lower than realtime to recover recall on float32 exports.
  static const double staticConfidenceThreshold = 0.25;

  /// IoU threshold for Non-Maximum Suppression.
  static const double iouThreshold = 0.50;

  /// Maximum detections returned after NMS.
  static const int maxDetections = 10;

  // ── Frame pipeline ─────────────────────────────────────────────────────────
  /// Process every Nth camera frame to reduce CPU/GPU load.
  static const int frameSkip = 5;

  // ── Overlay colours ────────────────────────────────────────────────────────
  static const Map<String, Color> classColors = {
    'ripe': Color(0xFF4CAF50), // green  — ripe
    'semi_ripe': Color(0xFF2196F3), // blue   — semi-ripe
    'unripe': Color(0xFFF44336), // red    — unripe
  };

  // ── UI ─────────────────────────────────────────────────────────────────────
  static const double bboxStrokeWidth = 2.5;
  static const double labelFontSize = 12.0;
  static const double labelPadding = 4.0;
  static const double labelBorderRadius = 4.0;
}
