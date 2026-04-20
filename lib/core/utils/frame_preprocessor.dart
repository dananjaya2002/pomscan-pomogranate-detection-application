/// Top-level preprocessing utilities for camera frames.
///
/// All functions here are **top-level** (not class members) so they can be
/// passed directly to Flutter's [compute] function, which runs them in a
/// background isolate.  No Flutter/Material types are imported — only Dart
/// primitives and the pure-Dart `image` package — ensuring safe serialisation
/// across isolate boundaries.
library;

import 'dart:typed_data';

import 'package:image/image.dart' as img;

// ── Input data class ──────────────────────────────────────────────────────────

/// All data needed to preprocess a raw camera frame into a TFLite input tensor.
///
/// Every field is a primitive type or [Uint8List] so the object can be
/// serialised through Flutter's isolate `SendPort` (required by [compute]).
final class FramePreprocessInput {
  const FramePreprocessInput({
    required this.yBytes,
    required this.uBytes,
    required this.vBytes,
    required this.width,
    required this.height,
    required this.yRowStride,
    required this.uvRowStride,
    required this.uvPixelStride,
    required this.modelInputSize,
    required this.preprocessSize,
    this.isBgra = false,
    this.bgraBytes,
  });

  /// Y-plane bytes from the camera (also used as the single plane for BGRA).
  final Uint8List yBytes;

  /// U/Cb chroma plane bytes (YUV420 only).
  final Uint8List uBytes;

  /// V/Cr chroma plane bytes (YUV420 only).
  final Uint8List vBytes;

  /// Camera frame width in pixels.
  final int width;

  /// Camera frame height in pixels.
  final int height;

  /// Bytes-per-row for the Y plane.
  final int yRowStride;

  /// Bytes-per-row for the U/V planes.
  final int uvRowStride;

  /// Bytes-per-pixel stride for the UV plane (interleaved NV12/NV21 = 2).
  final int uvPixelStride;

  /// The final spatial size sent to the TFLite model (e.g. 640).
  /// The output Float32List will have [modelInputSize * modelInputSize * 3] elements.
  final int modelInputSize;

  /// Intermediate downsampling size that controls quality vs speed.
  /// Pixels are sampled at step = max(width,height) / preprocessSize.
  /// Values: 320 (fastest), 416 (balanced), 640 (full quality).
  final int preprocessSize;

  /// `true` when the camera supplies BGRA8888 (iOS default).
  final bool isBgra;

  /// Raw BGRA bytes — only populated when [isBgra] is `true`.
  final Uint8List? bgraBytes;
}

// ── Public entry point ────────────────────────────────────────────────────────

/// Converts a raw camera frame ([FramePreprocessInput]) to a normalised
/// [Float32List] ready for the TFLite interpreter.
///
/// This is a **top-level function** so it can be passed to [compute]:
/// ```dart
/// final buffer = await compute(preprocessCameraFrame, input);
/// ```
///
/// Handles:
///  - YUV420 / NV21 (Android, step-sampled for speed when preprocessSize < 640)
///  - BGRA8888 (iOS)
Float32List preprocessCameraFrame(FramePreprocessInput input) {
  final img.Image raw;

  if (input.isBgra && input.bgraBytes != null) {
    // iOS BGRA8888 — fast byte copy via image package
    raw = img.Image.fromBytes(
      width: input.width,
      height: input.height,
      bytes: input.bgraBytes!.buffer,
      order: img.ChannelOrder.bgra,
    );
  } else {
    raw = _convertYUV420(input);
  }

  return _imageToFloat32(raw, input.modelInputSize);
}

// ── Preprocessing helpers (package-private) ───────────────────────────────────

/// Converts a YUV420/NV21 camera frame to an [img.Image].
///
/// When [FramePreprocessInput.preprocessSize] < camera width, a pixel-skip
/// step is applied: only every `step`-th pixel in each dimension is sampled.
/// This reduces the loop iteration count by `step²`, trading image quality
/// for significant CPU savings in the hot path.
img.Image _convertYUV420(FramePreprocessInput input) {
  // Determine sampling step so the output image is approximately
  // preprocessSize × (preprocessSize * height/width) pixels.
  final int step =
      (input.width / input.preprocessSize).ceil().clamp(1, 4);

  final int outW = (input.width / step).ceil();
  final int outH = (input.height / step).ceil();

  final result = img.Image(width: outW, height: outH);

  final yBytes = input.yBytes;
  final uBytes = input.uBytes;
  final vBytes = input.vBytes;
  final yRowStride = input.yRowStride;
  final uvRowStride = input.uvRowStride;
  final uvPixelStride = input.uvPixelStride;

  for (int sy = 0, dy = 0; sy < input.height; sy += step, dy++) {
    for (int sx = 0, dx = 0; sx < input.width; sx += step, dx++) {
      final int yIndex = sy * yRowStride + sx;
      final int uvIndex =
          (sy ~/ 2) * uvRowStride + (sx ~/ 2) * uvPixelStride;

      final int yVal = yBytes[yIndex] & 0xFF;
      final int uVal = (uBytes[uvIndex] & 0xFF) - 128;
      final int vVal = (vBytes[uvIndex] & 0xFF) - 128;

      final int r = (yVal + 1.402 * vVal).round().clamp(0, 255);
      final int g =
          (yVal - 0.344136 * uVal - 0.714136 * vVal).round().clamp(0, 255);
      final int b = (yVal + 1.772 * uVal).round().clamp(0, 255);

      result.setPixelRgb(dx, dy, r, g, b);
    }
  }

  return result;
}

/// Resizes [image] to [inputSize] × [inputSize] and returns a flat
/// [Float32List] normalised to `[0, 1]` in HWC order.
Float32List _imageToFloat32(img.Image image, int inputSize) {
  final resized = img.copyResize(
    image,
    width: inputSize,
    height: inputSize,
    interpolation: img.Interpolation.linear,
  );

  final buffer = Float32List(inputSize * inputSize * 3);
  var idx = 0;
  for (int y = 0; y < inputSize; y++) {
    for (int x = 0; x < inputSize; x++) {
      final pixel = resized.getPixel(x, y);
      buffer[idx++] = pixel.r / 255.0;
      buffer[idx++] = pixel.g / 255.0;
      buffer[idx++] = pixel.b / 255.0;
    }
  }
  return buffer;
}
