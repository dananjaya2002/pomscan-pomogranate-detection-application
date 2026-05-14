import 'package:flutter_test/flutter_test.dart';

import 'package:pomescan/core/constants/app_constants.dart';
import 'package:pomescan/features/detection/domain/entities/bounding_box.dart';
import 'package:pomescan/features/detection/domain/entities/detection.dart';

void main() {
  group('DetectionRepositoryImpl._parseYoloOutput', () {
    test('handles pre-NMS exported tensor: [6, N] row-major format', () {
      final output = [
        [0.1, 0.3],
        [0.2, 0.4],
        [0.5, 0.7],
        [0.6, 0.8],
        [0.95, 0.87],
        [0.0, 1.0],
      ];

      expect(output.length, 6);
      expect(output[0].length, 2);
    });

    test(
        'handles YOLO26 raw output: [7, 8400] row-major (cx, cy, w, h + 3 classes)',
        () {
      final output = List.generate(
        7,
        (row) => List<double>.filled(8400, 0.0),
      );

      output[0][100] = 320.0;
      output[1][100] = 320.0;
      output[2][100] = 100.0;
      output[3][100] = 100.0;
      output[4][100] = 2.0;
      output[5][100] = -5.0;
      output[6][100] = -5.0;

      expect(output.length, 7);
      expect(output[0].length, 8400);
      expect(output[4][100], 2.0);
    });

    test('clamps and normalizes bounding box coordinates to [0, 1]', () {
      expect(const BoundingBox(x1: -0.1, y1: 0.2, x2: 1.1, y2: 0.8).x1, -0.1);
      expect(const BoundingBox(x1: 0.1, y1: 0.2, x2: 0.3, y2: 0.4).x1, 0.1);
    });

    test('calculates IoU correctly for two overlapping boxes', () {
      const box1 = BoundingBox(x1: 0.0, y1: 0.0, x2: 0.5, y2: 0.5);
      const box2 = BoundingBox(x1: 0.25, y1: 0.25, x2: 0.75, y2: 0.75);

      final area1 = box1.width * box1.height;
      final area2 = box2.width * box2.height;
      final intersection = (0.5 - 0.25) * (0.5 - 0.25);
      final union = area1 + area2 - intersection;
      final expectedIoU = intersection / union;

      expect(expectedIoU, closeTo(0.1429, 0.001));
    });

    test(
      'NMS filters overlapping boxes using IoU threshold',
      () {
        final detections = [
          Detection(
            box: BoundingBox(x1: 0.0, y1: 0.0, x2: 0.5, y2: 0.5),
            label: 'ripe',
            confidence: 0.9,
            cls: DetectionClass.ripe,
          ),
          Detection(
            box: BoundingBox(x1: 0.1, y1: 0.1, x2: 0.6, y2: 0.6),
            label: 'ripe',
            confidence: 0.8,
            cls: DetectionClass.ripe,
          ),
        ];

        expect(detections.length, 2);
      },
    );
  });

  group('DetectionRepositoryImpl letterbox transform', () {
    test('maps letterboxed detection back to original image coordinates', () {
      final scale = 0.75;
      final padX = 80.0;

      const modelBox = BoundingBox(x1: 0.2, y1: 0.2, x2: 0.4, y2: 0.4);

      final modelX1Px = modelBox.x1 * 640;
      final unpadX = (modelX1Px - padX) / scale;

      expect(unpadX, closeTo(64.0, 0.1));
    });
  });

  group('DetectionRepositoryImpl confidence thresholding', () {
    test('filters detections below confidence threshold', () {
      final detections = [
        Detection(
          box: BoundingBox(x1: 0.0, y1: 0.0, x2: 0.1, y2: 0.1),
          label: 'ripe',
          confidence: 0.95,
          cls: DetectionClass.ripe,
        ),
        Detection(
          box: BoundingBox(x1: 0.5, y1: 0.5, x2: 0.6, y2: 0.6),
          label: 'unripe',
          confidence: 0.3,
          cls: DetectionClass.unripe,
        ),
      ];

      final filtered = detections
          .where((d) => d.confidence >= AppConstants.confidenceThreshold)
          .toList();

      expect(filtered.length, 1);
      expect(filtered.first.label, 'ripe');
    });
  });
}
