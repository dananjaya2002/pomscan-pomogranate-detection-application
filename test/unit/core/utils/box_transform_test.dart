import 'dart:ui';

import 'package:pomescan/core/utils/box_transform.dart';
import 'package:pomescan/features/detection/domain/entities/bounding_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoxTransformer.toScreenRect', () {
    test(
      'maps center point to screen center',
      () {
        const box = BoundingBox(x1: 0.4, y1: 0.4, x2: 0.6, y2: 0.6);
        const overlay = Size(1080, 1920);

        final rect = BoxTransformer.toScreenRect(box, 0.75, overlay);

        expect(rect.center.dx, closeTo(overlay.width / 2, 0.1));
        expect(rect.center.dy, closeTo(overlay.height / 2, 0.1));
      },
    );

    test(
      'portrait and inverted landscape ratios produce same mapping',
      () {
        const box = BoundingBox(x1: 0.2, y1: 0.2, x2: 0.8, y2: 0.8);
        const overlay = Size(1080, 1920);

        final portraitRect = BoxTransformer.toScreenRect(box, 0.75, overlay);
        final invertedRect = BoxTransformer.toScreenRect(
          box,
          1.0 / 0.75,
          overlay,
        );

        expect(portraitRect.left, closeTo(invertedRect.left, 0.001));
        expect(portraitRect.top, closeTo(invertedRect.top, 0.001));
        expect(portraitRect.right, closeTo(invertedRect.right, 0.001));
        expect(portraitRect.bottom, closeTo(invertedRect.bottom, 0.001));
      },
    );

    test(
      'keeps rectangle ordering valid after transform',
      () {
        const box = BoundingBox(x1: 0.1, y1: 0.1, x2: 0.9, y2: 0.9);

        final rect =
            BoxTransformer.toScreenRect(box, 0.75, const Size(720, 1280));

        expect(rect.left, lessThan(rect.right));
        expect(rect.top, lessThan(rect.bottom));
      },
    );
  });
}
