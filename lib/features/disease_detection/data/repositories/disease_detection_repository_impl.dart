/// Concrete implementation of [DiseaseDetectionRepository].
///
/// Decodes image bytes, resizes to the model's expected input size,
/// normalises to [0, 1], runs inference, then argmax-decodes the output.
library;

import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/disease_result.dart';
import '../../domain/repositories/disease_detection_repository.dart';
import '../datasources/disease_model_datasource.dart';

final class DiseaseDetectionRepositoryImpl
    implements DiseaseDetectionRepository {
  DiseaseDetectionRepositoryImpl({
    required DiseaseModelDataSource modelDataSource,
  }) : _model = modelDataSource;

  final DiseaseModelDataSource _model;

  @override
  Future<void> initialise() => _model.initialise();

  @override
  Future<void> dispose() async => _model.dispose();

  @override
  Future<DiseaseResult> classifyImage(Uint8List imageBytes) async {
    final inputBuffer = _preprocessImageBytes(imageBytes);
    final probabilities = await _model.runInference(inputBuffer);
    return _parseOutput(probabilities);
  }

  // ── Preprocessing ──────────────────────────────────────────────────────────

  Float32List _preprocessImageBytes(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) throw StateError('Could not decode image bytes');

    final size = _model.isInitialised
        ? _model.inputSize
        : AppConstants.diseaseInputSize;

    final resized = img.copyResize(
      image,
      width: size,
      height: size,
      interpolation: img.Interpolation.linear,
    );

    final buffer = Float32List(size * size * 3);
    var idx = 0;
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final pixel = resized.getPixel(x, y);
        buffer[idx++] = pixel.r / 255.0;
        buffer[idx++] = pixel.g / 255.0;
        buffer[idx++] = pixel.b / 255.0;
      }
    }
    return buffer;
  }

  // ── Output parsing ─────────────────────────────────────────────────────────

  DiseaseResult _parseOutput(List<double> probabilities) {
    var maxScore = 0.0;
    var classIdx = 0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxScore) {
        maxScore = probabilities[i];
        classIdx = i;
      }
    }

    final safeIdx = classIdx.clamp(0, AppConstants.diseaseLabels.length - 1);
    final label = AppConstants.diseaseLabels[safeIdx];

    return DiseaseResult(
      label: label,
      confidence: maxScore,
      classIndex: safeIdx,
      isHealthy: label.toLowerCase() == 'healthy',
    );
  }
}
