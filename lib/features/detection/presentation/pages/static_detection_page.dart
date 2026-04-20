import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/detection.dart';
import '../providers/detection_provider.dart';

class StaticDetectionPage extends ConsumerStatefulWidget {
  const StaticDetectionPage({super.key});

  @override
  ConsumerState<StaticDetectionPage> createState() =>
      _StaticDetectionPageState();
}

class _StaticDetectionPageState extends ConsumerState<StaticDetectionPage> {
  File? _image;
  List<Detection>? _detections;
  bool _isProcessing = false;
  bool _isLoadingModel = false;
  Size? _imageNaturalSize;
  String? _resultMessage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _detections = null; // Reset detections on new image
        _imageNaturalSize = null;
        _resultMessage = null;
      });
      _runDetection();
    }
  }

  Future<void> _runDetection() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
      _resultMessage = null;
    });

    try {
      final bytes = await _image!.readAsBytes();
      if (bytes.isEmpty) {
        throw StateError('Selected image is empty. Please choose another one.');
      }

      // Decode image to get dimensions for inference
      final decodedImage = await decodeImageFromList(bytes);
      if (decodedImage.width <= 0 || decodedImage.height <= 0) {
        throw StateError('Could not decode image dimensions.');
      }
      final naturalSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );

      if (mounted) {
        setState(() {
          _isLoadingModel = true;
        });
      }
      await ref.read(staticModelInitProvider.future);
      if (!mounted) return;
      setState(() {
        _isLoadingModel = false;
      });

      final useCase = ref.read(staticRunDetectionUseCaseProvider);

      final results = await useCase.callStatic(
        bytes,
        decodedImage.width,
        decodedImage.height,
      );

      if (mounted) {
        setState(() {
          _detections = results;
          _imageNaturalSize = naturalSize;
          _isProcessing = false;
          _resultMessage =
              results.isEmpty ? 'No fruit detected in this image.' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isLoadingModel = false;
        });
        final error = '$e'.toLowerCase();
        final message = error.contains('could not decode image') ||
                error.contains('selected image is empty')
            ? 'Image could not be processed. Please use a valid JPG or PNG image.'
            : error.contains('shape mismatch') || error.contains('tensor')
                ? 'Model tensor mismatch. Please verify the selected detection model export.'
                : 'Detection failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Image Detection (Float32)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _image == null
                  ? const Text('No image selected.')
                  : Stack(
                      fit: StackFit.loose,
                      children: [
                        Image.file(_image!),
                        if (_detections != null && _imageNaturalSize != null)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _StaticBBoxPainter(
                                _detections!,
                                _imageNaturalSize!,
                              ),
                            ),
                          ),
                        if (_isProcessing)
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                        if (_isLoadingModel)
                          const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text('Loading Float32 model...'),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          if (_resultMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _resultMessage!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticBBoxPainter extends CustomPainter {
  const _StaticBBoxPainter(this.detections, this.naturalImageSize);
  final List<Detection> detections;

  /// The original pixel dimensions of the decoded image.
  /// Used to correctly map normalised model coordinates to the
  /// letterboxed/pillarboxed image rect rendered inside the canvas.
  final Size naturalImageSize;

  static const double _strokeWidth = 2.5;
  static const double _cornerLen = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Compute the actual image rect within the canvas.
    // Image.file uses BoxFit.contain by default, so the rendered image may
    // have horizontal or vertical letterbox bars.
    final FittedSizes fitted =
        applyBoxFit(BoxFit.contain, naturalImageSize, size);
    final double offsetX = (size.width - fitted.destination.width) / 2;
    final double offsetY = (size.height - fitted.destination.height) / 2;
    final double imgW = fitted.destination.width;
    final double imgH = fitted.destination.height;

    for (final detection in detections) {
      final box = detection.box;

      // Map normalised [0,1] model coords to the rendered image rect.
      final rect = Rect.fromLTRB(
        offsetX + box.x1 * imgW,
        offsetY + box.y1 * imgH,
        offsetX + box.x2 * imgW,
        offsetY + box.y2 * imgH,
      );

      final color = AppConstants.classColors[detection.label] ?? Colors.red;

      _drawBox(canvas, size, rect, detection, color);
    }
  }

  void _drawBox(
    Canvas canvas,
    Size canvasSize,
    Rect rect,
    Detection detection,
    Color color,
  ) {
    // ── Subtle semi-transparent fill ────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = color.withAlpha(22),
    );

    // ── Full rounded-rect border ────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = color.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ── Corner accent brackets ──────────────────────────────────────────
    final Paint bracketPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.square;

    final double cl =
        _cornerLen.clamp(12.0, 30.0).clamp(0.0, rect.width * 0.35);
    final double cs = cl.clamp(0.0, rect.height * 0.35);

    canvas
      // Top-left
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

    // ── Label pill ──────────────────────────────────────────────────────
    _drawLabel(canvas, canvasSize, rect, detection, color);
  }

  void _drawLabel(
    Canvas canvas,
    Size canvasSize,
    Rect rect,
    Detection detection,
    Color color,
  ) {
    final String rawLabel = detection.label.replaceAll('_', '-');
    final String displayLabel =
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
    final double pillX = rect.left.clamp(0.0, canvasSize.width - pillW);
    final double pillTop = (rect.top - pillH - 2.0).clamp(0.0, double.infinity);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pillX, pillTop, pillW, pillH),
        const Radius.circular(radius),
      ),
      Paint()..color = color.withAlpha(220),
    );

    tp.paint(canvas, Offset(pillX + padding, pillTop + padding));
  }

  @override
  bool shouldRepaint(_StaticBBoxPainter old) =>
      old.detections != detections || old.naturalImageSize != naturalImageSize;
}
