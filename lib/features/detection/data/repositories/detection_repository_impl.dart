/// Concrete implementation of [DetectionRepository].
///
/// Orchestrates [CameraDataSource]  [ModelDataSource].
library;

import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/bounding_box.dart';
import '../../domain/entities/detection.dart';
import '../../domain/repositories/detection_repository.dart';
import '../datasources/camera_datasource.dart';
import '../datasources/model_datasource.dart';

final class DetectionRepositoryImpl implements DetectionRepository {
  DetectionRepositoryImpl({
    required ModelDataSource modelDataSource,
    required CameraDataSource cameraDataSource,
  }) : _model = modelDataSource,
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
  }) async {
    final inputBuffer = _preprocessCameraImage(frame);
    final rawOutput = await _model.runInference(inputBuffer);
    return _parseYoloOutput(
      rawOutput,
      confidenceThreshold ?? AppConstants.confidenceThreshold,
      maxDetections ?? AppConstants.maxDetections,
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
    final inputBuffer = _preprocessImageBytes(imageBytes);
    final rawOutput = await _model.runInference(inputBuffer);
    return _parseYoloOutput(
      rawOutput,
      confidenceThreshold ?? AppConstants.confidenceThreshold,
      maxDetections ?? AppConstants.maxDetections,
    );
  }

  //  Preprocessing 

  /// Converts a [CameraImage] (YUV420 or BGRA8888) to a normalised
  /// Float32List ready for the TFLite interpreter.
  Float32List _preprocessCameraImage(CameraImage frame) {
    img.Image? image;

    if (frame.format.group == ImageFormatGroup.yuv420) {
      image = _convertYUV420(frame);
    } else if (frame.format.group == ImageFormatGroup.bgra8888) {
      image = img.Image.fromBytes(
        width: frame.width,
        height: frame.height,
        bytes: frame.planes[0].bytes.buffer,
        order: img.ChannelOrder.bgra,
      );
    } else if (frame.format.group == ImageFormatGroup.nv21) {
      image = _convertYUV420(frame);
    }

    if (image == null) {
      throw StateError(
        'Unsupported CameraImage format: ${frame.format.group}',
      );
    }

    return _imageToFloat32(image);
  }

  /// Converts a YUV420 (or NV21) [CameraImage] to an [img.Image].
  img.Image _convertYUV420(CameraImage frame) {
    final result = img.Image(width: frame.width, height: frame.height);

    final yPlane = frame.planes[0].bytes;
    final uPlane = frame.planes[1].bytes;
    final vPlane = frame.planes[2].bytes;

    final yRowStride = frame.planes[0].bytesPerRow;
    final uvRowStride = frame.planes[1].bytesPerRow;
    final uvPixelStride = frame.planes[1].bytesPerPixel ?? 1;

    for (int y = 0; y < frame.height; y++) {
      for (int x = 0; x < frame.width; x++) {
        final yIndex = y * yRowStride + x;
        final uvIndex =
            (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final yVal = yPlane[yIndex] & 0xFF;
        final uVal = (uPlane[uvIndex] & 0xFF) - 128;
        final vVal = (vPlane[uvIndex] & 0xFF) - 128;

        final r = (yVal + 1.402 * vVal).round().clamp(0, 255);
        final g =
            (yVal - 0.344136 * uVal - 0.714136 * vVal)
                .round()
                .clamp(0, 255);
        final b = (yVal + 1.772 * uVal).round().clamp(0, 255);

        result.setPixelRgb(x, y, r, g, b);
      }
    }
    return result;
  }

  /// Decodes raw image bytes (JPEG/PNG/) to a normalised Float32List.
  Float32List _preprocessImageBytes(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) throw StateError('Could not decode image bytes');
    return _imageToFloat32(image);
  }

  /// Resizes [image] to [AppConstants.inputSize] squared and returns a flat
  /// Float32List normalised to [0, 1] in HWC order.
  Float32List _imageToFloat32(img.Image image) {
    final resized = img.copyResize(
      image,
      width: AppConstants.inputSize,
      height: AppConstants.inputSize,
      interpolation: img.Interpolation.linear,
    );

    final buffer = Float32List(
      AppConstants.inputSize * AppConstants.inputSize * 3,
    );

    var idx = 0;
    for (int y = 0; y < AppConstants.inputSize; y++) {
      for (int x = 0; x < AppConstants.inputSize; x++) {
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
  /// [output] has shape [7][8400]:
  ///   - rows 0-3 : cx, cy, w, h in [0, inputSize] pixel space
  ///   - rows 4-6 : class scores (ripe, semi_ripe, unripe)
  List<Detection> _parseYoloOutput(
    List<List<double>> output,
    double confidenceThreshold,
    int maxDetections,
  ) {
    final anchors = output[0].length; // 8400
    final candidates = <Detection>[];

    for (var i = 0; i < anchors; i++) {
      var maxScore = 0.0;
      var classIdx = 0;
      for (var c = 0; c < AppConstants.numClasses; c++) {
        final s = output[4 + c][i];
        if (s > maxScore) {
          maxScore = s;
          classIdx = c;
        }
      }

      if (maxScore < confidenceThreshold) continue;

      final cx = output[0][i] / AppConstants.inputSize;
      final cy = output[1][i] / AppConstants.inputSize;
      final w = output[2][i] / AppConstants.inputSize;
      final h = output[3][i] / AppConstants.inputSize;

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
