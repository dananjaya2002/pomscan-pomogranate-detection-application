/// Camera data source — manages [CameraController] lifecycle and frame streaming.
library;

import 'package:camera/camera.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/failures.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Provides access to the rear camera and exposes a raw [CameraImage] stream.
///
/// Responsibilities:
///  - Discover the first back-facing camera via [availableCameras].
///  - Manage the [CameraController] lifecycle (init / pause / resume / dispose).
///  - Start / stop the YUV frame stream consumed by the inference pipeline.
final class CameraDataSource {
  CameraDataSource();

  CameraController? _controller;
  bool _streamActive = false;

  // ── Public API ────────────────────────────────────────────────────────────

  /// `true` after [initialise] completes successfully.
  bool get isInitialised => _controller?.value.isInitialized ?? false;

  /// The underlying [CameraController] — only valid after [initialise].
  /// Throws [StateError] if called before initialisation.
  CameraController get controller {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw StateError(
        'CameraDataSource not initialised. Call initialise() first.',
      );
    }
    return _controller!;
  }

  /// Discovers and initialises the first back-facing camera.
  ///
  /// [resolution] defaults to [ResolutionPreset.medium] (640×480 on most
  /// devices), which closely matches the model’s 640-px input size and avoids
  /// the overhead of downscaling large frames in software.  Pass a different
  /// preset from the user’s [AppSettings.cameraQuality] to honour the setting.
  ///
  /// Throws [CameraFailure] if no back camera is found or initialisation fails.
  Future<void> initialise({
    ResolutionPreset resolution = ResolutionPreset.medium,
  }) async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        resolution,
        // Disable audio — we only need video frames for inference.
        enableAudio: false,
        // Request YUV420_888 on Android (default); BGRA8888 on iOS (default).
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      // Disable auto-flash to avoid inference colour shifts.
      await _controller!.setFlashMode(FlashMode.off);
      _log.i('Camera initialised: ${backCamera.name}');
    } on CameraException catch (e) {
      throw CameraFailure('Camera init failed: ${e.description}');
    } catch (e) {
      throw CameraFailure('Unexpected camera error: $e');
    }
  }

  /// Registers [callback] to receive every raw [CameraImage] frame.
  ///
  /// Safe to call only after [initialise]. Does nothing if the stream is
  /// already active.
  Future<void> startImageStream(
    void Function(CameraImage image) callback,
  ) async {
    if (!isInitialised) {
      _log.w('startImageStream called before initialise — ignoring.');
      return;
    }
    if (_streamActive) return;

    await _controller!.startImageStream(callback);
    _streamActive = true;
    _log.d('Image stream started');
  }

  /// Stops the frame stream without disposing the controller.
  ///
  /// The camera preview continues to render; inference is simply paused.
  Future<void> stopImageStream() async {
    if (!_streamActive || _controller == null) return;
    try {
      await _controller!.stopImageStream();
    } catch (_) {
      // Swallow — controller may already be in a stopped state.
    }
    _streamActive = false;
    _log.d('Image stream stopped');
  }

  /// Pauses the camera preview (called on app background).
  Future<void> pausePreview() async {
    if (!isInitialised) return;
    try {
      await stopImageStream();
      await _controller!.pausePreview();
      _log.d('Camera preview paused');
    } catch (e) {
      _log.w('pausePreview error: $e');
    }
  }

  /// Resumes the camera preview (called on app foreground).
  Future<void> resumePreview() async {
    if (!isInitialised) return;
    try {
      await _controller!.resumePreview();
      _log.d('Camera preview resumed');
    } catch (e) {
      _log.w('resumePreview error: $e');
    }
  }

  /// Toggles the device torch.
  Future<void> setTorchMode({required bool enabled}) async {
    if (!isInitialised) return;
    try {
      await _controller!.setFlashMode(
        enabled ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      _log.w('setTorchMode error: $e');
    }
  }

  /// Fully disposes the camera controller and releases hardware resources.
  Future<void> dispose() async {
    _streamActive = false;
    await _controller?.dispose();
    _controller = null;
    _log.d('CameraDataSource disposed');
  }
}
