/// Central configuration constants for the pomegranate detection app.
library;

import 'package:flutter/material.dart';

abstract final class AppConstants {
  // ── Model ──────────────────────────────────────────────────────────────────
  static const String modelAssetPath =
      'assets/models/pomegranate_detect.tflite';

  /// Input tensor spatial size (width == height).
  static const int inputSize = 640;

  /// Number of detection classes.
  static const int numClasses = 3;

  /// Class label index → name mapping (matches training order).
  static const List<String> classLabels = ['ripe', 'semi_ripe', 'unripe'];

  // ── Inference thresholds ───────────────────────────────────────────────────
  /// Minimum class score to retain a box before NMS.
  static const double confidenceThreshold = 0.45;

  /// IoU threshold for Non-Maximum Suppression.
  static const double iouThreshold = 0.50;

  /// Maximum detections returned after NMS.
  static const int maxDetections = 10;

  // ── Frame pipeline ─────────────────────────────────────────────────────────
  /// Process every Nth camera frame to reduce CPU/GPU load.
  static const int frameSkip = 3;

  // ── Overlay colours ────────────────────────────────────────────────────────
  static const Map<String, Color> classColors = {
    'ripe': Color(0xFF4CAF50), // green
    'semi_ripe': Color(0xFFFF9800), // orange
    'unripe': Color(0xFFF44336), // red
  };

  // ── UI ─────────────────────────────────────────────────────────────────────
  static const double bboxStrokeWidth = 2.5;
  static const double labelFontSize = 12.0;
  static const double labelPadding = 4.0;
  static const double labelBorderRadius = 4.0;
}
