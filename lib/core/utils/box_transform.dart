/// Coordinate transform: YOLO model space → screen pixel space.
///
/// ## Rendering pipeline recap
///
/// 1. Raw CameraImage (Android: landscape) is **rotated 90° CW** in
///    `image_utils.dart` → portrait frame, width D_w, height D_h,
///    aspect ratio `ar = D_w / D_h` (< 1 for portrait, e.g. 0.75 for 4:3).
///
/// 2. The portrait frame is **centre-cropped to a square** (width × width).
///    - Horizontal strip used: full width [0..D_w].
///    - Vertical strip used:   [cropTop .. cropTop + D_w] where
///      `cropTop = (D_h - D_w) / 2`.
///    So model coord (0,0) maps to frame pixel (0, cropTop), not (0,0).
///
/// 3. `CameraPreviewWidget` renders the **full** portrait frame using:
///    - `Center(child: CameraPreview(controller))` inside a W × H
///      `LayoutBuilder` constraint.
///    - `Transform.scale(scale, alignment: Alignment.center)` to fill the
///      screen without black bars (cover behaviour).
///    - `ClipRect` hides the overflow.
///
/// 4. Scale factor:
///    - `screenAR = W / H`
///    - If `ar > screenAR`: `scale = ar * H / W`   (preview taller than screen)
///    - Else                `scale = W / (H * ar)` (preview narrower than screen)
///
/// ## Derived formulae
///
/// Let `fx` and `fy` be the **frame-normalised** coordinates of a model point:
///
/// ```
/// fx = model_x                                  // portrait: no x-crop
/// fy = model_y * ar + (1 − ar) / 2              // accounts for top/bottom crop
/// ```
///
/// Screen coordinates:
///
/// When `ar > screenAR`:
/// ```
/// screen_x = W/2 + ar·H·(fx − 0.5)
/// screen_y = H · fy
/// ```
///
/// When `ar ≤ screenAR`:
/// ```
/// screen_x = W · fx
/// screen_y = H/2 + (fy − 0.5)·(W / ar)
/// ```
///
/// Both cases map a centred unit box to screen centre exactly.
library;

import 'dart:ui' show Rect, Size;

import '../../features/detection/domain/entities/bounding_box.dart';

/// Transforms normalised [BoundingBox] coordinates (YOLO model space, [0,1])
/// to screen pixel coordinates matching the live [CameraPreviewWidget].
abstract final class BoxTransformer {
  BoxTransformer._();

  /// Returns the screen-space [Rect] for [box] given:
  /// - [previewAspectRatio]: `controller.value.aspectRatio` (width ÷ height
  ///   of the camera preview as Flutter reports it, e.g. `0.75` for 4:3
  ///   portrait or `1.333` for a landscape sensor in front-facing portrait).
  ///   Pass `min(raw, 1.0)` if you know the value is always portrait.
  /// - [overlaySize]: the pixel size of the overlay widget (must match the
  ///   camera preview container, ie. the full screen).
  static Rect toScreenRect(
    BoundingBox box,
    double previewAspectRatio,
    Size overlaySize,
  ) {
    // Ensure we treat the camera as portrait (ar ≤ 1). If the platform
    // accidentally reports a landscape ratio, invert it.
    final double ar = previewAspectRatio > 1.0
        ? 1.0 / previewAspectRatio
        : previewAspectRatio;

    final double W = overlaySize.width;
    final double H = overlaySize.height;
    final double screenAR = W / H;

    // Map model coords → frame-normalised coords.
    //   Portrait frame: width = D_w, height = D_h = D_w / ar
    //   cropTop_norm = (1 − ar) / 2   (fraction of frame height)
    final double cropTop = (1.0 - ar) / 2.0;

    double normX(double modelX) => modelX; // no x-crop in portrait
    double normY(double modelY) => modelY * ar + cropTop;

    // Map frame-normalised coords → screen pixels.
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
