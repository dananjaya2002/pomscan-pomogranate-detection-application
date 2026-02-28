/// JSON-serialisable DTO that mirrors the [Detection] domain entity.
library;

import '../../domain/entities/bounding_box.dart';
import '../../domain/entities/detection.dart';

/// Data-model representation of a detection result.
///
/// Used at the data layer to decouple model output parsing from the domain.
final class DetectionModel {
  const DetectionModel({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.label,
    required this.confidence,
    required this.classIndex,
  });

  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final String label;
  final double confidence;
  final int classIndex;

  /// Converts this model to the domain [Detection] entity.
  Detection toEntity() => Detection(
    box: BoundingBox(x1: x1, y1: y1, x2: x2, y2: y2),
    label: label,
    confidence: confidence,
    cls: DetectionClass.values[classIndex],
  );

  factory DetectionModel.fromMap(Map<String, dynamic> map) => DetectionModel(
    x1: (map['x1'] as num).toDouble(),
    y1: (map['y1'] as num).toDouble(),
    x2: (map['x2'] as num).toDouble(),
    y2: (map['y2'] as num).toDouble(),
    label: map['label'] as String,
    confidence: (map['confidence'] as num).toDouble(),
    classIndex: map['classIndex'] as int,
  );

  Map<String, dynamic> toMap() => {
    'x1': x1,
    'y1': y1,
    'x2': x2,
    'y2': y2,
    'label': label,
    'confidence': confidence,
    'classIndex': classIndex,
  };
}
