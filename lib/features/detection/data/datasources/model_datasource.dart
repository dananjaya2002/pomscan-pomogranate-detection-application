library;

import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

final class ModelDataSource {
  ModelDataSource({required this.modelAssetPath});

  final String modelAssetPath;

  Interpreter? _interpreter;
  bool _isInitialised = false;
  String _activeDelegate = 'CPU';

  int _inputSize = AppConstants.inputSize;
  int _outputRows = AppConstants.numClasses + 4;
  int _outputCols = 8400;
  double _lastInferenceLatencyMs = 0.0;

  bool get isInitialised => _isInitialised;
  String get activeDelegate => _activeDelegate;
  int get inputSize => _inputSize;
  int get outputRows => _outputRows;
  int get outputCols => _outputCols;
  double get lastInferenceLatencyMs => _lastInferenceLatencyMs;

  Future<void> initialise() async {
    if (_isInitialised) return;

    final threads = (Platform.numberOfProcessors - 1).clamp(2, 4);

    final delegatesToTry = <_DelegateTier>[
      if (Platform.isIOS)
        _DelegateTier(name: 'CoreML', build: () => CoreMlDelegate()),
    ];

    for (final tier in delegatesToTry) {
      try {
        final options = InterpreterOptions()..threads = threads;
        options.addDelegate(tier.build());
        _interpreter = await Interpreter.fromAsset(
          modelAssetPath,
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

    try {
      final options = InterpreterOptions()..threads = threads;
      _interpreter = await Interpreter.fromAsset(
        modelAssetPath,
        options: options,
      );
      _interpreter!.allocateTensors();
      _isInitialised = true;
      _activeDelegate = 'CPU';
      _logReady(threads);
    } catch (e, st) {
      _log.e(
        'Detection model load failed (CPU fallback)',
        error: e,
        stackTrace: st,
      );
      throw ModelFailure('Failed to load detection TFLite model: $e');
    }
  }

  void _logReady(int threads) {
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    _inputSize = inputShape[1];
    if (outputShape.length >= 3) {
      _outputRows = outputShape[1];
      _outputCols = outputShape[2];
    }
    _log.i(
      'Detection model ready [$_activeDelegate] — '
      'input: $inputShape  output: $outputShape  threads: $threads',
    );
  }

  Future<List<List<double>>> runInference(Float32List inputBuffer) async {
    if (!_isInitialised || _interpreter == null) {
      throw StateError(
        'ModelDataSource not initialised. Call initialise() first.',
      );
    }

    final expectedInputLength = _inputSize * _inputSize * 3;
    if (inputBuffer.length != expectedInputLength) {
      throw ArgumentError(
        'Input tensor shape mismatch: expected flat length '
        '$expectedInputLength (1x$_inputSize'
        'x$_inputSize'
        'x3), got ${inputBuffer.length}.',
      );
    }

    final input = inputBuffer.reshape([
      1,
      _inputSize,
      _inputSize,
      3,
    ]);

    final output = List.generate(
      1,
      (_) => List.generate(
        _outputRows,
        (_) => List<double>.filled(_outputCols, 0.0),
      ),
    );

    try {
      final stopwatch = Stopwatch()..start();
      _interpreter!.run(input, output);
      stopwatch.stop();
      _lastInferenceLatencyMs = stopwatch.elapsedMicroseconds / 1000.0;
    } on ArgumentError catch (e) {
      throw StateError('Model inference failed due to shape mismatch: $e');
    }

    return output[0];
  }

  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _isInitialised = false;
  }
}

final class _DelegateTier {
  const _DelegateTier({required this.name, required this.build});
  final String name;
  final Delegate Function() build;
}
