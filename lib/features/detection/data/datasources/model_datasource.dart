/// TFLite model data source — loads the interpreter and runs inference.
///
/// Handles:
///  - Async interpreter loading from the Flutter asset bundle.
///  - Android: 3-tier delegate cascade: GPU → NNAPI → XNNPack → CPU baseline.
///  - iOS: Core ML delegate with CPU fallback.
///  - Dynamic thread count based on device processor count.
///  - Single forward pass with pre-allocated output buffers.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Wraps the TFLite interpreter lifecycle and raw inference call.
///
/// Call [initialise] once before any [runInference] calls.
/// Call [dispose] when the detection pipeline is torn down.
final class ModelDataSource {
  ModelDataSource();

  Interpreter? _interpreter;
  bool _isInitialised = false;

  /// Human-readable name of the delegate that was successfully applied.
  String _activeDelegate = 'CPU';

  bool get isInitialised => _isInitialised;

  /// Which acceleration backend is in use (e.g. "GPU", "NNAPI", "XNNPack", "CPU").
  String get activeDelegate => _activeDelegate;

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Loads the `.tflite` asset, registers the best available delegate, and
  /// allocates tensors.
  ///
  /// Idempotent — safe to call multiple times.
  /// Throws [ModelFailure] if the asset cannot be loaded.
  Future<void> initialise() async {
    if (_isInitialised) return;

    // Determine optimal thread count: leave one core free for the UI thread.
    final threads = (Platform.numberOfProcessors - 1).clamp(2, 4);

    // Delegate strategy:
    // - Android: No hardware delegates. GpuDelegateV2 causes silent hangs on
    //   Mali/Adreno; XNNPackDelegate causes an uncatchable SIGSEGV on Exynos
    //   9xxx devices (Samsung Galaxy M21). Falls through to CPU baseline.
    // - iOS: CoreML delegate with CPU fallback.
    final delegatesToTry = <_DelegateTier>[
      if (Platform.isIOS)
        _DelegateTier(
          name: 'CoreML',
          build: () => CoreMlDelegate(),
        ),
    ];

    for (final tier in delegatesToTry) {
      try {
        final options = InterpreterOptions()..threads = threads;
        options.addDelegate(tier.build());

        _interpreter = await Interpreter.fromAsset(
          AppConstants.modelAssetPath,
          options: options,
        );
        _interpreter!.allocateTensors();
        _isInitialised = true;
        _activeDelegate = tier.name;

        final inputShape = _interpreter!.getInputTensor(0).shape;
        final outputShape = _interpreter!.getOutputTensor(0).shape;
        _log.i(
          'Model ready [$_activeDelegate] — '
          'input: $inputShape  output: $outputShape  threads: $threads',
        );
        return; // success — exit early
      } catch (e) {
        _log.w('${tier.name} delegate failed, trying next: $e');
        _interpreter?.close();
        _interpreter = null;
      }
    }

    // Baseline: plain multithreaded CPU — always supported.
    try {
      final options = InterpreterOptions()..threads = threads;
      _interpreter = await Interpreter.fromAsset(
        AppConstants.modelAssetPath,
        options: options,
      );
      _interpreter!.allocateTensors();
      _isInitialised = true;
      _activeDelegate = 'CPU';

      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      _log.i(
        'Model ready [CPU] — '
        'input: $inputShape  output: $outputShape  threads: $threads',
      );
    } catch (e, st) {
      _log.e('Model load failed (CPU fallback)', error: e, stackTrace: st);
      throw ModelFailure('Failed to load TFLite model: $e');
    }
  }

  // ── Inference ─────────────────────────────────────────────────────────────

  /// Runs a single YOLO11 forward pass.
  ///
  /// [inputBuffer] — flat [Float32List] of shape
  ///   `[1 × inputSize × inputSize × 3]` normalised to [0, 1].
  ///
  /// Returns the raw output tensor as `List<List<double>>` of shape
  ///   `[7, 8400]` where rows are features (cx, cy, w, h, c0, c1, c2) and
  ///   columns are anchor candidates.
  ///
  /// Throws [StateError] if called before [initialise].
  Future<List<List<double>>> runInference(Float32List inputBuffer) async {
    if (!_isInitialised || _interpreter == null) {
      throw StateError(
        'ModelDataSource not initialised. Call initialise() first.',
      );
    }

    // Reshape flat buffer to NHWC [1, 640, 640, 3] for the interpreter.
    final input = inputBuffer.reshape([
      1,
      AppConstants.inputSize,
      AppConstants.inputSize,
      3,
    ]);

    // Pre-allocate output buffer matching the model's output tensor [1, 7, 8400].
    final output = List.generate(
      1,
      (_) => List.generate(
        AppConstants.numClasses + 4, // 4 box coords + numClasses scores
        (_) => List<double>.filled(8400, 0.0),
      ),
    );

    _interpreter!.run(input, output);

    // Slice off the batch dimension — callers expect [7][8400].
    return output[0];
  }

  // ── Disposal ──────────────────────────────────────────────────────────────

  /// Closes the interpreter and releases native resources.
  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _isInitialised = false;
    _log.d('ModelDataSource disposed');
  }
}

// ── Private helper ─────────────────────────────────────────────────────────

/// Pairs a human-readable delegate name with a factory function.
///
/// Used by [ModelDataSource.initialise] to try each accelerator in order
/// without duplicating the interpreter-creation boilerplate.
final class _DelegateTier {
  const _DelegateTier({required this.name, required this.build});
  final String name;
  final Delegate Function() build;
}
