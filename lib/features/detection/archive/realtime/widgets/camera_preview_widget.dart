/// Camera preview widget — renders the live [CameraController] feed.
library;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/camera_provider.dart';

/// Renders the live camera feed, scaled to fill the screen with correct
/// aspect ratio, or an appropriate placeholder for each [CameraState].
final class CameraPreviewWidget extends ConsumerWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);

    return switch (cameraState) {
      CameraInitializing() => const _LoadingView(),
      CameraReady(:final controller) => _LivePreview(controller: controller),
      CameraPermissionDenied() => const _PermissionDeniedView(),
      CameraError(:final message) => _ErrorView(message: message),
    };
  }
}

// ── Live preview ──────────────────────────────────────────────────────────────

class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    // CameraPreview pads letterboxes internally; we want it to fill the screen.
    // OverflowBox + FittedBox let us clip the preview to fill without distortion.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double rawAspect = controller.value.aspectRatio;
        final double previewAspect =
            rawAspect > 1.0 ? 1.0 / rawAspect : rawAspect;
        final double screenAspect =
            constraints.maxWidth / constraints.maxHeight;

        double scale;
        if (previewAspect < screenAspect) {
          // Preview is narrower than screen — scale by width
          scale = screenAspect / previewAspect;
        } else {
          // Preview is wider — scale by height
          scale = previewAspect / screenAspect;
        }

        return ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(controller)),
          ),
        );
      },
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initialising camera…',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
}

// ── Permission denied ─────────────────────────────────────────────────────────

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white38,
                  size: 64,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Camera permission required',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Grant camera access in Settings to start\npomegranate ripeness detection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: openAppSettings,
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ColoredBox(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Camera Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(cameraProvider.notifier).initialise(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
}
