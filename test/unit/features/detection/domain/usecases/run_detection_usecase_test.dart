import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../lib/features/detection/domain/entities/bounding_box.dart';
import '../../../../../../lib/features/detection/domain/entities/detection.dart';
import '../../../../../../lib/features/detection/domain/repositories/detection_repository.dart';
import '../../../../../../lib/features/detection/domain/usecases/run_detection_usecase.dart';

void main() {
  group('RunDetectionUseCase.callStatic', () {
    test(
      'delegates arguments to repository.detectOnImage and returns result',
      () async {
      final repository = _FakeDetectionRepository();
      const expected = [
        Detection(
          box: BoundingBox(x1: 0.1, y1: 0.1, x2: 0.3, y2: 0.3),
          label: 'ripe',
          confidence: 0.91,
          cls: DetectionClass.ripe,
        ),
      ];
      repository.staticResult = expected;
      final useCase = RunDetectionUseCase(repository);

      final imageBytes = Uint8List.fromList([1, 2, 3]);
      final result = await useCase.callStatic(
        imageBytes,
        640,
        480,
        confidenceThreshold: 0.5,
        maxDetections: 4,
      );

      expect(result, expected);
      expect(repository.staticCallCount, 1);
      expect(repository.lastWidth, 640);
      expect(repository.lastHeight, 480);
      expect(repository.lastConfidenceThreshold, 0.5);
      expect(repository.lastMaxDetections, 4);
      expect(repository.lastBytes, imageBytes);
    });
  });
}

final class _FakeDetectionRepository implements DetectionRepository {
  List<Detection> staticResult = const [];
  int staticCallCount = 0;
  Uint8List? lastBytes;
  int? lastWidth;
  int? lastHeight;
  double? lastConfidenceThreshold;
  int? lastMaxDetections;

  @override
  Future<List<Detection>> detect(
    CameraImage frame, {
    double? confidenceThreshold,
    int? maxDetections,
    int? preprocessSize,
  }) async {
    throw UnimplementedError('Not needed for this test');
  }

  @override
  Future<List<Detection>> detectOnImage(
    Uint8List imageBytes,
    int width,
    int height, {
    double? confidenceThreshold,
    int? maxDetections,
  }) async {
    staticCallCount += 1;
    lastBytes = imageBytes;
    lastWidth = width;
    lastHeight = height;
    lastConfidenceThreshold = confidenceThreshold;
    lastMaxDetections = maxDetections;
    return staticResult;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialise() async {}
}
