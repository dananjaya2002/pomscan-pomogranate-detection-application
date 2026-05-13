# PomeScan User Guide

## 1. Introduction
PomeScan is a mobile assistant for pomegranate farming. It helps you:
- Check fruit ripeness from a photo
- Identify possible diseases from a photo
- Read practical farming guides (diseases, plantation, harvesting)

The app runs inference on-device and is designed for field use.

## 2. Who This Guide Is For
This guide is for:
- Farmers and field officers
- Agricultural students and researchers
- Anyone using PomeScan for ripeness and disease checks

## 3. App Features
- Ripeness Scan: Classifies fruits as Ripe, Semi-ripe, or Unripe
- Disease Scan: Predicts likely disease class from an image
- Knowledge Base: Diseases, Plantation Guide, Harvesting Guide
- Adjustable detection filters in Settings
- About page with project and technology details

## 4. First Launch
1. Open PomeScan.
2. Wait for the splash screen to complete loading.
3. You will be redirected to the Home dashboard.

Notes:
- The splash screen includes an animated loading bar.
- Model initialization can take a short time on first use.

## 5. Home Dashboard Overview
The Home screen is divided into sections:
- Quick Scan:
  - Ripeness Scan card
  - Detect Diseases card
- Knowledge Base:
  - Diseases
  - Plantation Guide
  - Harvesting Guide
- App:
  - Settings
  - About Us

## 6. How To Use Ripeness Scan
1. On Home, tap Start Ripeness Scan.
2. On the Ripeness Detection page, choose an image source:
   - Take Photo
   - Gallery
3. Wait for processing to finish.
4. Review the result overlay and status chips:
   - Ripe
   - Semi-ripe
   - Unripe
5. If ripe fruits are detected, tap Open Harvesting Guide for recommendations.

What you will see:
- Bounding boxes drawn on detected fruits
- Count chips for each ripeness category
- A no-detection message if no fruit is found

## 7. How To Use Disease Scan
1. On Home, tap Start Disease Scan.
2. Choose Camera or Gallery.
3. Wait for Analysing image status to complete.
4. Review the result card for predicted disease and guidance.
5. Tap Reset to clear and run a new scan.

Tips:
- Use clear, well-lit images.
- Keep the target leaf or fruit centered and in focus.

## 8. Knowledge Base Usage
From Home, open one of the following:
- Diseases
- Plantation Guide
- Harvesting Guide

In each section:
1. Tap a list item to open full details.
2. Read description and practical tips.
3. Return using the back button.

## 9. Settings
Open Settings from Home to tune detection behavior.

Available controls:
- Min Confidence
  - Higher value: fewer but more confident detections
  - Lower value: more detections, including weaker predictions
- Max Detections
  - Limits how many boxes appear at once

Information section includes:
- Model type
- Input size
- Framework
- App version

Settings are saved automatically.

## 10. Recommended Photo Capture Practices
For better results:
- Capture in daylight or strong even lighting
- Avoid motion blur
- Avoid heavy shadows and overexposure
- Fill most of the frame with the fruit or affected leaf area
- Avoid cluttered backgrounds when possible

## 11. Common Messages And Meaning
- No image selected yet.
  - You have not chosen a photo yet.
- Loading detection model...
  - Model is being prepared for inference.
- No fruit detected in this image.
  - No valid fruit object passed the confidence threshold.
- Image could not be processed. Please use a valid JPG or PNG image.
  - File may be corrupted, unsupported, or unreadable.
- Detection failed. Please try again.
  - A runtime issue occurred. Retry with another image.

## 12. Troubleshooting
If scan results are poor:
1. Retake the photo in better lighting.
2. Move closer to the fruit or symptom region.
3. Ensure image is sharp and not compressed heavily.
4. Lower Min Confidence in Settings slightly.
5. Retry using Gallery with a high-quality image.

If the app seems slow:
1. Close other heavy apps.
2. Restart PomeScan.
3. Use smaller batches of scans instead of continuous retries.

If camera or gallery does not open:
1. Check app permissions in Android settings.
2. Allow camera and storage/media access.
3. Reopen the app and try again.

## 13. Limitations
- Predictions are AI estimates, not guaranteed diagnoses.
- Accuracy depends strongly on image quality and field conditions.
- Use results as decision support, not as the only source of truth.

## 14. Safety And Best Practice
- Confirm critical decisions with agronomy experts.
- Use multiple observations over time, not a single photo.
- Combine scan results with field symptoms and local conditions.

## 15. Quick Workflow Reference
1. Open app
2. Choose Ripeness Scan or Disease Scan
3. Capture/select a clear image
4. Wait for processing
5. Review result and guidance
6. Open related Knowledge Base content
7. Adjust Settings if needed

## 16. Version
- Guide Version: 1.0
- App Version: 1.0.0
- Last Updated: May 10, 2026
