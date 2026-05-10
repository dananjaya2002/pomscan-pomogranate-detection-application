# PUSL3190 Interim Report — Content Draft
**Project Title:** Real-Time Pomegranate Ripeness and Disease Detection Mobile Application  
**Student Name:** [Your Full Name]  
**Student ID:** [Your Student ID]  
**Supervisor:** [Supervisor Name]  
**Date:** March 2026  

> **How to use this file:** This document contains all relevant content organised by the required report sections. Copy, expand or reformat sections as needed when writing your final report in the DOCX template.

---

## Chapter 01 — Introduction

### 1.1 Introduction

Agriculture plays a critical role in Sri Lanka's economy, with fruit cultivation contributing substantially to both local food production and export value. Among these crops, pomegranate (*Punica granatum*) has emerged as a high-value fruit due to its nutritional benefits and growing market demand. Sri Lankan varieties such as Lanka Red and Malee Pink have unique visual characteristics distinct from globally studied cultivars, yet lack localised automated tools for quality assessment.

Recent advancements in computer vision and machine learning have demonstrated great potential in automating agricultural monitoring. However, most existing systems depend on cloud-based processing or high-end hardware, both of which are often unaffordable and impractical for small-scale farmers in rural Sri Lanka, where internet connectivity is limited and computational resources are constrained.

This project, branded **PomeScan**, addresses these challenges by developing a lightweight, real-time mobile application integrated with optimised on-device machine learning models. The system enables farmers to assess pomegranate ripeness and detect diseases without relying on expensive infrastructure or constant internet connectivity.

### 1.2 Problem Definition

Fruit quality assessment in Sri Lanka currently relies on manual inspection methods that are inefficient and error-prone. Farmers — particularly those in rural regions — experience significant financial losses due to:

- Improper harvesting timing due to inaccurate ripeness estimation
- Poor storage decisions resulting from undetected early-stage diseases
- Diseases spreading rapidly within crops before detection

Furthermore, there is a critical absence of localised datasets and automated tools specifically adapted to Sri Lankan pomegranate varieties (Lanka Red, Malee Pink), further reducing the accuracy and applicability of existing machine learning models when deployed locally.

Existing technological solutions that attempt to address these problems depend heavily on cloud-based inference, high-end hardware, or lab-controlled conditions — making them unaffordable and impractical for the target user base.

### 1.3 Project Objectives

The primary objectives of this project are:

1. To develop and optimise lightweight ML models (YOLOv8, MobileNet/EfficientNet) for detecting pomegranate fruits, classifying ripeness stages (unripe, semi-ripe, ripe), and identifying disease symptoms.
2. To integrate trained models into a Flutter-based mobile application with on-device inference using TensorFlow Lite.
3. To design a bounding-box and label overlay interface that displays ripeness and disease information directly on the live camera feed.
4. To evaluate model performance based on detection accuracy, latency, and real-time frame rates on mid-range Android devices.
5. To deliver an affordable, offline-capable mobile solution that enhances productivity, reduces waste, and supports Sri Lankan farmers in low-resource agricultural environments.

---

## Chapter 02 — System Analysis

### 2.1 Facts Gathering Techniques

The following fact-gathering methods were employed during requirements analysis:

- **Literature Review:** A systematic review of recent publications (Scopus, IEEE Xplore, arXiv, Kaggle) focused on lightweight object detection, mobile machine learning, and agricultural automation. Key works include YOLO-Granada (Zhao et al., 2024), YOLO-MSNet (Xu et al., 2025), and Al Ansari (2024).
- **Domain Expert Consultation:** Collaboration with Ms. L. G. I. Samanmalee, Assistant Director of Agriculture, Department of Agriculture, who provided insights into pomegranate cultivation, local variety characteristics, and dataset images.
- **Field Observation:** Analysis of real-world farming conditions in Sri Lanka to understand lighting variability, background diversity, and user context for the mobile application.
- **Existing System Analysis:** Evaluation of available mobile and cloud-based fruit detection tools to identify their limitations in offline, low-resource settings.

### 2.2 Existing System

Several systems currently exist for fruit ripeness and disease detection:

| System | Approach | Limitation |
|---|---|---|
| YOLO-Granada (Zhao et al., 2024) | Lightweight YOLOv5/ShuffleNet on Android | Uses non-Sri Lankan datasets; no AR interface |
| YOLO-MSNet (Xu et al., 2025) | Pruned YOLOv11n for pomegranate detection | Not fine-tuned for SR varieties; lab-evaluated |
| AlexNet Android App (Al Ansari, 2024) | AlexNet for leaf disease identification | Static image input; no real-time inference |
| General cloud-based agri-AI tools | Cloud inference | Internet-dependent; unusable offline |

### 2.3 Drawbacks of the Existing System

1. **Regional Dataset Mismatch:** Existing models are trained on datasets from other regions and do not account for the unique colour, texture, and shape of Sri Lankan pomegranate varieties (Lanka Red, Malee Pink).
2. **Cloud Dependency:** Most solutions require internet connectivity for inference, making them unusable in rural agricultural environments with poor connectivity.
3. **Hardware Requirements:** High-end hardware requirements make existing systems economically inaccessible to small-scale farmers.
4. **Limited User Experience:** Current systems prioritise detection accuracy over practical farmer usability, with few offering intuitive, real-time visual overlays.
5. **No Field Validation:** Most evaluations occur in controlled laboratory settings, with limited real-world field testing on low-resource devices.
6. **Incomplete Coverage:** No system addresses the combined needs of real-time ripeness classification and disease detection specifically for Sri Lankan varieties in a single mobile application.

---

## Chapter 03 — Requirements Specification

### 3.1 Functional Requirements

| ID | Requirement |
|---|---|
| FR-01 | The system shall capture a live camera feed and perform real-time pomegranate fruit detection using an on-device TFLite model. |
| FR-02 | The system shall classify each detected fruit into one of three ripeness categories: **unripe**, **semi-ripe**, or **ripe**. |
| FR-03 | The system shall render bounding-box overlays with colour-coded labels directly on the live camera preview. |
| FR-04 | The system shall display a confidence score (percentage) alongside each detection label. |
| FR-05 | The system shall support static image detection from the device gallery or camera capture. |
| FR-06 | The system shall display an FPS (frames per second) counter during live detection. |
| FR-07 | The system shall provide informational content about pomegranate diseases, harvesting, and plantation via a Knowledge Base section. |
| FR-08 | The system shall allow users to configure camera resolution, processing speed, and inference thresholds via a Settings screen. |
| FR-09 | The system shall operate fully offline without any cloud connectivity requirement. |

### 3.2 Non-Functional Requirements

| ID | Requirement |
|---|---|
| NFR-01 | The application must operate offline with minimal latency (<500ms per inference on mid-range Android devices). |
| NFR-02 | The application must run smoothly on mid-range Android devices (Android 10+, 4GB+ RAM). |
| NFR-03 | The system should achieve ≥95% precision/recall for fruit detection and ≥90% accuracy for ripeness classification on the validation dataset. |
| NFR-04 | The application must achieve real-time performance of ≥20 FPS on target devices. |
| NFR-05 | Combined ML model files must be <100MB for practical on-device deployment. |
| NFR-06 | The UI must be intuitive and require minimal training for non-technical agricultural users. |
| NFR-07 | App state must be preserved across lifecycle changes (backgrounding, resuming). |

### 3.3 Hardware / Software Requirements

**Development Hardware:**
- Personal laptop for model training and application development (no external infrastructure required)

**Target Hardware:**
- Android smartphones, Android 10+, minimum 4GB RAM (mid-range devices)

**Software Tools:**
- Flutter SDK (Dart) — mobile application development
- TensorFlow / PyTorch — ML model training and optimisation
- TensorFlow Lite — on-device inference
- Python + OpenCV + Jupyter Notebook — model experimentation
- VS Code with Dart/Flutter extensions — IDE
- Git / GitHub — version control

### 3.4 Networking Requirements

The system is **designed to operate fully offline**. No networking requirements exist for the core detection functionality. Network access is only needed during development for package management and dataset retrieval.

---

## Chapter 04 — Feasibility Study

### 4.1 Operational Feasibility

The proposed system is operationally feasible for the following reasons:

- **Established technology:** Flutter has proven cross-platform mobile deployment capability; TensorFlow Lite is the industry-standard for on-device inference.
- **Target user accessibility:** The application is designed for a single-screen workflow — open app, point camera at fruit — requiring minimal technical knowledge from farmers.
- **Offline operation:** Full offline capability eliminates dependency on rural internet infrastructure.
- **Collaboration support:** The Department of Agriculture has confirmed collaboration for dataset compilation, ensuring domain knowledge integration.

### 4.2 Economical Feasibility

This project requires **zero direct financial expenditure:**

- **Hardware:** Development conducted on personal laptop; no cloud compute costs.
- **Dataset:** Primary dataset self-created from locally grown Sri Lankan pomegranates (in collaboration with the Department of Agriculture); supplemented by open-source Kaggle datasets at no cost.
- **Software:** All tools (Flutter, TensorFlow, PyTorch, Python) are open-source and freely available.
- **Deployment:** No server infrastructure, hosting, or recurring costs required.

The final deliverable will also be **zero-cost to end users (farmers)**, as it runs entirely on their existing mid-range smartphones.

### 4.3 Technical Feasibility

Recent published research confirms the technical viability of the approach:

- **Lightweight detection on mobile:** YOLO-Granada (Zhao et al., 2024) and YOLO-MSNet (Xu et al., 2025) have demonstrated that pruned YOLO models can run efficiently on Android devices with accuracy >90%.
- **TFLite deployment:** TensorFlow Lite with quantisation can reduce model sizes by 75–90% with minimal accuracy loss, achieving <500ms inference on mid-range hardware.
- **Flutter + TFLite integration:** The `tflite_flutter` package (v0.12.1) provides well-supported bindings for on-device inference in Flutter applications.
- **YUV to RGB preprocessing:** The project implements custom YUV420 → RGB conversion in a background Dart isolate (using Flutter's `compute`) to avoid blocking the main UI thread during inference.

---

## Chapter 05 — System Architecture

### 5.1 Use Case Diagram

> *[Insert Use Case Diagram here — covering: Farmer → View Live Detection, View Ripeness Result, View Disease Info, Configure Settings, Use Knowledge Base; System → Run Inference, Apply NMS, Display BBox Overlay]*

**Key actors and use cases:**

- **Farmer (User):**
  - Launch live camera detection
  - View real-time bounding boxes with ripeness labels
  - Detect fruit from a static gallery image
  - Browse Knowledge Base (diseases, harvesting, plantation)
  - Configure camera resolution, processing speed, confidence thresholds
  - View About / app information

- **System (PomeScan App):**
  - Initialise TFLite model from bundled asset
  - Capture camera frames via image stream
  - Preprocess frames (YUV→RGB, resize to 640×640)
  - Run YOLO inference on-device
  - Apply Non-Maximum Suppression (NMS)
  - Render bounding-box overlays on camera preview

### 5.2 Class Diagram of Proposed System

> *[Insert Class Diagram here]*

**Key domain classes and relationships:**

```
Detection
  - BoundingBox box
  - String label
  - double confidence
  - DetectionClass cls { ripe, semiRipe, unripe }

DetectionState
  - List<Detection> detections
  - double fps
  - bool isProcessing

AppSettings
  - CameraQuality cameraQuality
  - PerformanceMode performanceMode
  - ModelInputSize modelInputSize
  - double confidenceThreshold
  - double iouThreshold
  - bool showFps

FramePreprocessInput
  - Uint8List yBytes, uBytes, vBytes
  - int width, height, modelInputSize, preprocessSize
  - bool isBgra
```

**Key providers (Riverpod):**
- `modelInitProvider` — async initialisation of TFLite interpreter
- `cameraProvider` — camera lifecycle state (Uninitialised / Initialising / Ready / Error)
- `detectionProvider` — real-time detection state (detections list, FPS, isProcessing flag)
- `settingsProvider` — persisted app settings via SharedPreferences

### 5.3 ER Diagram

> *[Insert ER Diagram if applicable — the application is primarily stateless / file-asset-driven with local preference persistence only. No relational database is used.]*

**Data persistence:**
- `SharedPreferences` — stores user settings (camera quality, performance mode, confidence threshold)
- Bundled JSON assets — `diseases.json`, `harvesting.json`, `plantation.json` provide knowledge-base content
- Bundled TFLite model — `pomegranate_detect.tflite` and `labels.txt` in `assets/models/`

### 5.4 High-Level Architectural Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        PomeScan App                         │
│                                                             │
│  ┌──────────┐   ┌──────────────┐   ┌─────────────────────┐ │
│  │ Splash   ├──►│  Home Page   ├──►│  Detection Page     │ │
│  │  Page    │   │  (Dashboard) │   │  ┌───────────────┐  │ │
│  └──────────┘   └──────┬───────┘   │  │ CameraPreview │  │ │
│                        │           │  │ BBoxOverlay   │  │ │
│               ┌────────┼────────┐  │  │ FPS Counter   │  │ │
│               ▼        ▼        ▼  │  │ Dashboard     │  │ │
│           Settings  About   Info   │  └───────────────┘  │ │
│            Page     Page  List Page│                      │ │
│                                   └──────────────────────-┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Detection Pipeline                      │   │
│  │  Camera Stream → Frame Skip → Isolate Preprocess    │   │
│  │  → TFLite Inference → NMS → Riverpod State Update  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────┐  ┌───────────────────────────────┐   │
│  │  Bundled Assets  │  │  Persisted Settings            │   │
│  │  • .tflite model │  │  (SharedPreferences)           │   │
│  │  • labels.txt    │  │  • CameraQuality               │   │
│  │  • diseases.json │  │  • PerformanceMode             │   │
│  │  • harvesting.json│  │  • ModelInputSize              │   │
│  │  • plantation.json│  │  • Confidence / IoU thresholds│   │
│  └──────────────────┘  └───────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Clean Architecture Layers:**
- **Presentation Layer:** Flutter widgets, Riverpod providers (`features/*/presentation/`)
- **Domain Layer:** Entities (`Detection`, `BoundingBox`, `AppSettings`), use cases (`RunDetectionUseCase`)
- **Data Layer:** Data sources (`ModelDatasource`), repositories (`DetectionRepositoryImpl`, `SettingsRepository`)
- **Core:** Shared constants (`AppConstants`), theme (`AppTheme`), utilities (`FramePreprocessor`, `BoxTransformer`), error types

### 5.5 Networking Diagram

Not applicable. The system operates fully offline. No network communication occurs during normal operation.

---

## Chapter 06 — Development Tools and Technologies

### 6.1 Development Methodology

The project adopts an **Agile-inspired iterative development approach**, structured around the university semester timeline (November 2025 – October 2026). Key aspects:

- **Sprint-based cycles:** Short development iterations focusing on one component at a time (e.g., camera integration → TFLite integration → overlay rendering → UI polishing)
- **Continuous validation:** Each sprint ends with a working prototype and performance benchmarking
- **Iterative model refinement:** ML model fine-tuning proceeds in parallel with application development
- **Milestone-driven:** Aligned with key academic deadlines (Proposal → PID → Interim Report → Final Submission)

### 6.2 Programming Languages and Tools

| Tool / Language | Role |
|---|---|
| **Dart / Flutter** | Cross-platform mobile application development |
| **Python** | ML model training, dataset preprocessing, augmentation |
| **TensorFlow / Keras** | Model training and optimisation |
| **PyTorch** | Supplementary model experimentation |
| **OpenCV** | Image preprocessing and dataset preparation |
| **Jupyter Notebook** | Model experimentation and analysis |
| **VS Code** | Primary IDE (with Dart/Flutter extensions) |
| **Git / GitHub** | Version control and source code management |
| **Android Studio** | Android build tooling and emulator |

### 6.3 Third-Party Components and Libraries

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management (providers for camera, detection, settings) |
| `tflite_flutter` | ^0.12.1 | On-device TFLite inference (Dart bindings) |
| `camera` | ^0.10.5+9 | Camera preview and image stream access |
| `image` | ^4.2.0 | Pure-Dart image processing for YUV→RGB conversion in isolates |
| `image_picker` | ^1.1.2 | Gallery/camera image selection for static detection |
| `permission_handler` | ^11.3.1 | Runtime camera permission handling |
| `shared_preferences` | ^2.3.2 | Persistent local storage for user settings |
| `equatable` | ^2.0.5 | Value equality for domain entities |
| `logger` | ^2.4.0 | Structured logging for debugging |

### 6.4 Algorithms

#### Object Detection — YOLO (You Only Look Once)
The application uses a **YOLOv8-based** model optimised and converted to TensorFlow Lite format (`pomegranate_detect.tflite`).

- **Input:** 640×640×3 normalised RGB tensor
- **Output:** Detection tensor containing bounding boxes (cx, cy, w, h in normalised [0,1] coordinates) and class scores for 3 classes
- **Classes:** `ripe` (index 0), `semi_ripe` (index 1), `unripe` (index 2)
- **Confidence threshold:** 0.45 (configurable via Settings)
- **Max detections:** 10 per frame

#### Non-Maximum Suppression (NMS)
After YOLO inference, NMS is applied to eliminate overlapping duplicate detections:
- **IoU threshold:** 0.50 (configurable via Settings)
- Applied per-frame to the raw YOLO output before Riverpod state update

#### Frame Preprocessing Pipeline
```
Camera Frame (YUV420/NV21 on Android, BGRA8888 on iOS)
    │
    ▼
Background Isolate (Flutter compute)
    │
    ├─ YUV420 → RGB step-sampling (configurable preprocessSize: 320/416/640)
    │   OR
    └─ BGRA8888 → RGB copy (iOS)
    │
    ▼
Centre-crop to square aspect ratio
    │
    ▼
Resize to 640×640
    │
    ▼
Normalise to Float32 [0.0, 1.0]
    │
    ▼
TFLite Interpreter (main isolate)
```

#### FPS Computation
A **rolling window algorithm** (12-frame window) is used to compute current FPS:
$$FPS = \frac{windowSize - 1}{newestTimestamp - oldestTimestamp} \times 1000$$

This reflects real-time throughput rather than a cumulative average, providing accurate live performance feedback.

#### Bounding Box Coordinate Transformation
Detection boxes from YOLO (normalised [0,1] in model input space) are transformed to screen pixel coordinates using `BoxTransformer`, which accounts for: camera aspect ratio, centre-crop square applied during preprocessing, and screen dimensions.

---

## Chapter 07 — Implementation Progress

### 7.1 Development Environment Setup

The development environment has been fully configured:

- **Flutter SDK** installed and configured with Dart
- **Android build toolchain** (Gradle, Android SDK) configured via `android/build.gradle.kts`
- **TFLite model** (`pomegranate_detect.tflite`, 3 classes: ripe/semi_ripe/unripe) bundled as a Flutter asset
- **Labels file** (`labels.txt`) and **knowledge-base JSON files** bundled under `assets/`
- **Clean Architecture** folder structure established under `lib/` with separate `core/`, `features/` directories
- **Riverpod** state management layer wired and functional
- **GitHub repository** set up for version control (`dananjaya2002/pomogranate-detection-application-flutter`)

### 7.2 Implemented Features

At the time of this interim submission, the following features have been implemented as a working prototype:

#### ✅ Application Shell & Navigation
- **Splash Screen** (`SplashPage`) — branded loading screen with navigation to Home
- **Home Dashboard** (`HomePage`) — scrollable dashboard with hero scan card, Knowledge Base section, and Quick Access grid
- **App branding:** Application named "PomeScan — Pomegranate Quality AI" with a dark theme

#### ✅ TFLite Model Integration
- YOLOv8 model loaded from bundled asset via `modelInitProvider`
- TFLite interpreter initialised asynchronously on app start to avoid UI jank
- Three detection classes wired: `ripe`, `semi_ripe`, `unripe`
- Configurable confidence threshold (default: 0.45) and IoU threshold (default: 0.50)

#### ✅ Live Camera Detection (`DetectionPage`)
- Full-screen camera preview using the `camera` package
- Camera initialised via `cameraProvider` with lifecycle management (pause on background, resume on foreground)
- Image stream captured at camera resolution, processed per configured frame-skip rate
- **Frame preprocessing** (`FramePreprocessor`): YUV420 → RGB → centre-crop → resize to 640×640 → Float32 normalisation, executed in a **background Dart isolate** via `compute` to avoid dropping UI frames
- iOS BGRA8888 format also handled
- **Backpressure guard:** New frames dropped if inference is still running on the previous frame

#### ✅ Detection Pipeline
- YOLO output tensor parsed to extract bounding boxes and class scores
- **Non-Maximum Suppression (NMS)** implemented and applied per frame
- `DetectionState` updated via Riverpod `StateNotifier` after each inference cycle
- **Rolling FPS counter** (12-frame window) computed and displayed live

#### ✅ Bounding-Box Overlay (`BBoxOverlay`)
- `CustomPainter`-based transparent overlay rendered on top of camera preview
- Bounding boxes drawn with colour-coded labels:
  - 🟩 Green — `ripe`
  - 🔵 Blue — `semi_ripe`
  - 🔴 Red — `unripe`
- Each detection shows label + confidence percentage (e.g., "ripe 94%")
- Corner L-bracket visual style for clean multi-detection rendering
- `RepaintBoundary` used to isolate overlay repaints from camera layer

#### ✅ Detection Dashboard (`DetectionDashboard`)
- Bottom panel displaying current detection results summary during live detection

#### ✅ FPS Counter (`FpsCounter`)
- Live FPS badge displayed in the top-right corner of the detection screen

#### ✅ Static Image Detection (`StaticDetectionPage`)
- Allows users to select an image from device gallery or capture a new photo
- Runs the same YOLO inference pipeline on the selected static image
- Renders detection bounding-box overlay on the static image result

#### ✅ Settings Screen (`SettingsPage`)
- **Camera Resolution:** Low / Medium / High (affects camera initialisation quality)
- **Processing Speed:** Eco / Balanced / Performance (controls frame-skip rate)
- **Preprocessing Quality:** 320px / 416px / 640px (controls YUV sampling resolution)
- **Confidence Threshold:** Adjustable slider (affects minimum detection score)
- **IoU Threshold:** Adjustable slider (affects NMS aggressiveness)
- **Show FPS toggle:** Enable/disable FPS counter display
- All settings persisted locally via `SharedPreferences`

#### ✅ Knowledge Base (`InfoListPage`)
- Informational content loaded from bundled JSON assets:
  - `diseases.json` — pomegranate disease information
  - `harvesting.json` — harvesting guidance
  - `plantation.json` — plantation and cultivation tips
- Accessible from the Home dashboard

#### ✅ About Page
- Application information screen

### 7.3 Code Snippets / Architecture Notes

#### Frame preprocessing in background isolate (core inference pipeline):
```dart
// In DetectionNotifier — runs preprocessing on a background isolate
// to prevent dropping camera frames on the main thread
final input = FramePreprocessInput(
  yBytes: frame.planes[0].bytes,
  uBytes: frame.planes[1].bytes,
  vBytes: frame.planes[2].bytes,
  width: frame.width,
  height: frame.height,
  modelInputSize: AppConstants.inputSize,  // 640
  preprocessSize: settings.modelInputSize.size,
);
final tensorBuffer = await compute(preprocessCameraFrame, input);
```

#### Riverpod provider structure:
```dart
// Async model init provider — loads TFLite model once at startup
final modelInitProvider = FutureProvider<void>((ref) async {
  // TFLite interpreter loaded from bundled asset
});

// Camera state notifier — manages camera lifecycle
final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>(...);

// Detection notifier — owns the inference loop
final detectionProvider = StateNotifierProvider<DetectionNotifier, DetectionState>(...);
```

#### Detection entity (domain layer):
```dart
final class Detection extends Equatable {
  final BoundingBox box;     // normalised [0,1] coordinates
  final String label;        // 'ripe', 'semi_ripe', 'unripe'
  final double confidence;   // [0.0, 1.0]
  final DetectionClass cls;  // strongly-typed enum
}
```

### 7.4 Challenges Encountered and Solutions

| Challenge | Solution Applied |
|---|---|
| **YUV420 → RGB conversion blocking UI thread** | Moved preprocessing to a background Dart isolate using Flutter's `compute()` function; all input types constrained to primitives/`Uint8List` for safe isolate serialisation |
| **Camera and model both need to be ready before detection starts** | Implemented dual-gate logic: `ref.listen` on both `modelInitProvider` and `cameraProvider`; detection stream only starts when both are in a ready state |
| **Frame rate degradation under heavy load** | Implemented frame-skip throttle (configurable `frameSkip`) and a backpressure guard that drops new frames while inference from the previous frame is still running |
| **Bounding box coordinates misaligned with camera preview** | Implemented `BoxTransformer` that correctly maps YOLO normalised [0,1] coordinates to screen pixels, accounting for camera aspect ratio and the centre-crop applied during preprocessing |
| **App lifecycle (backgrounding) causing camera/stream errors** | Implemented `WidgetsBindingObserver` to stop the image stream and pause the camera when the app is backgrounded, and restart cleanly when resumed |
| **iOS vs Android camera format differences** | `FramePreprocessInput` accepts both YUV420 (Android, via separate Y/U/V plane bytes) and BGRA8888 (iOS, via combined byte array) with format detection at runtime |

### 7.5 Current System Limitations

1. **Detection only — no disease classification yet:** The current TFLite model classifies ripeness only (ripe/semi_ripe/unripe). Disease detection (a core project objective) has not yet been implemented and is pending custom dataset development.
2. **Prototype model, not fine-tuned:** The current model (`pomegranate_detect.tflite`) is a prototype. The custom Sri Lankan pomegranate dataset has not yet been collected and the model has not been fine-tuned on local varieties (Lanka Red, Malee Pink).
3. **No AR overlays:** The proposal specified augmented reality (AR) overlays using ARCore. The current implementation uses a `CustomPainter` overlay on the camera preview, which is a simpler (non-AR) approach. Full ARCore/AR integration is planned for a future sprint.
4. **No performance benchmarking completed:** Formal FPS, latency, and memory benchmarking on target mid-range Android devices has not yet been conducted. The Settings screen exposes performance knobs but quantified benchmarks are pending.
5. **UI prototype stage:** The application is at the early prototype stage — core architecture and detection pipeline are functional, but UI design and user experience refinement are ongoing.
6. **No user acceptance testing:** Testing with actual farmers or agricultural extension officers has not yet been conducted.

---

## Chapter 08 — Discussion

### Summary of the Report

This interim report documents the progress made during the first phase of the PomeScan project — a real-time, on-device pomegranate ripeness and disease detection mobile application targeting small-scale farmers in Sri Lanka.

The foundational architecture of the Flutter application has been successfully established, following Clean Architecture principles with Riverpod for state management. The core detection pipeline has been implemented end-to-end: camera frame capture → YUV→RGB preprocessing in a background isolate → TFLite YOLO inference → NMS → real-time bounding-box overlay rendered on the camera preview. Supporting features including static image detection, a configurable settings screen, and a knowledge base have also been completed.

The current application runs as a working prototype with a 3-class ripeness detection model (ripe/semi_ripe/unripe). Several technical challenges around frame preprocessing performance, multi-provider synchronisation, and cross-platform camera format handling have been resolved.

### What Has Changed from the Proposal

| Aspect | Proposal / PID Intention | Current Status / Change |
|---|---|---|
| AR overlays (ARCore) | Specified as a key feature | Not yet implemented; replaced by CustomPainter overlay for now. AR integration deferred to a later sprint. |
| Disease detection | Core objective alongside ripeness | Not yet in model; current model detects ripeness only. Disease classification pending dataset collection. |
| YOLOv8 + MobileNet dual model | Proposed for detection + classification separately | Currently a single combined YOLO model handles both detection and classification of ripeness stages. Architecture may be revisited. |
| Custom Sri Lankan dataset | Primary deliverable | Dataset collection in progress (in collaboration with Dept. of Agriculture). Not yet used for fine-tuning. |
| Performance benchmarking | Success metric | Benchmarking infrastructure in place (FPS counter, configurable settings) but formal benchmarking not yet completed. |

### Future Plans / Upcoming Work

The following activities are planned for the remaining project phases:

1. **Custom Dataset Collection and Annotation**
   - Capture 500–800 images of Sri Lankan pomegranate varieties (Lanka Red, Malee Pink) under diverse field conditions
   - Manual labelling of ripeness categories and disease types
   - Apply augmentation (rotation, scaling, brightness, flipping) to reach 2000+ annotated images
   - Train/validation/test split: 70% / 20% / 10%

2. **Disease Detection Model Development**
   - Extend the model to include disease classification classes
   - Fine-tune YOLOv8 model on the custom Sri Lankan dataset using transfer learning
   - Evaluate with precision, recall, F1-score, and confusion matrix

3. **Model Optimisation and TFLite Conversion**
   - Apply TFLite conversion with int8/float16 quantisation to meet <100MB size target
   - Apply TensorFlow Model Optimization Toolkit pruning where needed
   - Target: <500ms inference latency and ≥20 FPS on mid-range Android devices

4. **AR Interface Integration**
   - Investigate ARCore integration for true augmented reality overlays
   - Alternatively, enhance the existing CustomPainter overlay with more contextual AR-style visual feedback

5. **Performance Benchmarking**
   - Formal FPS, latency, and memory benchmarking on representative mid-range Android devices
   - Document results across performance modes (Eco / Balanced / Performance settings)

6. **UI/UX Refinement**
   - User interface polishing based on design feedback
   - Onboarding flow for first-time farmers

7. **User Acceptance Testing**
   - Testing session with sample farmers or agricultural extension officers from the Department of Agriculture
   - Feedback integration and usability improvements

---

## References

1. Zhao, J., Li, Y., Guo, D., Fan, Y., Wu, X., Wang, X., & Almodfer, R. (2024). YOLO-Granada: A Lightweight Attentioned YOLO for Pomegranates Fruit Detection. https://doi.org/10.21203/rs.3.rs-4005773/v1

2. Xu, L., Li, B., Fu, X., Lu, Z., Li, Z., Jiang, B., & Jia, S. (2025). YOLO-MSNet: Real-Time Detection Algorithm for Pomegranate Fruit Improved by YOLOv11n. *Agriculture, 15*, 1028. https://doi.org/10.3390/agriculture15101028

3. Al Ansari, M. S. (2024). A Machine Learning Approach to Pomegranate Leaf Disease Identification. *International Journal on Recent and Innovation Trends in Computing and Communication, 11*(9). https://doi.org/10.17762/ijritcc.v11i9.9597

4. Kaggle. Pomegranate Fruit Image Dataset. Available: https://www.kaggle.com

---

## Appendix — Project File Structure Reference

```
lib/
├── main.dart                          # App entry point (PomegranateDetectorApp)
├── injection_container.dart           # Dependency injection setup
├── core/
│   ├── constants/app_constants.dart   # Model path, class labels, thresholds, colours
│   ├── errors/failures.dart           # Domain error types
│   ├── theme/app_theme.dart           # Dark theme (AppColors, AppTheme)
│   └── utils/
│       ├── frame_preprocessor.dart    # YUV→RGB→resize→normalise in isolate
│       └── box_transform.dart         # YOLO [0,1] coords → screen pixels
├── features/
│   ├── splash/presentation/pages/splash_page.dart
│   ├── home/presentation/pages/home_page.dart
│   ├── detection/
│   │   ├── domain/
│   │   │   ├── entities/detection.dart       # Detection, BoundingBox, DetectionClass
│   │   │   └── usecases/run_detection_usecase.dart
│   │   ├── data/
│   │   │   ├── datasources/model_datasource.dart
│   │   │   └── repositories/detection_repository_impl.dart
│   │   └── presentation/
│   │       ├── pages/detection_page.dart       # Live camera detection
│   │       ├── pages/static_detection_page.dart # Gallery image detection
│   │       ├── providers/detection_provider.dart
│   │       ├── providers/camera_provider.dart
│   │       └── widgets/
│   │           ├── bbox_overlay.dart           # CustomPainter bounding boxes
│   │           ├── camera_preview_widget.dart
│   │           ├── detection_dashboard.dart
│   │           └── fps_counter.dart
│   ├── settings/
│   │   ├── domain/entities/app_settings.dart
│   │   ├── data/repositories/settings_repository.dart
│   │   └── presentation/
│   │       ├── pages/settings_page.dart
│   │       └── providers/settings_provider.dart
│   ├── info/                          # Knowledge base feature
│   ├── about/                         # About page
└── ...

assets/
├── models/
│   ├── pomegranate_detect.tflite      # YOLOv8 detection model (3 classes)
│   └── labels.txt                     # Class label names
└── content/
    ├── diseases.json                  # Knowledge base: disease info
    ├── harvesting.json                # Knowledge base: harvesting tips
    └── plantation.json                # Knowledge base: plantation guidance
```
