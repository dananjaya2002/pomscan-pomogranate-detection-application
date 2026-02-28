/// Riverpod providers for the real-time detection pipeline.
///
/// [DetectionNotifier] owns the frame-to-detection lifecycle:
///   camera image stream → frame-skip throttle → async inference → NMS
///   → state update → UI rebuild.
///
/// FPS is computed with a rolling timestamp window over the last
/// [_kFpsWindow] processed frames, so it reflects current throughput
/// rather than a cumulative average that drifts lower over time.
library;

import 'dart:collection';

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
    this.fps = 0.0,
    this.isProcessing = false,
  });

  final List<Detection> detections;
  final double fps;
  final bool isProcessing;

  DetectionState copyWith({
    List<Detection>? detections,
    double? fps,
    bool? isProcessing,
  }) => DetectionState(
    detections: detections ?? this.detections,
    fps: fps ?? this.fps,
    isProcessing: isProcessing ?? this.isProcessing,
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

  /// Keeps the millisecond timestamps of the last [_kFpsWindow] processed
  /// frames.  FPS = (window_size − 1) / (newest_ts − oldest_ts) in seconds.
  final Queue<int> _frameTimestamps = Queue();

  /// Maximum number of timestamps to keep in the rolling window.
  static const int _kFpsWindow = 12;

  // ── Public API ──────────────────────────────────────────────────────────

  /// Subscribes to the camera image stream and starts the inference loop.
  ///
  /// Safe to call multiple times — a running stream is stopped first.
  Future<void> startDetecting() async {
    await stopDetecting();
    _frameCounter = 0;
    _frameTimestamps.clear();
    await _ref.read(cameraProvider.notifier).startImageStream(_onFrame);
  }

  /// Stops the image stream and clears stale detections.
  ///
  /// Safe to call when the stream is not running.
  Future<void> stopDetecting() async {
    _frameTimestamps.clear();
    try {
      await _ref.read(cameraProvider.notifier).stopImageStream();
    } catch (_) {
      // Stream may not be active — ignore.
    }
    if (mounted) {
      state = state.copyWith(detections: [], isProcessing: false);
    }
  }

  // ── Frame callback ───────────────────────────────────────────────────────

  /// Called on every raw camera frame (main thread, high frequency).
  void _onFrame(CameraImage frame) {
    // Throttle: only process every Nth frame.
    // Use settings-driven frame-skip when available, otherwise fall back.
    final settings = _ref.read(settingsProvider).valueOrNull;
    final frameSkip =
        settings?.performanceMode.frameSkip ?? AppConstants.frameSkip;
    _frameCounter++;
    if (_frameCounter % frameSkip != 0) return;

    // Backpressure guard: drop frame if inference is still running.
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true);
    _runInference(frame);
  }

  /// Runs preprocessing + TFLite inference + NMS asynchronously.
  ///
  /// Heavy preprocessing (YUV→RGB → crop → resize) is handed off via
  /// [compute] so the UI thread is kept free.  TFLite with a GPU/CoreML
  /// delegate handles its own thread pool internally.
  Future<void> _runInference(CameraImage frame) async {
    try {
      // detect() serialises the frame, offloads YUV→RGB / crop / resize /
      // normalise via compute() to a background isolate, then runs TFLite
      // inference on the main isolate (required by the GPU delegate).
      final settings = _ref.read(settingsProvider).valueOrNull;
      final detections = await _useCase(
        frame,
        confidenceThreshold: settings?.confidenceThreshold,
        maxDetections: settings?.maxDetections,
      );

      // Rolling-window FPS—record this frame's timestamp.
      final now = DateTime.now().millisecondsSinceEpoch;
      _frameTimestamps.addLast(now);
      if (_frameTimestamps.length > _kFpsWindow) _frameTimestamps.removeFirst();

      double fps = state.fps;
      if (_frameTimestamps.length >= 2) {
        final elapsedSec =
            (_frameTimestamps.last - _frameTimestamps.first) / 1000.0;
        if (elapsedSec > 0) {
          fps = (_frameTimestamps.length - 1) / elapsedSec;
        }
      }

      if (mounted) {
        state = state.copyWith(
          detections: detections,
          fps: fps,
          isProcessing: false,
        );
      }
    } catch (_) {
      if (mounted) state = state.copyWith(isProcessing: false);
    }
  }

  // ── Dispose ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    stopDetecting();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final modelDataSourceProvider = Provider<ModelDataSource>(
  (ref) => ModelDataSource(),
);

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

final detectionRepositoryProvider = Provider((ref) {
  return DetectionRepositoryImpl(
    modelDataSource: ref.watch(modelDataSourceProvider),
    cameraDataSource: ref.watch(cameraDataSourceProvider),
  );
});

final runDetectionUseCaseProvider = Provider((ref) {
  return RunDetectionUseCase(ref.watch(detectionRepositoryProvider));
});

final detectionProvider =
    StateNotifierProvider<DetectionNotifier, DetectionState>((ref) {
      // Pass ref so the notifier can call cameraProvider.notifier methods.
      return DetectionNotifier(ref.watch(runDetectionUseCaseProvider), ref);
    });
