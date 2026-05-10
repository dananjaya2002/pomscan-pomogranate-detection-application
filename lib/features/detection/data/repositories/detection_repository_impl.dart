/// Concrete implementation of [DetectionRepository].
///
/// Orchestrates [CameraDataSource]  [ModelDataSource].
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/frame_preprocessor.dart';
import '../../domain/entities/bounding_box.dart';
import '../../domain/entities/detection.dart';
import '../../domain/repositories/detection_repository.dart';
import '../datasources/model_datasource.dart';

final class DetectionRepositoryImpl implements DetectionRepository {
  DetectionRepositoryImpl({
    required ModelDataSource modelDataSource,
  }) : _model = modelDataSource;

  final ModelDataSource _model;

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
      confidenceThreshold ?? AppConstants.staticConfidenceThreshold,
      maxDetections ?? AppConstants.maxDetections,
      _model.inputSize,
      outputRows: _model.outputRows,
      outputCols: _model.outputCols,
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
    final preprocess = _preprocessImageBytes(imageBytes);
    final rawOutput = await _model.runInference(preprocess.buffer).timeout(
          const Duration(milliseconds: 1200),
        );

    final sourceWidth = width > 0 ? width : preprocess.sourceWidth;
    final sourceHeight = height > 0 ? height : preprocess.sourceHeight;

    return _parseYoloOutput(
      rawOutput,
      confidenceThreshold ?? AppConstants.confidenceThreshold,
      maxDetections ?? AppConstants.maxDetections,
      _model.inputSize,
      outputRows: _model.outputRows,
      outputCols: _model.outputCols,
      staticTransform: _StaticLetterboxTransform(
        sourceWidth: sourceWidth,
        sourceHeight: sourceHeight,
        inputSize: _model.inputSize,
        scale: preprocess.scale,
        padX: preprocess.padX,
        padY: preprocess.padY,
      ),
    );
  }

  //  Preprocessing

  // Camera frame preprocessing is now handled by [preprocessCameraFrame] in
  // frame_preprocessor.dart, which runs via compute() in a background isolate.

  /// Decodes raw image bytes (JPEG/PNG) to a normalised Float32List.
  _StaticPreprocessResult _preprocessImageBytes(Uint8List bytes) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null || image.width <= 0 || image.height <= 0) {
        throw StateError(
          'Could not decode image. Please use a valid JPG or PNG image.',
        );
      }
      return _imageToFloat32Letterbox(image, _model.inputSize);
    } catch (_) {
      throw StateError(
        'Could not decode image. Please use a valid JPG or PNG image.',
      );
    }
  }

  /// Letterboxes [image] into a square [modelInputSize] canvas and returns a
  /// normalised Float32 tensor plus geometric metadata for reverse mapping.
  _StaticPreprocessResult _imageToFloat32Letterbox(
    img.Image image,
    int modelInputSize,
  ) {
    final input = modelInputSize.toDouble();
    final scale = math.min(input / image.width, input / image.height);
    final resizedW = (image.width * scale).round().clamp(1, modelInputSize);
    final resizedH = (image.height * scale).round().clamp(1, modelInputSize);
    final padX = ((modelInputSize - resizedW) / 2).floorToDouble();
    final padY = ((modelInputSize - resizedH) / 2).floorToDouble();

    final resized = img.copyResize(
      image,
      width: resizedW,
      height: resizedH,
      interpolation: img.Interpolation.linear,
    );

    final canvas = img.Image(width: modelInputSize, height: modelInputSize);
    img.fill(canvas, color: img.ColorRgb8(0, 0, 0));
    img.compositeImage(
      canvas,
      resized,
      dstX: padX.toInt(),
      dstY: padY.toInt(),
    );

    final buffer = Float32List(
      modelInputSize * modelInputSize * 3,
    );

    var idx = 0;
    for (int y = 0; y < modelInputSize; y++) {
      for (int x = 0; x < modelInputSize; x++) {
        final pixel = canvas.getPixel(x, y);
        buffer[idx++] = pixel.r / 255.0;
        buffer[idx++] = pixel.g / 255.0;
        buffer[idx++] = pixel.b / 255.0;
      }
    }
    return _StaticPreprocessResult(
      buffer: buffer,
      scale: scale,
      padX: padX,
      padY: padY,
      sourceWidth: image.width,
      sourceHeight: image.height,
    );
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
    int modelInputSize, {
    int? outputRows,
    int? outputCols,
    _StaticLetterboxTransform? staticTransform,
  }) {
    final view = _YoloTensorView.tryCreate(
      output,
      AppConstants.classLabels.length,
      outputRowsHint: outputRows,
      outputColsHint: outputCols,
    );
    if (view == null) {
      return const [];
    }

    final candidates = <Detection>[];

    if (view.isDecodedNms) {
      for (var i = 0; i < view.anchors; i++) {
        final score = _toUnitScore(view.valueAt(4, i));
        if (score < confidenceThreshold) continue;

        final rawClassId = view.valueAt(5, i);
        if (!rawClassId.isFinite) continue;
        final classIdx = rawClassId.round();
        if (classIdx < 0 || classIdx >= AppConstants.classLabels.length) {
          continue;
        }

        final rawX1 = view.valueAt(0, i);
        final rawY1 = view.valueAt(1, i);
        final rawX2 = view.valueAt(2, i);
        final rawY2 = view.valueAt(3, i);
        if (!rawX1.isFinite ||
            !rawY1.isFinite ||
            !rawX2.isFinite ||
            !rawY2.isFinite) {
          continue;
        }

        final looksNormalised = rawX1.abs() <= 1.5 &&
            rawY1.abs() <= 1.5 &&
            rawX2.abs() <= 1.5 &&
            rawY2.abs() <= 1.5;

        final modelX1 = looksNormalised ? rawX1 : rawX1 / modelInputSize;
        final modelY1 = looksNormalised ? rawY1 : rawY1 / modelInputSize;
        final modelX2 = looksNormalised ? rawX2 : rawX2 / modelInputSize;
        final modelY2 = looksNormalised ? rawY2 : rawY2 / modelInputSize;

        final left = math.min(modelX1, modelX2).clamp(0.0, 1.0);
        final top = math.min(modelY1, modelY2).clamp(0.0, 1.0);
        final right = math.max(modelX1, modelX2).clamp(0.0, 1.0);
        final bottom = math.max(modelY1, modelY2).clamp(0.0, 1.0);

        final modelSpaceBox = BoundingBox(
          x1: left,
          y1: top,
          x2: right,
          y2: bottom,
        );

        final mappedBox = staticTransform == null
            ? modelSpaceBox
            : _mapLetterboxedBoxToSource(modelSpaceBox, staticTransform);

        if (mappedBox.width <= 0 || mappedBox.height <= 0) continue;

        candidates.add(
          Detection(
            box: mappedBox,
            label: AppConstants.classLabels[classIdx],
            confidence: score.clamp(0.0, 1.0),
            cls: DetectionClass.values[classIdx],
          ),
        );
      }

      candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
      // Model-exported NMS has already filtered overlaps.
      return candidates.take(maxDetections).toList();
    }

    for (var i = 0; i < view.anchors; i++) {
      var maxScore = 0.0;
      var classIdx = 0;

      // Use class confidence as primary ranking signal. Objectness (when
      // present) is reserved for future tuning because multiplying it here
      // can over-suppress valid detections for some exports.
      final objectness =
          view.hasObjectness ? _toUnitScore(view.valueAt(4, i)) : 1.0;

      for (var c = 0; c < view.classCount; c++) {
        final classScore =
            _toUnitScore(view.valueAt(view.classRowOffset + c, i));
        final s = classScore;
        if (s > maxScore) {
          maxScore = s;
          classIdx = c;
        }
      }

      if (view.hasObjectness && objectness <= 0.0) continue;

      if (maxScore < confidenceThreshold) continue;

      final cx = view.valueAt(0, i) / modelInputSize;
      final cy = view.valueAt(1, i) / modelInputSize;
      final w = view.valueAt(2, i) / modelInputSize;
      final h = view.valueAt(3, i) / modelInputSize;

      final x1 = (cx - w / 2).clamp(0.0, 1.0);
      final y1 = (cy - h / 2).clamp(0.0, 1.0);
      final x2 = (cx + w / 2).clamp(0.0, 1.0);
      final y2 = (cy + h / 2).clamp(0.0, 1.0);

      final modelSpaceBox = BoundingBox(x1: x1, y1: y1, x2: x2, y2: y2);
      final mappedBox = staticTransform == null
          ? modelSpaceBox
          : _mapLetterboxedBoxToSource(modelSpaceBox, staticTransform);
      final area = mappedBox.width * mappedBox.height;
      if (mappedBox.width <= 0 || mappedBox.height <= 0) continue;
      if (!mappedBox.width.isFinite || !mappedBox.height.isFinite) continue;
      if (!area.isFinite || area < 1e-5) continue;

      final safeIdx = classIdx.clamp(0, AppConstants.classLabels.length - 1);

      candidates.add(
        Detection(
          box: mappedBox,
          label: AppConstants.classLabels[safeIdx],
          confidence: maxScore.clamp(0.0, 1.0),
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

  double _toUnitScore(double raw) {
    if (!raw.isFinite) return 0.0;
    if (raw >= 0.0 && raw <= 1.0) return raw;
    return 1.0 / (1.0 + math.exp(-raw));
  }

  BoundingBox _mapLetterboxedBoxToSource(
    BoundingBox modelSpaceBox,
    _StaticLetterboxTransform transform,
  ) {
    final input = transform.inputSize.toDouble();

    double unletterboxX(double xNorm) {
      final xPx = xNorm * input;
      return ((xPx - transform.padX) / transform.scale)
          .clamp(0.0, transform.sourceWidth.toDouble());
    }

    double unletterboxY(double yNorm) {
      final yPx = yNorm * input;
      return ((yPx - transform.padY) / transform.scale)
          .clamp(0.0, transform.sourceHeight.toDouble());
    }

    final left = unletterboxX(modelSpaceBox.x1);
    final top = unletterboxY(modelSpaceBox.y1);
    final right = unletterboxX(modelSpaceBox.x2);
    final bottom = unletterboxY(modelSpaceBox.y2);

    return BoundingBox(
      x1: (left / transform.sourceWidth).clamp(0.0, 1.0),
      y1: (top / transform.sourceHeight).clamp(0.0, 1.0),
      x2: (right / transform.sourceWidth).clamp(0.0, 1.0),
      y2: (bottom / transform.sourceHeight).clamp(0.0, 1.0),
    );
  }
}

final class _StaticPreprocessResult {
  const _StaticPreprocessResult({
    required this.buffer,
    required this.scale,
    required this.padX,
    required this.padY,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  final Float32List buffer;
  final double scale;
  final double padX;
  final double padY;
  final int sourceWidth;
  final int sourceHeight;
}

final class _StaticLetterboxTransform {
  const _StaticLetterboxTransform({
    required this.sourceWidth,
    required this.sourceHeight,
    required this.inputSize,
    required this.scale,
    required this.padX,
    required this.padY,
  });

  final int sourceWidth;
  final int sourceHeight;
  final int inputSize;
  final double scale;
  final double padX;
  final double padY;
}

final class _YoloTensorView {
  const _YoloTensorView._({
    required this.data,
    required this.rowMajor,
    required this.anchors,
    required this.isDecodedNms,
    required this.classCount,
    required this.hasObjectness,
    required this.classRowOffset,
  });

  final List<List<double>> data;
  final bool rowMajor;
  final int anchors;
  final bool isDecodedNms;
  final int classCount;
  final bool hasObjectness;
  final int classRowOffset;

  static _YoloTensorView? tryCreate(
    List<List<double>> output,
    int maxClassLabels, {
    int? outputRowsHint,
    int? outputColsHint,
  }) {
    if (output.isEmpty || output.first.isEmpty) return null;

    final rows = output.length;
    final cols = output.first.length;

    // NMS-baked export format: [x1, y1, x2, y2, confidence, class_id]
    // Either [6, N] (feature-major) or [N, 6] (anchor-major).
    if (rows == 6 && cols > 0) {
      return _YoloTensorView._(
        data: output,
        rowMajor: true,
        anchors: cols,
        isDecodedNms: true,
        classCount: 0,
        hasObjectness: false,
        classRowOffset: 0,
      );
    }
    if (cols == 6 && rows > 0) {
      return _YoloTensorView._(
        data: output,
        rowMajor: false,
        anchors: rows,
        isDecodedNms: true,
        classCount: 0,
        hasObjectness: false,
        classRowOffset: 0,
      );
    }

    final expectedNoObjRows = 4 + maxClassLabels;
    final expectedObjRows = 5 + maxClassLabels;

    final candidates = <_YoloTensorCandidate>[];

    void addCandidate({
      required bool rowMajor,
      required bool hasObjectness,
      required int classCount,
    }) {
      final anchors = rowMajor ? cols : rows;
      if (anchors <= 0 || classCount <= 0) return;
      candidates.add(
        _YoloTensorCandidate(
          rowMajor: rowMajor,
          hasObjectness: hasObjectness,
          anchors: anchors,
          classCount: classCount,
          classRowOffset: hasObjectness ? 5 : 4,
        ),
      );
    }

    if (rows == expectedNoObjRows) {
      addCandidate(
        rowMajor: true,
        hasObjectness: false,
        classCount: maxClassLabels,
      );
    }
    if (rows == expectedObjRows) {
      addCandidate(
        rowMajor: true,
        hasObjectness: true,
        classCount: maxClassLabels,
      );
    }
    if (cols == expectedNoObjRows) {
      addCandidate(
        rowMajor: false,
        hasObjectness: false,
        classCount: maxClassLabels,
      );
    }
    if (cols == expectedObjRows) {
      addCandidate(
        rowMajor: false,
        hasObjectness: true,
        classCount: maxClassLabels,
      );
    }

    _YoloTensorCandidate? selected;
    if (candidates.isNotEmpty) {
      candidates.sort((a, b) => b.anchors.compareTo(a.anchors));
      selected = candidates.first;
    }

    selected ??= _fallbackCandidate(rows, cols, maxClassLabels);
    if (selected == null) return null;

    return _YoloTensorView._(
      data: output,
      rowMajor: selected.rowMajor,
      anchors: selected.anchors,
      isDecodedNms: false,
      classCount: selected.classCount,
      hasObjectness: selected.hasObjectness,
      classRowOffset: selected.classRowOffset,
    );
  }

  static _YoloTensorCandidate? _fallbackCandidate(
    int rows,
    int cols,
    int maxClassLabels,
  ) {
    const minRowsNeeded = 5;
    final looksRowMajor = rows >= minRowsNeeded && cols > rows;
    final looksColMajor = cols >= minRowsNeeded && rows > cols;

    final bool rowMajor;
    if (looksRowMajor) {
      rowMajor = true;
    } else if (looksColMajor) {
      rowMajor = false;
    } else if (rows >= minRowsNeeded && cols >= minRowsNeeded) {
      rowMajor = rows <= cols;
    } else if (rows >= minRowsNeeded) {
      rowMajor = true;
    } else if (cols >= minRowsNeeded) {
      rowMajor = false;
    } else {
      return null;
    }

    final availableRows = rowMajor ? rows : cols;
    final hasObjectness = availableRows >= 5 + maxClassLabels;
    final classCount =
        (availableRows - (hasObjectness ? 5 : 4)).clamp(0, maxClassLabels);
    if (classCount <= 0) return null;

    return _YoloTensorCandidate(
      rowMajor: rowMajor,
      hasObjectness: hasObjectness,
      anchors: rowMajor ? cols : rows,
      classCount: classCount,
      classRowOffset: hasObjectness ? 5 : 4,
    );
  }

  double valueAt(int row, int anchor) {
    return rowMajor ? data[row][anchor] : data[anchor][row];
  }
}

final class _YoloTensorCandidate {
  const _YoloTensorCandidate({
    required this.rowMajor,
    required this.hasObjectness,
    required this.anchors,
    required this.classCount,
    required this.classRowOffset,
  });

  final bool rowMajor;
  final bool hasObjectness;
  final int anchors;
  final int classCount;
  final int classRowOffset;
}
