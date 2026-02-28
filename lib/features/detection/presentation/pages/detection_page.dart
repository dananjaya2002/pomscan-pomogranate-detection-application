/// Root detection screen.
///
/// Composes the camera preview, bounding-box overlay, FPS counter,
/// and a bottom control bar in a full-screen [Stack].
///
/// Detection lifecycle:
///   - Both [modelInitProvider] AND [cameraProvider] must be ready before the
///     image stream starts.  [ref.listen] on each triggers [_tryStartDetection].
///   - App backgrounded → stream stopped; foregrounded → stream restarted.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/camera_provider.dart';
import '../providers/detection_provider.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../widgets/bbox_overlay.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/detection_dashboard.dart';
import '../widgets/fps_counter.dart';

/// Main page of the application.
///
/// Layout (bottom → top):
///   0. [CameraPreviewWidget]   — full-screen live feed
///   1. [BBoxOverlay]           — transparent detection overlay
///   2. [FpsCounter]            — FPS badge (top-right)
///   3. Bottom control bar      — torch toggle & info
final class DetectionPage extends ConsumerStatefulWidget {
  const DetectionPage({super.key});

  @override
  ConsumerState<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends ConsumerState<DetectionPage>
    with WidgetsBindingObserver {
  bool _torchOn = false;

  /// Set to true once [modelInitProvider] completes successfully.
  bool _modelReady = false;

  /// Set to true once [startDetecting] has been called, to prevent double-starts.
  bool _streamStarted = false;

  /// Tracks the last applied camera quality so re-init is only triggered on
  /// an actual change, not on every settings rebuild.
  CameraQuality? _lastCameraQuality;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Lock to portrait for consistent coordinate-to-screen mapping.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Explicitly start the camera now that the user navigated to this screen.
    Future.microtask(() => ref.read(cameraProvider.notifier).initialise());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── App lifecycle ──────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final cameraNotifier = ref.read(cameraProvider.notifier);
    switch (lifecycleState) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _tryStopDetection();
        cameraNotifier.pauseCamera();
      case AppLifecycleState.resumed:
        cameraNotifier.resumeCamera();
      // Stream restart is handled by the cameraProvider listener in build().
      case AppLifecycleState.detached:
        break;
    }
  }

  // ── Detection stream helpers ───────────────────────────────────────────────

  /// Starts the detection stream if both the model and camera are ready.
  void _tryStartDetection() {
    if (!_modelReady) return;
    if (_streamStarted) return;
    final camState = ref.read(cameraProvider);
    if (camState is! CameraReady) return;
    _streamStarted = true;
    ref.read(detectionProvider.notifier).startDetecting();
  }

  /// Stops the detection stream and resets the started flag.
  void _tryStopDetection() {
    if (!_streamStarted) return;
    _streamStarted = false;
    ref.read(detectionProvider.notifier).stopDetecting();
  }

  // ── Torch ──────────────────────────────────────────────────────────────────

  Future<void> _toggleTorch() async {
    final next = !_torchOn;
    await ref.read(cameraProvider.notifier).setTorch(enabled: next);
    if (mounted) setState(() => _torchOn = next);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ── Model readiness ─────────────────────────────────────────────────────
    // Derive badge state directly from the watched AsyncValue so the UI is
    // always correct regardless of when the FutureProvider resolves relative
    // to the first build call (avoids ref.listen race conditions).
    final modelState = ref.watch(modelInitProvider);
    final modelLoaded = !modelState.isLoading;
    final modelError  = modelState.hasError;

    // Side effect only: flip _modelReady and start the inference stream once
    // the model successfully loads. We use ref.listen here for the async
    // side-effect (not for deriving UI state).
    ref.listen<AsyncValue<void>>(modelInitProvider, (_, next) {
      if (next is AsyncData && !_modelReady) {
        _modelReady = true;
        _tryStartDetection();
      }
    });

    // Edge-case guard: if modelInitProvider was already AsyncData when this
    // build ran (first build after returning from background, etc.) but the
    // listener above hasn't fired yet, ensure detection is started anyway.
    if (modelState is AsyncData && !_modelReady) {
      _modelReady = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryStartDetection());
    }

    // ── Camera state listener ───────────────────────────────────────────────
    // Start the inference stream when the camera becomes ready.
    // Reset the started flag when the camera goes offline.
    ref.listen<CameraState>(cameraProvider, (prev, next) {
      if (next is CameraReady) {
        // Camera (re-)became ready — allow a new stream to start.
        _streamStarted = false;
        _tryStartDetection();
      } else {
        _tryStopDetection();
      }
    });

    // ── Settings listener (camera quality) ────────────────────────────────
    // When the user changes camera quality in Settings, dispose the current
    // CameraController and re-initialise at the new resolution.
    ref.listen<AsyncValue<AppSettings>>(settingsProvider, (prev, next) {
      final newQuality = next.valueOrNull?.cameraQuality;
      if (newQuality == null) return;
      // First settings load: record the quality that was actually persisted.
      // If the user had saved a quality other than the medium default used by
      // the initial camera init, reinitialise the camera at the correct level.
      if (_lastCameraQuality == null) {
        _lastCameraQuality = newQuality;
        if (newQuality != CameraQuality.medium) {
          _tryStopDetection();
          Future.microtask(
            () => ref.read(cameraProvider.notifier).reinitialise(),
          );
        }
        return;
      }
      if (newQuality != _lastCameraQuality) {
        _lastCameraQuality = newQuality;
        _tryStopDetection();
        Future.microtask(
          () => ref.read(cameraProvider.notifier).reinitialise(),
        );
      }
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _tryStopDetection();
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 0: Live camera feed
            const CameraPreviewWidget(),

            // Layer 1: YOLO bounding-box overlay
            const BBoxOverlay(),

            // Layer 2: FPS counter badge (top-left)
            const FpsCounter(),

            // Layer 3: Model status badge (top-right)
            _ModelStatusBadge(loaded: modelLoaded, error: modelError),

            // Layer 4: Back button (top-left, above FPS)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black45,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),

            // Layer 5: Dashboard panel (bottom)
            DetectionDashboard(torchOn: _torchOn, onTorchToggle: _toggleTorch),
          ],
        ),
      ),
    );
  }
}

// ── Model status badge ────────────────────────────────────────────────────────

/// Small top-right pill that shows "AI Ready" once the TFLite interpreter
/// finishes loading, "AI Error" if loading failed, and "Loading AI…" with a
/// spinner beforehand.
class _ModelStatusBadge extends StatelessWidget {
  const _ModelStatusBadge({required this.loaded, this.error = false});
  final bool loaded;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12.0,
      right: 12.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(153),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                error
                    ? const Color(0xFFF44336).withAlpha(200)
                    : loaded
                    ? const Color(0xFF4CAF50).withAlpha(160)
                    : Colors.white.withAlpha(40),
            width: 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!loaded)
              const SizedBox(
                width: 9,
                height: 9,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                ),
              )
            else if (error)
              const Icon(
                Icons.error_outline_rounded,
                size: 11,
                color: Color(0xFFF44336),
              )
            else
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 11,
                color: Color(0xFF4CAF50),
              ),
            const SizedBox(width: 5),
            Text(
              error ? 'AI Error' : loaded ? 'AI Ready' : 'Loading AI…',
              style: TextStyle(
                color:
                    error
                        ? const Color(0xFFF44336)
                        : loaded
                        ? const Color(0xFF4CAF50)
                        : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
