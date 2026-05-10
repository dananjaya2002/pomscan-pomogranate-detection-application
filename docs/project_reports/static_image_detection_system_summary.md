# Static Image Detection System Summary

## Overview

The static image detection module performs one-shot pomegranate ripeness detection on a still image selected from the camera or gallery. It uses a Float32 TensorFlow Lite model and returns class-labeled bounding boxes (ripe, semi_ripe, unripe) overlaid on the original image.

The pipeline runs in this order:

1. User opens the static scan screen.
2. User selects image source (Camera or Gallery).
3. App loads and validates image bytes.
4. App initializes the static TFLite model (if not already initialized).
5. Image is letterboxed and converted to Float32 input tensor.
6. Inference is executed.
7. Raw YOLO-style output is decoded.
8. Confidence filtering + NMS are applied.
9. Final detections are mapped back to original image coordinates.
10. Overlay painter draws boxes + labels on the displayed image.

## Entry Point and UI Flow

The Static Scan feature is launched from the home page via the Open Static Scan (Float32) action. That navigates to the static detection page.

On the static page:

- The user presses Camera or Gallery.
- The image picker returns a file path.
- The page resets previous detections and messages.
- Detection starts immediately for the new image.

The page keeps local state for:

- Selected image file.
- Detection results list.
- Processing/loading flags.
- Natural image size (used for correct overlay mapping).
- Result message (for empty-detection and error feedback).

## Model Selection and Initialization

The static pipeline uses:

- Model asset: assets/models/pomegranate_detection_best_float32.tflite

This is different from real-time mode, which uses an int8 model. Static mode intentionally uses the Float32 model for better still-image quality.

Initialization details:

- A dedicated static model provider creates a ModelDataSource with the static model path.
- The app calls the static model init provider before inference.
- Interpreter tensors are allocated during initialization.
- The input and output tensor shapes are read dynamically from the model.

This dynamic tensor-shape reading makes the pipeline more robust to model export differences.

## Input Acquisition and Validation

After image selection:

1. The app reads image bytes from the selected file.
2. If bytes are empty, it throws an error.
3. The image is decoded to obtain natural width and height.
4. If decode fails or dimensions are invalid, it throws an error.

The decoded natural size is preserved so overlay coordinates can align correctly on the displayed image.

## Preprocessing Pipeline

The repository preprocesses static image bytes before inference.

### 1) Decode

The package:image decoder converts compressed image bytes (e.g., JPG/PNG) into pixel data.

### 2) Letterbox resize

The model expects a square input (inputSize x inputSize, default 640 x 640). To preserve aspect ratio:

- Compute scale factor to fit source image inside square canvas.
- Resize source image using linear interpolation.
- Place resized image centered on a gray background (114,114,114).
- Record letterbox metadata:
  - original width/height
  - scale
  - horizontal/vertical padding (padX/padY)
  - model input size

### 3) Float32 tensor conversion

The letterboxed image is converted to a flat Float32List in HWC RGB order:

- For each pixel: R/255, G/255, B/255
- Value range becomes [0,1]
- Flat length must be inputSize x inputSize x 3

## Inference Execution

The model data source performs the following checks and operations:

1. Ensure interpreter is initialized.
2. Validate input tensor length exactly matches expected shape.
3. Reshape flat input to [1, inputSize, inputSize, 3].
4. Allocate output tensor buffer using runtime output rows/cols.
5. Run interpreter.

If shape mismatch occurs, it throws an explicit error message indicating tensor mismatch.

## Output Decoding (YOLO-Style)

The detection repository decodes model output assuming YOLO-style rows per anchor:

- Row 0: center x
- Row 1: center y
- Row 2: width
- Row 3: height
- Remaining rows: class scores

For each anchor:

1. Find max class score and class index among available classes.
2. Reject candidate if score < confidence threshold.
3. Convert center-format box to corner-format:
   - x1 = cx - w/2
   - y1 = cy - h/2
   - x2 = cx + w/2
   - y2 = cy + h/2
4. Normalize by model input size.
5. Clamp coordinates to [0,1].

Class labels are mapped using:

- ripe
- semi_ripe
- unripe

## Letterbox-to-Original Coordinate Remapping

Because inference runs on a letterboxed square image, predicted boxes must be mapped back to original-image space.

The repository uses saved letterbox metadata to reverse padding and scaling:

- Convert normalized model coordinates back to model pixel space.
- Subtract padX/padY.
- Divide by scale.
- Normalize by original width/height.
- Clamp final values to [0,1].

This remapping prevents misplaced boxes and ensures alignment with the original aspect ratio image.

## Postprocessing: Sorting, NMS, and Limits

After decoding:

1. Candidates are sorted by descending confidence.
2. Non-Maximum Suppression (NMS) removes overlapping duplicate boxes.
3. IoU threshold is used to suppress boxes that overlap too much with higher-confidence boxes.
4. Final detections are truncated to maxDetections.

Default thresholds/constants:

- confidenceThreshold: 0.45
- iouThreshold: 0.50
- maxDetections: 10

## Data Structures Returned to UI

Each detection contains:

- BoundingBox (x1, y1, x2, y2) normalized to [0,1]
- Label string
- Confidence score [0,1]
- Enum class type

Confidence percentage shown in UI is computed by rounding confidence x 100.

## Rendering and Overlay Logic

The page renders the selected image and overlay in a shared coordinate context:

- A FittedBox contains a SizedBox set to natural image width/height.
- Image and CustomPaint overlay are stacked inside that exact same sized box.
- Overlay painter multiplies normalized coordinates by canvas width/height.

Since image and painter share identical dimensions, no additional transform matrix is needed for drawing.

Painter visuals include:

- Semi-transparent class-colored fill.
- Rounded rectangle border.
- Corner bracket accents.
- Label pill with title-cased class name + confidence percentage.

Class colors:

- ripe: green
- semi_ripe: blue
- unripe: red

## User Feedback and Error Handling

During detection:

- Circular loader appears while processing.
- Loading card appears while model initialization is in progress.

When no detections:

- Result message: No fruit detected in this image.

Error categorization:

1. Invalid/empty image decode errors -> user told to use a valid JPG/PNG.
2. Tensor/shape mismatch errors -> user warned about model export mismatch.
3. Unknown errors -> generic detection failed message.

This gives clearer failure reasons and reduces user confusion.

## Architectural Layering

The static detection path follows clean layering:

- Presentation: static detection page and painter
- Providers: model/use-case/repository wiring
- Domain: use case + repository contract
- Data: model data source + repository implementation

This separation improves maintainability and allows independent changes to UI, model execution, and postprocessing logic.

## Practical Strengths of Current Implementation

- Uses dedicated float32 static model for quality.
- Reads tensor shapes dynamically at runtime.
- Applies proper letterbox preprocessing and reverse mapping.
- Uses confidence filtering + NMS for cleaner outputs.
- Provides targeted user-visible error messages.
- Keeps overlay geometry aligned with displayed image dimensions.

## Important Note

The static call path currently passes width and height arguments through the use-case and repository signature, but preprocessing is based on decoded bytes and model metadata; those width/height parameters are not currently used in computation.

This does not break functionality, but it is useful to know for future refactoring or API cleanup.
