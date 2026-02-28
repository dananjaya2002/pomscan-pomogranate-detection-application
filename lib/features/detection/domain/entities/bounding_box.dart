/// Domain entity: an axis-aligned bounding box in normalised image coordinates.
library;

import 'package:equatable/equatable.dart';

/// All coordinates are normalised to `[0.0, 1.0]` relative to the
/// model input size ([AppConstants.inputSize] × [AppConstants.inputSize]).
final class BoundingBox extends Equatable {
  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  /// Left edge (normalised).
  final double x1;

  /// Top edge (normalised).
  final double y1;

  /// Right edge (normalised).
  final double x2;

  /// Bottom edge (normalised).
  final double y2;

  double get width => x2 - x1;
  double get height => y2 - y1;
  double get centerX => (x1 + x2) / 2;
  double get centerY => (y1 + y2) / 2;

  @override
  List<Object?> get props => [x1, y1, x2, y2];

  @override
  String toString() => 'BoundingBox(x1=$x1, y1=$y1, x2=$x2, y2=$y2)';
}
