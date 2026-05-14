library;

import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const String realtimeDetectionModelAssetPath =
      'assets/models/pomegranate_detection_best_int8.tflite';

  static const String staticDetectionModelAssetPath =
      'assets/models/pomegranate_detection_best_float32.tflite';

  static const int inputSize = 640;

  static const int numClasses = 3;

  static const List<String> classLabels = ['ripe', 'semi_ripe', 'unripe'];

  static const String diseaseModelAssetPath =
      'assets/models/pomegranate_disease.tflite';

  static const int diseaseInputSize = 224;

  static const int diseaseNumClasses = 5;

  static const List<String> diseaseLabels = [
    'Alternaria',
    'Anthracnose',
    'Bacterial_Blight',
    'Cercospora',
    'healthy',
  ];

  static const Map<String, String> diseaseLabelToInfoId = {
    'Alternaria': 'fruit_rot',
    'Anthracnose': 'anthracnose',
    'Bacterial_Blight': 'bacterial_blight',
    'Cercospora': 'cercospora_blight',
    'healthy': '',
  };

  static const Map<String, Color> diseaseColors = {
    'Alternaria': Color(0xFFE67E22),
    'Anthracnose': Color(0xFF8E44AD),
    'Bacterial_Blight': Color(0xFFE74C3C),
    'Cercospora': Color(0xFFD4AC0D),
    'healthy': Color(0xFF27AE60),
  };

  static const double confidenceThreshold = 0.45;

  static const double staticConfidenceThreshold = 0.25;

  static const double iouThreshold = 0.50;

  static const int maxDetections = 10;

  static const int frameSkip = 5;

  static const Map<String, Color> classColors = {
    'ripe': Color(0xFF4CAF50),
    'semi_ripe': Color(0xFF2196F3),
    'unripe': Color(0xFFF44336),
  };

  static const double bboxStrokeWidth = 2.5;
  static const double labelFontSize = 12.0;
  static const double labelPadding = 4.0;
  static const double labelBorderRadius = 4.0;
}
