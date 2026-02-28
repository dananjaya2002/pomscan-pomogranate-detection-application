/// Bounding box overlay — renders detection results as a 2-D overlay.
///
/// Coordinates are correctly mapped from YOLO model space ([0,1]) to screen
/// pixels using [BoxTransformer], which accounts for the camera aspect ratio
/// and the centre-crop square used during preprocessing.
///
/// Boxes are drawn as four corner L-brackets rather than a full rectangle
/// for a cleaner look when multiple detections overlap.
library;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/box_transform.dart';
import '../../domain/entities/detection.dart';
import '../providers/camera_provider.dart';
import '../providers/detection_provider.dart';

/// Transparent overlay that draws [Detection] bounding boxes and labels.
///
/// Uses [RepaintBoundary] to isolate repaints from the camera preview layer,
/// and [IgnorePointer] so touches pass through to the camera widget below.
final class BBoxOverlay extends ConsumerWidget {
  const BBoxOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detections = ref.watch(detectionProvider.select((s) => s.detections));

    final double? aspectRatio = switch (ref.watch(cameraProvider)) {
      CameraReady(:final CameraController controller) =>
        controller.value.aspectRatio,
      _ => null,
    };

    if (aspectRatio == null || detections.isEmpty) {
      return const SizedBox.expand();
    }

    return RepaintBoundary(
      child: IgnorePointer(
        child: SizedBox.expand(
          child: CustomPaint(
            painter: _BBoxPainter(
              detections: detections,
              previewAspectRatio: aspectRatio,
            ),
          ),
        ),
      ),
    );
  }
}

// ── CustomPainter ─────────────────────────────────────────────────────────────

class _BBoxPainter extends CustomPainter {
  _BBoxPainter({
    required this.detections,
    required this.previewAspectRatio,
  });

  final List<Detection> detections;
  final double previewAspectRatio;

  /// Length of each corner L-bracket arm in logical pixels.
  static const double _cornerLen = 20.0;
  static const double _strokeWidth = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    for (final detection in detections) {
      _drawDetection(canvas, size, detection);
    }
  }

  void _drawDetection(Canvas canvas, Size size, Detection detection) {
    final Color color =
        AppConstants.classColors[detection.label] ?? Colors.white;

    final Rect rect = BoxTransformer.toScreenRect(
      detection.box,
      previewAspectRatio,
      size,
    );

    // ── Corner brackets ───────────────────────────────────────────────────
    final Paint bracketPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.square;

    final double cl = _cornerLen.clamp(0.0, rect.width * 0.35);
    final double cs = cl.clamp(0.0, rect.height * 0.35);

    // Top-left
    canvas
      ..drawLine(rect.topLeft, rect.topLeft.translate(cl, 0), bracketPaint)
      ..drawLine(rect.topLeft, rect.topLeft.translate(0, cs), bracketPaint)
      // Top-right
      ..drawLine(rect.topRight, rect.topRight.translate(-cl, 0), bracketPaint)
      ..drawLine(rect.topRight, rect.topRight.translate(0, cs), bracketPaint)
      // Bottom-left
      ..drawLine(
          rect.bottomLeft, rect.bottomLeft.translate(cl, 0), bracketPaint)
      ..drawLine(
          rect.bottomLeft, rect.bottomLeft.translate(0, -cs), bracketPaint)
      // Bottom-right
      ..drawLine(
          rect.bottomRight, rect.bottomRight.translate(-cl, 0), bracketPaint)
      ..drawLine(
          rect.bottomRight, rect.bottomRight.translate(0, -cs), bracketPaint);

    // Subtle semi-transparent fill inside the box
    canvas.drawRect(
      rect,
      Paint()..color = color.withAlpha(18),
    );

    // ── Label pill ─────────────────────────────────────────────────────────
    _drawLabel(canvas, size, rect, detection, color);
  }

  void _drawLabel(
    Canvas canvas,
    Size canvasSize,
    Rect rect,
    Detection detection,
    Color color,
  ) {
    // Format: "Ripe 92%" — capitalise first letter and merge with confidence
    final rawLabel = detection.label.replaceAll('_', '-');
    final displayLabel =
        rawLabel[0].toUpperCase() + rawLabel.substring(1);
    final String text = '$displayLabel  ${detection.confidencePercent}';

    const double padding = 5.0;
    const double radius = 5.0;
    const double fontSize = 11.5;

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double pillW = tp.width + padding * 2;
    final double pillH = tp.height + padding * 2;

    // Position pill above the box; clamp so it doesn't go off-canvas.
    final double pillX = rect.left.clamp(0.0, canvasSize.width - pillW);
    final double pillTop = (rect.top - pillH - 2.0).clamp(0.0, double.infinity);

    // Pill background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pillX, pillTop, pillW, pillH),
        const Radius.circular(radius),
      ),
      Paint()..color = color.withAlpha(220),
    );

    // Label text
    tp.paint(canvas, Offset(pillX + padding, pillTop + padding));
  }

  @override
  bool shouldRepaint(_BBoxPainter old) =>
      old.detections != detections ||
      old.previewAspectRatio != previewAspectRatio;
}
