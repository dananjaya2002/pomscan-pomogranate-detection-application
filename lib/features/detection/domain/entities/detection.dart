library;

import 'package:equatable/equatable.dart';

import 'bounding_box.dart';

enum DetectionClass { ripe, semiRipe, unripe }

final class Detection extends Equatable {
  const Detection({
    required this.box,
    required this.label,
    required this.confidence,
    required this.cls,
  });

  final BoundingBox box;

  final String label;

  final double confidence;

  final DetectionClass cls;

  String get confidencePercent =>
      '${(confidence.clamp(0.0, 1.0) * 100).round()}%';

  @override
  List<Object?> get props => [box, label, confidence, cls];

  @override
  String toString() =>
      'Detection(label=$label, confidence=$confidencePercent, box=$box)';
}
