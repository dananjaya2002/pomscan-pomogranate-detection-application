/// Riverpod providers for the real-time detection pipeline.
///
/// [DetectionNotifier] owns the frame-to-detection lifecycle:
///   camera image stream → frame-skip throttle → async inference → NMS
///   → state update → UI rebuild.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/datasources/model_datasource.dart';
import '../../data/repositories/detection_repository_impl.dart';
import '../../domain/entities/detection.dart';
import '../../domain/usecases/run_detection_usecase.dart';
import 'camera_provider.dart';

// ── State ────────────────────────────────────────────────────────────────────

@immutable
final class DetectionState {
  const DetectionState({
    this.detections = const [],
    this.inferenceLatencyMs = 0.0,
    this.isScanActive = false,
  });

  final List<Detection> detections;
  final double inferenceLatencyMs;
  final bool isScanActive;

  DetectionState copyWith({
    List<Detection>? detections,
    double? inferenceLatencyMs,
    bool? isScanActive,
  }) =>
      DetectionState(
        detections: detections ?? this.detections,
        inferenceLatencyMs: inferenceLatencyMs ?? this.inferenceLatencyMs,
        isScanActive: isScanActive ?? this.isScanActive,
      );
}

// ── Notifier ─────────────────────────────────────────────────────────────────

/// Drives the inference loop end-to-end.
///
/// Call [startDetecting] after both the camera and the model are ready;
/// call [stopDetecting] when the app backgrounds or the widget disposes.
final class DetectionNotifier extends StateNotifier<DetectionState> {
  DetectionNotifier(this._useCase, this._ref) : super(const DetectionState());

  final RunDetectionUseCase _useCase;
  final Ref _ref;

  int _frameCounter = 0;
  int _dynamicFrameSkip = AppConstants.frameSkip;
  bool _inferenceBusy = false;
  static const int _maxAdaptiveFrameSkip = 12;

  // ── Public API ──────────────────────────────────────────────────────────

  /// Subscribes to the camera image stream and starts the inference loop.
  ///
  /// Safe to call multiple times — a running stream is stopped first.
  Future<void> startDetecting() async {
    await stopDetecting();
    _frameCounter = 0;
    _dynamicFrameSkip = AppConstants.frameSkip;
    _inferenceBusy = false;
    if (mounted) {
      state = state.copyWith(isScanActive: false);
    }
    await _ref.read(cameraProvider.notifier).startImageStream(_onFrame);
  }

  /// Stops the image stream and clears stale detections.
  ///
  /// Safe to call when the stream is not running.
  Future<void> stopDetecting() async {
    _inferenceBusy = false;
    _dynamicFrameSkip = AppConstants.frameSkip;
    try {
      await _ref.read(cameraProvider.notifier).stopImageStream();
    } catch (_) {
      // Stream may not be active — ignore.
    }
    if (mounted) {
      state = state.copyWith(
        detections: const [],
        inferenceLatencyMs: 0.0,
        isScanActive: false,
      );
    }
  }

  void startScan() {
    if (!mounted || state.isScanActive) return;
    state = state.copyWith(isScanActive: true);
  }

  void stopScan() {
    if (!mounted || !state.isScanActive) return;
    state = state.copyWith(isScanActive: false, inferenceLatencyMs: 0.0);
  }

  void toggleScan() {
    if (state.isScanActive) {
      stopScan();
      return;
    }
    startScan();
  }

  // ── Frame callback ───────────────────────────────────────────────────────

  /// Called on every raw camera frame (main thread, high frequency).
  void _onFrame(CameraImage frame) {
    if (!state.isScanActive) return;

    // Throttle: process every Nth frame (adaptive under load).
    final settings = _ref.read(settingsProvider).valueOrNull;
    final baseFrameSkip =
        settings?.realtimeFrameInterval.frames ?? AppConstants.frameSkip;
    final effectiveFrameSkip = math.max(baseFrameSkip, _dynamicFrameSkip);
    _frameCounter++;
    if (_frameCounter % effectiveFrameSkip != 0) return;

    // Backpressure guard: drop frame if inference is still running.
    if (_inferenceBusy) return;

    _inferenceBusy = true;
    _runInference(frame);
  }

  /// Runs preprocessing + TFLite inference + NMS asynchronously.
  ///
  /// Heavy preprocessing (YUV→RGB → crop → resize) is handed off via
  /// [compute] so the UI thread is kept free.  TFLite with a GPU/CoreML
  /// delegate handles its own thread pool internally.
  Future<void> _runInference(CameraImage frame) async {
    final startedAt = DateTime.now().millisecondsSinceEpoch;
    try {
      // detect() serialises the frame, offloads YUV→RGB / crop / resize /
      // normalise via compute() to a background isolate, then runs TFLite
      // inference on the main isolate (required by the GPU delegate).
      final settings = _ref.read(settingsProvider).valueOrNull;
      final detections = await _useCase(
        frame,
        confidenceThreshold: settings?.confidenceThreshold,
        maxDetections: settings?.maxDetections,
        preprocessSize: settings?.modelInputSize.pixels,
      ).timeout(const Duration(milliseconds: 750));

      final cycleElapsedMs = DateTime.now().millisecondsSinceEpoch - startedAt;
      final modelLatencyMs =
          _ref.read(modelDataSourceProvider).lastInferenceLatencyMs;
      final baseFrameSkip =
          settings?.realtimeFrameInterval.frames ?? AppConstants.frameSkip;

      if (settings?.adaptiveFrameSkipping ?? true) {
        _adaptFrameSkip(modelLatencyMs, settings?.realtimeFrameInterval.frames);
      } else {
        _dynamicFrameSkip = baseFrameSkip;
      }

      if (mounted) {
        final latency =
            modelLatencyMs > 0 ? modelLatencyMs : cycleElapsedMs.toDouble();
        final latencyChanged =
            (latency - state.inferenceLatencyMs).abs() >= 3.0;
        if (_detectionsChanged(detections, state.detections) ||
            latencyChanged) {
          state = state.copyWith(
            detections: detections,
            inferenceLatencyMs: latency,
          );
        }
      }
    } on TimeoutException {
      final settings = _ref.read(settingsProvider).valueOrNull;
      if (settings?.adaptiveFrameSkipping ?? true) {
        _adaptFrameSkip(1200, settings?.realtimeFrameInterval.frames);
      }
    } catch (_) {
      // Keep stream alive by swallowing transient inference failures.
    } finally {
      _inferenceBusy = false;
    }
  }

  void _adaptFrameSkip(double inferenceMs, int? baseSkipOverride) {
    final base = baseSkipOverride ?? AppConstants.frameSkip;
    if (inferenceMs >= 260) {
      _dynamicFrameSkip =
          (_dynamicFrameSkip + 1).clamp(base, _maxAdaptiveFrameSkip);
      return;
    }
    if (inferenceMs <= 140) {
      _dynamicFrameSkip =
          (_dynamicFrameSkip - 1).clamp(base, _maxAdaptiveFrameSkip);
    }
  }

  bool _detectionsChanged(List<Detection> next, List<Detection> current) {
    if (next.length != current.length) return true;
    for (var i = 0; i < next.length; i++) {
      if (next[i] != current[i]) return true;
    }
    return false;
  }

  // ── Dispose ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    stopDetecting();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final modelDataSourceProvider = Provider<ModelDataSource>((ref) {
  return ModelDataSource(
    modelAssetPath: AppConstants.realtimeDetectionModelAssetPath,
  );
});

final staticModelDataSourceProvider = Provider<ModelDataSource>((ref) {
  return ModelDataSource(
    modelAssetPath: AppConstants.staticDetectionModelAssetPath,
  );
});

/// Pre-warms the TFLite interpreter in the background.
///
/// [DetectionPage] watches this provider so the interpreter is loaded as
/// soon as the page is rendered — no UI blocking.
final modelInitProvider = FutureProvider<void>((ref) async {
  // Use ref.read — this is a one-shot initialisation. Using ref.watch here
  // would restart the Future (and abort mid-flight) if the provider is
  // ever invalidated, causing the "Loading AI…" badge to spin forever.
  final model = ref.read(modelDataSourceProvider);
  await model.initialise();
  ref.onDispose(model.dispose);
});

/// Initialises the static-image model (float32) on demand.
final staticModelInitProvider = FutureProvider<void>((ref) async {
  final model = ref.read(staticModelDataSourceProvider);
  await model.initialise();
  ref.onDispose(model.dispose);
});

final detectionRepositoryProvider = Provider((ref) {
  return DetectionRepositoryImpl(
    modelDataSource: ref.watch(modelDataSourceProvider),
    cameraDataSource: ref.watch(cameraDataSourceProvider),
  );
});

final runDetectionUseCaseProvider = Provider((ref) {
  return RunDetectionUseCase(ref.watch(detectionRepositoryProvider));
});

final staticDetectionRepositoryProvider = Provider((ref) {
  return DetectionRepositoryImpl(
    modelDataSource: ref.watch(staticModelDataSourceProvider),
    cameraDataSource: ref.watch(cameraDataSourceProvider),
  );
});

final staticRunDetectionUseCaseProvider = Provider((ref) {
  return RunDetectionUseCase(ref.watch(staticDetectionRepositoryProvider));
});

final detectionProvider =
    StateNotifierProvider<DetectionNotifier, DetectionState>((ref) {
  // Pass ref so the notifier can call cameraProvider.notifier methods.
  return DetectionNotifier(ref.watch(runDetectionUseCaseProvider), ref);
});
