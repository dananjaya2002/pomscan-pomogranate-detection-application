import 'dart:math' as math;
import 'dart:typed_data';

import '../../../../lib/core/utils/frame_preprocessor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'preprocessCameraFrame',
    () {
    test(
      'converts BGRA input into normalized RGB tensor',
      () {
      final input = FramePreprocessInput(
        yBytes: Uint8List(0),
        uBytes: Uint8List(0),
        vBytes: Uint8List(0),
        width: 1,
        height: 1,
        yRowStride: 0,
        uvRowStride: 0,
        uvPixelStride: 1,
        modelInputSize: 1,
        preprocessSize: 1,
        isBgra: true,
        bgraBytes: Uint8List.fromList([0, 0, 255, 255]),
      );

      final result = preprocessCameraFrame(input);

      expect(result.length, 3);
      expect(result[0], closeTo(1.0, 0.001));
      expect(result[1], closeTo(0.0, 0.001));
      expect(result[2], closeTo(0.0, 0.001));
      },
    );

    test(
      'converts YUV420 input into normalized tensor with expected size',
      () {
      const yValue = 100;
      const expected = yValue / 255.0;
      final input = FramePreprocessInput(
        yBytes: Uint8List.fromList([yValue, yValue, yValue, yValue]),
        uBytes: Uint8List.fromList([128]),
        vBytes: Uint8List.fromList([128]),
        width: 2,
        height: 2,
        yRowStride: 2,
        uvRowStride: 1,
        uvPixelStride: 1,
        modelInputSize: 2,
        preprocessSize: 2,
      );

      final result = preprocessCameraFrame(input);

      expect(result.length, 12);
      for (var i = 0; i < result.length; i += 3) {
        expect(result[i], closeTo(expected, 0.02));
        expect(result[i + 1], closeTo(expected, 0.02));
        expect(result[i + 2], closeTo(expected, 0.02));
      }
      },
    );

    test(
      'keeps all tensor values in [0, 1] range',
      () {
      final input = FramePreprocessInput(
        yBytes: Uint8List.fromList([255, 0, 255, 0]),
        uBytes: Uint8List.fromList([0]),
        vBytes: Uint8List.fromList([255]),
        width: 2,
        height: 2,
        yRowStride: 2,
        uvRowStride: 1,
        uvPixelStride: 1,
        modelInputSize: 2,
        preprocessSize: 2,
      );

      final result = preprocessCameraFrame(input);

      final minVal = result.reduce(math.min);
      final maxVal = result.reduce(math.max);
      expect(minVal, greaterThanOrEqualTo(0.0));
      expect(maxVal, lessThanOrEqualTo(1.0));
      },
    );
  });
}
