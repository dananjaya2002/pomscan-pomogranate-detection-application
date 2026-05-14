# Pomegranate Detection — Flutter Mobile App

A Flutter application for detecting pomegranate fruits and diagnosing common pomegranate diseases using on-device TensorFlow Lite models. This repository contains the mobile app, assets, model files, and integration tests used in the final year project.

## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture & Models](#architecture--models)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Testing](#testing)
- [Contributing](#contributing)
- [License & Contact](#license--contact)

## Overview

This app enables farmers and agronomists to capture images of pomegranate plants and receive near-instant inference locally on the device. It bundles optimized TensorFlow Lite models for object detection and disease classification and a lightweight UI for capturing images, running inference, and viewing results.

## Key Features

- On-device object detection for pomegranate fruits
- Disease classification using a dedicated TFLite model
- Support for camera capture and gallery image selection
- Small, optimized TFLite models for fast inference and reduced battery use
- Integration and unit tests for core inference and UI flows

## Architecture & Models

- App: Flutter (Dart) mobile application with platform integrations for Android and iOS.
- Models: Stored in the `models/` directory:
  - `pomegranate_detection_best_float32.tflite`
  - `pomegranate_detection_best_int8.tflite`
  - `pomegranate_disease.tflite`
- Labels: `models/labels.txt` maps class indices to human-readable labels.
- Content data: `assets/content/` holds metadata and mapping JSON files used by the UI.

## Quick Start

Prerequisites

- Flutter SDK (stable channel) installed and on PATH
- Android SDK / Android Studio for building Android apps
- Xcode (macOS) for building iOS apps (optional)

Setup

1. Clone the repository:
```bash
	git clone <repo-url>
	cd flutter_application_1
```
2. Install dependencies:
```bash
	flutter pub get
```
3. Run on a connected device or emulator:
```bash
	flutter run
```
4. Build a release APK (Android):
```bash
	flutter build apk --release
```
## Usage

- Launch the app and grant camera/storage permissions when prompted.
- Choose between camera capture or gallery selection.
- The app will run object detection to locate pomegranate fruit, then run disease classification on the detected crop image.
- Results include bounding boxes, predicted labels, and confidence scores, along with guidance from the built-in content JSONs.

## Testing

- Run unit and widget tests:
```bash
  flutter test test/unit 
```
- Run integration tests:
```bash
  flutter test integration_test  
```
Refer to the `integration_test/` directory for test examples.

- Run system tests:
```bash
  flutter test test/system 
```  
## Contributing

Contributions, bug reports, and feature requests are welcome. Please open an issue first to discuss larger changes, then submit a pull request with a clear description and tests where applicable.

## License & Contact

This project is delivered as part of an academic final year project.

For questions or collaboration, contact the project owner or open an issue in this repository.

---

Project structure highlights:

- `lib/` — main app source code
- `models/` — TFLite models and labels
- `assets/content/` — JSON content used by the UI
- `integration_test/` — end-to-end tests

