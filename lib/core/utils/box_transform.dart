library;

import 'dart:ui' show Rect, Size;

import '../../features/detection/domain/entities/bounding_box.dart';

abstract final class BoxTransformer {
  BoxTransformer._();

  static Rect toScreenRect(
    BoundingBox box,
    double previewAspectRatio,
    Size overlaySize,
  ) {
    final double ar = previewAspectRatio > 1.0
        ? 1.0 / previewAspectRatio
        : previewAspectRatio;

    final double W = overlaySize.width;
    final double H = overlaySize.height;
    final double screenAR = W / H;

    final double cropTop = (1.0 - ar) / 2.0;

    double normX(double modelX) => modelX;
    double normY(double modelY) => modelY * ar + cropTop;

    double toScreenX(double fx) {
      if (ar > screenAR) {
        return W / 2.0 + ar * H * (fx - 0.5);
      } else {
        return W * fx;
      }
    }

    double toScreenY(double fy) {
      if (ar > screenAR) {
        return H * fy;
      } else {
        return H / 2.0 + (fy - 0.5) * (W / ar);
      }
    }

    return Rect.fromLTRB(
      toScreenX(normX(box.x1)),
      toScreenY(normY(box.y1)),
      toScreenX(normX(box.x2)),
      toScreenY(normY(box.y2)),
    );
  }
}
