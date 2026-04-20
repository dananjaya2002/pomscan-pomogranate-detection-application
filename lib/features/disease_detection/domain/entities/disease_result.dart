/// Domain entity representing the output of the disease classifier.
library;

import 'package:equatable/equatable.dart';

final class DiseaseResult extends Equatable {
  const DiseaseResult({
    required this.label,
    required this.confidence,
    required this.classIndex,
    required this.isHealthy,
  });

  /// Model class name (e.g. 'Alternaria', 'Cercospora', 'healthy').
  final String label;

  /// Probability / softmax score in [0, 1].
  final double confidence;

  /// Zero-based index into [AppConstants.diseaseLabels].
  final int classIndex;

  /// True when the model predicts the fruit/plant is healthy.
  final bool isHealthy;

  @override
  List<Object?> get props => [label, confidence, classIndex, isHealthy];
}
