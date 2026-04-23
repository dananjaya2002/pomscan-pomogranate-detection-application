/// Domain entity: a single object detection result.
library;

import 'package:equatable/equatable.dart';

import 'bounding_box.dart';

/// The three pomegranate ripeness classes produced by the model.
enum DetectionClass { ripe, semiRipe, unripe }

/// Represents one detected object in a camera frame.
final class Detection extends Equatable {
  const Detection({
    required this.box,
    required this.label,
    required this.confidence,
    required this.cls,
  });

  /// Normalised bounding box (0–1 relative to model input size).
  final BoundingBox box;

  /// Human-readable class label (e.g. `'ripe'`, `'semi_ripe'`, `'unripe'`).
  final String label;

  /// Class confidence score in `[0.0, 1.0]`.
  final double confidence;

  /// Strongly-typed class enum.
  final DetectionClass cls;

  /// Returns confidence as a percentage string, e.g. `"94%"`.
  String get confidencePercent =>
      '${(confidence.clamp(0.0, 1.0) * 100).round()}%';

  @override
  List<Object?> get props => [box, label, confidence, cls];

  @override
  String toString() =>
      'Detection(label=$label, confidence=$confidencePercent, box=$box)';
}
