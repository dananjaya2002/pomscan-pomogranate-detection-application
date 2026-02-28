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
  ConsumerState<StaticDetectionPage> createState() => _StaticDetectionPageState();
}

class _StaticDetectionPageState extends ConsumerState<StaticDetectionPage> {
  File? _image;
  List<Detection>? _detections;
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _detections = null; // Reset detections on new image
      });
      _runDetection();
    }
  }

  Future<void> _runDetection() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final bytes = await _image!.readAsBytes();
      
      // Decode image to get dimensions for inference
      final decodedImage = await decodeImageFromList(bytes);

      final useCase = ref.read(runDetectionUseCaseProvider);
      
      final results = await useCase.callStatic(
        bytes,
        decodedImage.width,
        decodedImage.height,
      );

      if (mounted) {
        setState(() {
          _detections = results;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detection failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Image Detection'),
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
                        if (_detections != null)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _StaticBBoxPainter(_detections!),
                            ),
                          ),
                        if (_isProcessing)
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                      ],
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
  const _StaticBBoxPainter(this.detections);
  final List<Detection> detections;

  @override
  void paint(Canvas canvas, Size size) {
    for (final detection in detections) {
      final box = detection.box;
      
      // Transform normalized coordinates to painter size
      final rect = Rect.fromLTRB(
        box.x1 * size.width,
        box.y1 * size.height,
        box.x2 * size.width,
        box.y2 * size.height,
      );

      final color = AppConstants.classColors[detection.label] ?? Colors.red;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppConstants.bboxStrokeWidth;

      canvas.drawRect(rect, paint);

      // Draw Label
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '${detection.label} ${detection.confidencePercent}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppConstants.labelFontSize,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(rect.left, rect.top - textPainter.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
