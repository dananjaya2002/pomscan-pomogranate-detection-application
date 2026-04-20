/// TFLite disease classification model data source.
///
/// Loads [AppConstants.diseaseModelAssetPath] (a 5-class image classifier)
/// and exposes a single [runInference] method that returns raw class
/// probabilities as a [List<double>] of length [AppConstants.diseaseNumClasses].
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

final class DiseaseModelDataSource {
  DiseaseModelDataSource();

  Interpreter? _interpreter;
  bool _isInitialised = false;
  String _activeDelegate = 'CPU';

  /// Actual spatial input size read from the model tensor (default 224).
  int _inputSize = AppConstants.diseaseInputSize;

  bool get isInitialised => _isInitialised;
  String get activeDelegate => _activeDelegate;

  /// Spatial size the model expects (width == height).
  int get inputSize => _inputSize;

  // ── Initialisation ────────────────────────────────────────────────────────

  Future<void> initialise() async {
    if (_isInitialised) return;

    final threads = (Platform.numberOfProcessors - 1).clamp(2, 4);

    // iOS: attempt CoreML delegate; Android: CPU baseline only (see
    // detection ModelDataSource for rationale on skipping GPU/NNAPI).
    final delegatesToTry = <_DelegateTier>[
      if (Platform.isIOS)
        _DelegateTier(name: 'CoreML', build: () => CoreMlDelegate()),
    ];

    for (final tier in delegatesToTry) {
      try {
        final options = InterpreterOptions()..threads = threads;
        options.addDelegate(tier.build());
        _interpreter = await Interpreter.fromAsset(
          AppConstants.diseaseModelAssetPath,
          options: options,
        );
        _interpreter!.allocateTensors();
        _isInitialised = true;
        _activeDelegate = tier.name;
        _logReady(threads);
        return;
      } catch (e) {
        _log.w('${tier.name} delegate failed, trying next: $e');
        _interpreter?.close();
        _interpreter = null;
      }
    }

    // CPU baseline — always supported.
    try {
      final options = InterpreterOptions()..threads = threads;
      _interpreter = await Interpreter.fromAsset(
        AppConstants.diseaseModelAssetPath,
        options: options,
      );
      _interpreter!.allocateTensors();
      _isInitialised = true;
      _activeDelegate = 'CPU';
      _logReady(threads);
    } catch (e, st) {
      _log.e('Disease model load failed (CPU fallback)', error: e, stackTrace: st);
      throw ModelFailure('Failed to load disease TFLite model: $e');
    }
  }

  void _logReady(int threads) {
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    // inputShape = [1, H, W, 3]
    _inputSize = inputShape[1];
    _log.i(
      'Disease model ready [$_activeDelegate] — '
      'input: $inputShape  output: $outputShape  threads: $threads',
    );
  }

  // ── Inference ─────────────────────────────────────────────────────────────

  /// Runs the classifier forward pass.
  ///
  /// [inputBuffer] — flat [Float32List] of shape
  ///   `[1 × inputSize × inputSize × 3]` normalised to [0, 1].
  ///
  /// Returns raw output logits / probabilities as `List<double>` of length
  ///   [AppConstants.diseaseNumClasses].
  Future<List<double>> runInference(Float32List inputBuffer) async {
    if (!_isInitialised || _interpreter == null) {
      throw StateError(
        'DiseaseModelDataSource not initialised. Call initialise() first.',
      );
    }

    final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);
    final output = List.generate(
      1,
      (_) => List<double>.filled(AppConstants.diseaseNumClasses, 0.0),
    );

    _interpreter!.run(input, output);
    return output[0];
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialised = false;
  }
}

// ── Internal helper ───────────────────────────────────────────────────────────

final class _DelegateTier {
  const _DelegateTier({required this.name, required this.build});
  final String name;
  final Delegate Function() build;
}
