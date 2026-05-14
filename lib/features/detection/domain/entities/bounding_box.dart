library;

import 'package:equatable/equatable.dart';

final class BoundingBox extends Equatable {
  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  final double x1;

  final double y1;

  final double x2;

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
