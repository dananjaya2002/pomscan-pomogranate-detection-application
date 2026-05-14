library;

import 'package:equatable/equatable.dart';

final class DiseaseResult extends Equatable {
  const DiseaseResult({
    required this.label,
    required this.confidence,
    required this.classIndex,
    required this.isHealthy,
  });

  final String label;

  final double confidence;

  final int classIndex;

  final bool isHealthy;

  @override
  List<Object?> get props => [label, confidence, classIndex, isHealthy];
}
