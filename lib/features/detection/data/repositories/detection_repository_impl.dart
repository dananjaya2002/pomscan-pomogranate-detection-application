/// Concrete implementation of [DetectionRepository].
///
/// Orchestrates [CameraDataSource]  [ModelDataSource].
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/frame_preprocessor.dart';
import '../../domain/entities/bounding_box.dart';
import '../../domain/entities/detection.dart';
import '../../domain/repositories/detection_repository.dart';
import '../datasources/camera_datasource.dart';
import '../datasources/model_datasource.dart';

final class DetectionRepositoryImpl implements DetectionRepository {
  DetectionRepositoryImpl({
    required ModelDataSource modelDataSource,
    required CameraDataSource cameraDataSource,
  })  : _model = modelDataSource,
        _camera = cameraDataSource;

  final ModelDataSource _model;
  // ignore: unused_field
  final CameraDataSource _camera;

  @override
  Future<void> initialise() => _model.initialise();

  @override
  Future<void> dispose() => _model.dispose();

  //  Camera frame inference

  @override
  Future<List<Detection>> detect(
    CameraImage frame, {
    double? confidenceThreshold,
    int? maxDetections,
    int? preprocessSize,
  }) async {
    final bool isBgra = frame.format.group == ImageFormatGroup.bgra8888;
    final input = FramePreprocessInput(
      yBytes: frame.planes[0].bytes,
      uBytes: frame.planes.length > 1 ? frame.planes[1].bytes : Uint8List(0),
      vBytes: frame.planes.length > 2 ? frame.planes[2].bytes : Uint8List(0),
      width: frame.width,
      height: frame.height,
      yRowStride: frame.planes[0].bytesPerRow,
      uvRowStride: frame.planes.length > 1 ? frame.planes[1].bytesPerRow : 0,
      uvPixelStride:
          frame.planes.length > 1 ? (frame.planes[1].bytesPerPixel ?? 1) : 1,
      modelInputSize: _model.inputSize,
      preprocessSize: preprocessSize ?? _model.inputSize,
      isBgra: isBgra,
      bgraBytes: isBgra ? frame.planes[0].bytes : null,
    );

    // Offload heavy YUV→RGB conversion + resize to a background isolate.
    final inputBuffer = await compute(preprocessCameraFrame, input).timeout(
      const Duration(milliseconds: 500),
    );
    final rawOutput = await _model.runInference(inputBuffer).timeout(
          const Duration(milliseconds: 650),
        );
    return _parseYoloOutput(
      rawOutput,
      confidenceThreshold ?? AppConstants.confidenceThreshold,
      maxDetections ?? AppConstants.maxDetections,
      _model.inputSize,
    );
  }

  //  Static image inference

  @override
  Future<List<Detection>> detectOnImage(
    Uint8List imageBytes,
    int width,
    int height, {
    double? confidenceThreshold,
    int? maxDetections,
  }) async {
    if (imageBytes.isEmpty) {
      throw StateError('Selected image is empty. Please choose another image.');
    }
    final inputBuffer = _preprocessImageBytes(imageBytes);
    final rawOutput = await _model.runInference(inputBuffer).timeout(
          const Duration(milliseconds: 1200),
        );
    return _parseYoloOutput(
      rawOutput,
      confidenceThreshold ?? AppConstants.confidenceThreshold,
      maxDetections ?? AppConstants.maxDetections,
      _model.inputSize,
    );
  }

  //  Preprocessing

  // Camera frame preprocessing is now handled by [preprocessCameraFrame] in
  // frame_preprocessor.dart, which runs via compute() in a background isolate.

  /// Decodes raw image bytes (JPEG/PNG) to a normalised Float32List.
  Float32List _preprocessImageBytes(Uint8List bytes) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null || image.width <= 0 || image.height <= 0) {
        throw StateError(
          'Could not decode image. Please use a valid JPG or PNG image.',
        );
      }
      return _imageToFloat32(image, _model.inputSize);
    } catch (_) {
      throw StateError(
        'Could not decode image. Please use a valid JPG or PNG image.',
      );
    }
  }

  /// Resizes [image] to [AppConstants.inputSize] squared and returns a flat
  /// Float32List normalised to [0, 1] in HWC order.
  Float32List _imageToFloat32(img.Image image, int modelInputSize) {
    final resized = img.copyResize(
      image,
      width: modelInputSize,
      height: modelInputSize,
      interpolation: img.Interpolation.linear,
    );

    final buffer = Float32List(
      modelInputSize * modelInputSize * 3,
    );

    var idx = 0;
    for (int y = 0; y < modelInputSize; y++) {
      for (int x = 0; x < modelInputSize; x++) {
        final pixel = resized.getPixel(x, y);
        buffer[idx++] = pixel.r / 255.0;
        buffer[idx++] = pixel.g / 255.0;
        buffer[idx++] = pixel.b / 255.0;
      }
    }
    return buffer;
  }

  //  YOLO11 output decoding

  /// Decodes the YOLO11 output tensor.
  ///
  /// [output] has shape [rows][anchors]:
  ///   - rows 0-3 : cx, cy, w, h in [0, inputSize] pixel space
  ///   - rows 4.. : class scores
  List<Detection> _parseYoloOutput(
    List<List<double>> output,
    double confidenceThreshold,
    int maxDetections,
    int modelInputSize,
  ) {
    if (output.length < 5 || output[0].isEmpty) {
      return const [];
    }

    final anchors = output[0].length;
    final availableClassRows = output.length - 4;
    final classCount = availableClassRows < AppConstants.classLabels.length
        ? availableClassRows
        : AppConstants.classLabels.length;
    if (classCount <= 0) return const [];

    final candidates = <Detection>[];

    for (var i = 0; i < anchors; i++) {
      var maxScore = 0.0;
      var classIdx = 0;
      for (var c = 0; c < classCount; c++) {
        final s = output[4 + c][i];
        if (s > maxScore) {
          maxScore = s;
          classIdx = c;
        }
      }

      if (maxScore < confidenceThreshold) continue;

      final cx = output[0][i] / modelInputSize;
      final cy = output[1][i] / modelInputSize;
      final w = output[2][i] / modelInputSize;
      final h = output[3][i] / modelInputSize;

      final x1 = (cx - w / 2).clamp(0.0, 1.0);
      final y1 = (cy - h / 2).clamp(0.0, 1.0);
      final x2 = (cx + w / 2).clamp(0.0, 1.0);
      final y2 = (cy + h / 2).clamp(0.0, 1.0);

      final safeIdx = classIdx.clamp(0, AppConstants.classLabels.length - 1);

      candidates.add(
        Detection(
          box: BoundingBox(x1: x1, y1: y1, x2: x2, y2: y2),
          label: AppConstants.classLabels[safeIdx],
          confidence: maxScore,
          cls: DetectionClass.values[safeIdx],
        ),
      );
    }

    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    return _nms(candidates, AppConstants.iouThreshold)
        .take(maxDetections)
        .toList();
  }

  //  Non-Maximum Suppression

  List<Detection> _nms(List<Detection> boxes, double iouThreshold) {
    final result = <Detection>[];
    final active = List<bool>.filled(boxes.length, true);

    for (var i = 0; i < boxes.length; i++) {
      if (!active[i]) continue;
      result.add(boxes[i]);
      for (var j = i + 1; j < boxes.length; j++) {
        if (!active[j]) continue;
        if (_iou(boxes[i].box, boxes[j].box) > iouThreshold) {
          active[j] = false;
        }
      }
    }
    return result;
  }

  double _iou(BoundingBox a, BoundingBox b) {
    final interX1 = a.x1 > b.x1 ? a.x1 : b.x1;
    final interY1 = a.y1 > b.y1 ? a.y1 : b.y1;
    final interX2 = a.x2 < b.x2 ? a.x2 : b.x2;
    final interY2 = a.y2 < b.y2 ? a.y2 : b.y2;

    final interW = interX2 - interX1;
    final interH = interY2 - interY1;
    if (interW <= 0 || interH <= 0) return 0.0;

    final interArea = interW * interH;
    final aArea = (a.x2 - a.x1) * (a.y2 - a.y1);
    final bArea = (b.x2 - b.x1) * (b.y2 - b.y1);

    return interArea / (aArea + bArea - interArea);
  }
}
