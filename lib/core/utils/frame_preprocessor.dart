library;

import 'dart:typed_data';

import 'package:image/image.dart' as img;

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

  final Uint8List yBytes;

  final Uint8List uBytes;

  final Uint8List vBytes;

  final int width;

  final int height;

  final int yRowStride;

  final int uvRowStride;

  final int uvPixelStride;

  final int modelInputSize;

  final int preprocessSize;

  final bool isBgra;

  final Uint8List? bgraBytes;
}

Float32List preprocessCameraFrame(FramePreprocessInput input) {
  final img.Image raw;

  if (input.isBgra && input.bgraBytes != null) {
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

img.Image _convertYUV420(FramePreprocessInput input) {
  final int step = (input.width / input.preprocessSize).ceil().clamp(1, 4);

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
      final int uvIndex = (sy ~/ 2) * uvRowStride + (sx ~/ 2) * uvPixelStride;

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
