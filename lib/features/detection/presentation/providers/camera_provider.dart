/// Riverpod providers for camera state.
library;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/errors/failures.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/datasources/camera_datasource.dart';

// ── State ────────────────────────────────────────────────────────────────────

@immutable
sealed class CameraState {
  const CameraState();
}

final class CameraInitializing extends CameraState {
  const CameraInitializing();
}

/// Camera is ready and the [CameraController] is available for preview.
final class CameraReady extends CameraState {
  const CameraReady(this.controller);
  final CameraController controller;
}

/// Camera permission was denied by the user.
final class CameraPermissionDenied extends CameraState {
  const CameraPermissionDenied();
}

/// An unexpected error occurred during camera setup.
final class CameraError extends CameraState {
  const CameraError(this.message);
  final String message;
}

// ── Notifier ─────────────────────────────────────────────────────────────────

/// Manages the full camera lifecycle:
///   1. Request [Permission.camera] at runtime.
///   2. Delegate to [CameraDataSource] for hardware init.
///   3. Expose [CameraReady] with the live [CameraController].
///   4. Pause / resume the preview on app lifecycle changes.
///   5. Toggle the torch.
final class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier(this._dataSource, this._ref) : super(const CameraInitializing());

  final CameraDataSource _dataSource;
  final Ref _ref;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Requests camera permission, then initialises the hardware camera.
  /// Emits the appropriate [CameraState] when done.
  Future<void> initialise() async {
    state = const CameraInitializing();

    try {
      // 1. Runtime permission
      final status = await Permission.camera.request();

      if (status.isPermanentlyDenied) {
        await openAppSettings();
        state = const CameraPermissionDenied();
        return;
      }

      if (!status.isGranted) {
        state = const CameraPermissionDenied();
        return;
      }

      // 2. Read the user’s chosen camera quality and pass it to the datasource
      //    so the CameraController is created at the correct resolution.
      final settings = _ref.read(settingsProvider).valueOrNull;
      final resolution = settings?.cameraQuality.preset ?? ResolutionPreset.high;

      // 3. Hardware init
      await _dataSource.initialise(resolution: resolution);
      state = CameraReady(_dataSource.controller);
    } on CameraFailure catch (e) {
      state = CameraError(e.message);
    } catch (e) {
      state = CameraError('Unexpected error: $e');
    }
  }

  /// Disposes the current camera controller and re-initialises with the
  /// latest settings (e.g. after the user changes [CameraQuality]).
  Future<void> reinitialise() async {
    await _dataSource.dispose();
    await initialise();
  }

  /// Pauses the camera when the app goes to background.
  Future<void> pauseCamera() async {
    await _dataSource.pausePreview();
  }

  /// Resumes the camera when the app returns to foreground.
  Future<void> resumeCamera() async {
    if (!_dataSource.isInitialised) {
      // Re-initialise if the OS fully released the camera.
      await initialise();
    } else {
      await _dataSource.resumePreview();
    }
    // Refresh the state so the preview widget re-attaches.
    if (_dataSource.isInitialised) {
      state = CameraReady(_dataSource.controller);
    }
  }

  // ── Controls ──────────────────────────────────────────────────────────────

  /// Toggles the device torch.
  Future<void> setTorch({required bool enabled}) =>
      _dataSource.setTorchMode(enabled: enabled);

  /// Starts raw frame streaming. The [callback] is called for every YUV frame.
  Future<void> startImageStream(void Function(CameraImage) callback) =>
      _dataSource.startImageStream(callback);

  /// Stops the raw frame stream (preview continues).
  Future<void> stopImageStream() => _dataSource.stopImageStream();

  @override
  void dispose() {
    _dataSource.dispose();
    super.dispose();
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

final cameraDataSourceProvider = Provider<CameraDataSource>(
  (ref) => CameraDataSource(),
);

final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>(
  (ref) {
    final dataSource = ref.watch(cameraDataSourceProvider);
    // Camera is NOT auto-initiated. DetectionPage.initState() must call
    // ref.read(cameraProvider.notifier).initialise() explicitly so the
    // camera only opens when the user navigates to the scan screen.
    return CameraNotifier(dataSource, ref);
  },
);
