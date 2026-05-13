import 'package:pomescan/features/detection/domain/entities/bounding_box.dart';
import 'package:pomescan/features/detection/domain/entities/detection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoundingBox', () {
    test(
      'calculates geometry helpers correctly',
      () {
        const box = BoundingBox(x1: 0.1, y1: 0.2, x2: 0.7, y2: 0.8);

        expect(box.width, closeTo(0.6, 0.0001));
        expect(box.height, closeTo(0.6, 0.0001));
        expect(box.centerX, closeTo(0.4, 0.0001));
        expect(box.centerY, closeTo(0.5, 0.0001));
      },
    );

    test(
      'supports value equality',
      () {
        const a = BoundingBox(x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0);
        const b = BoundingBox(x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0);

        expect(a, equals(b));
      },
    );
  });

  group(
    'Detection',
    () {
      test(
        'formats confidence percentage',
        () {
          const detection = Detection(
            box: BoundingBox(x1: 0.1, y1: 0.1, x2: 0.2, y2: 0.2),
            label: 'ripe',
            confidence: 0.941,
            cls: DetectionClass.ripe,
          );

          expect(detection.confidencePercent, '94%');
        },
      );

      test(
        'clamps confidence percentage text to 0-100',
        () {
          const low = Detection(
            box: BoundingBox(x1: 0.1, y1: 0.1, x2: 0.2, y2: 0.2),
            label: 'ripe',
            confidence: -3,
            cls: DetectionClass.ripe,
          );
          const high = Detection(
            box: BoundingBox(x1: 0.1, y1: 0.1, x2: 0.2, y2: 0.2),
            label: 'unripe',
            confidence: 4,
            cls: DetectionClass.unripe,
          );

          expect(low.confidencePercent, '0%');
          expect(high.confidencePercent, '100%');
        },
      );
    },
  );
}
