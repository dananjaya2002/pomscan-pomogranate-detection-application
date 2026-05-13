import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../info/domain/entities/info_item.dart';
import '../../../../core/constants/farmer_strings.dart';
import '../../../../core/widgets/visibility_widgets.dart';
import '../../../info/presentation/pages/info_list_page.dart';
import '../../domain/entities/detection.dart';
import '../providers/static_detection_provider.dart';

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

  int get _ripeCount =>
      _detections?.where((d) => d.label == 'ripe').length ?? 0;
  int get _semiRipeCount =>
      _detections?.where((d) => d.label == 'semi_ripe').length ?? 0;
  int get _unripeCount =>
      _detections?.where((d) => d.label == 'unripe').length ?? 0;
  bool get _hasRipeDetections => _ripeCount > 0;

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
            ? FarmerStrings.errorImageInvalid
            : error.contains('shape mismatch') || error.contains('tensor')
              ? FarmerStrings.errorProcessing
              : error.contains('out of memory')
                ? FarmerStrings.errorOutOfMemory
                : FarmerStrings.errorGeneral;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  void _openHarvestingGuide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const InfoListPage(type: InfoType.harvesting),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text(FarmerStrings.ripeScanTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Text(
                    FarmerStrings.ripeScanDescription,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  color: AppColors.surfaceVariant,
                  constraints: const BoxConstraints(minHeight: 260),
                  child: Center(
                    child: _image == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 50),
                            child: Text(
                                '📸 Pick a photo to start scanning',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Stack(
                            fit: StackFit.loose,
                            children: [
                              Image.file(_image!),
                              if (_detections != null &&
                                  _imageNaturalSize != null)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _StaticBBoxPainter(
                                      _detections!,
                                      _imageNaturalSize!,
                                    ),
                                  ),
                                ),
                              if (_isProcessing)
                                  Positioned.fill(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: ProcessingStatusOverlay(
                                          status: 'processing',
                                          statusTitle: FarmerStrings.statusAnalyzing,
                                          description: FarmerStrings.tipAnalysisTime,
                                        ),
                                      ),
                                    ),
                                  ),
                              if (_isLoadingModel)
                                  Positioned.fill(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: ProcessingStatusOverlay(
                                          status: 'loading',
                                          statusTitle: FarmerStrings.statusLoading,
                                          description: FarmerStrings.tipAnalysisTime,
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_detections != null && _detections!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          FarmerStrings.resultsTitle,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(
                            label: 'Ripe',
                            count: _ripeCount,
                            color: AppColors.ripe,
                          ),
                          _StatusChip(
                            label: 'Semi-ripe',
                            count: _semiRipeCount,
                            color: AppColors.semiRipe,
                          ),
                          _StatusChip(
                            label: 'Unripe',
                            count: _unripeCount,
                            color: AppColors.unripe,
                          ),
                        ],
                      ),
                      if (_hasRipeDetections) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openHarvestingGuide,
                            icon: const Icon(Icons.menu_book_rounded),
                              label: const Text(FarmerStrings.viewTreatmentGuide),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.harvestingAccent,
                              side: const BorderSide(
                                color: AppColors.harvestingAccent,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (_resultMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _resultMessage!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(FarmerStrings.takePhotoButton),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text(FarmerStrings.selectImageButton),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(130)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
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

  static const double _strokeWidth = 3.6;
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
      final rawRect = Rect.fromLTRB(
        offsetX + box.x1 * imgW,
        offsetY + box.y1 * imgH,
        offsetX + box.x2 * imgW,
        offsetY + box.y2 * imgH,
      );

      final rect = Rect.fromLTRB(
        rawRect.left.clamp(0.0, size.width),
        rawRect.top.clamp(0.0, size.height),
        rawRect.right.clamp(0.0, size.width),
        rawRect.bottom.clamp(0.0, size.height),
      );
      if (rect.width <= 1.0 || rect.height <= 1.0) continue;

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
    const edgeEpsilon = 2.0;
    final isNearFullImage = rect.left <= edgeEpsilon &&
        rect.top <= edgeEpsilon &&
        rect.right >= canvasSize.width - edgeEpsilon &&
        rect.bottom >= canvasSize.height - edgeEpsilon;

    final borderStroke = isNearFullImage ? 3.8 : 2.6;
    final borderAlpha = isNearFullImage ? 255 : 240;

    // ── Stronger semi-transparent fill for visibility ───────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = color.withAlpha(36),
    );

    // ── Dark outline below color stroke for better contrast on bright images
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = Colors.black.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderStroke + 1.6,
    );

    // ── Full rounded-rect border ────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = color.withAlpha(borderAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderStroke,
    );

    if (isNearFullImage && rect.width > 6.0 && rect.height > 6.0) {
      final inset = rect.deflate(1.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(inset, const Radius.circular(6)),
        Paint()
          ..color = color.withAlpha(220)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // ── Corner accent brackets ──────────────────────────────────────────
    final Paint bracketPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.square;
    final Paint bracketShadowPaint = Paint()
      ..color = Colors.black.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth + 1.2
      ..strokeCap = StrokeCap.square;

    final double cl =
        _cornerLen.clamp(12.0, 30.0).clamp(0.0, rect.width * 0.35);
    final double cs = cl.clamp(0.0, rect.height * 0.35);

    canvas
      // Top-left shadow
      ..drawLine(
          rect.topLeft, rect.topLeft.translate(cl, 0), bracketShadowPaint)
      ..drawLine(
          rect.topLeft, rect.topLeft.translate(0, cs), bracketShadowPaint)
      // Top-right shadow
      ..drawLine(
          rect.topRight, rect.topRight.translate(-cl, 0), bracketShadowPaint)
      ..drawLine(
          rect.topRight, rect.topRight.translate(0, cs), bracketShadowPaint)
      // Bottom-left shadow
      ..drawLine(
          rect.bottomLeft, rect.bottomLeft.translate(cl, 0), bracketShadowPaint)
      ..drawLine(rect.bottomLeft, rect.bottomLeft.translate(0, -cs),
          bracketShadowPaint)
      // Bottom-right shadow
      ..drawLine(rect.bottomRight, rect.bottomRight.translate(-cl, 0),
          bracketShadowPaint)
      ..drawLine(rect.bottomRight, rect.bottomRight.translate(0, -cs),
          bracketShadowPaint)
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

    const double padding = 6.0;
    const double radius = 5.0;
    const double fontSize = 12.2;

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
    final double maxX = (canvasSize.width - pillW).clamp(0.0, double.infinity);
    final double maxY =
        (canvasSize.height - pillH - 2.0).clamp(6.0, double.infinity);
    final double pillX = rect.left.clamp(0.0, maxX);
    final double pillTop = (rect.top - pillH - 4.0).clamp(6.0, maxY);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pillX, pillTop, pillW, pillH),
        const Radius.circular(radius),
      ),
      Paint()..color = Colors.black.withAlpha(190),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pillX + 1, pillTop + 1, pillW - 2, pillH - 2),
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
