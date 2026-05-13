/// Farmer-friendly UI strings for the PomeScan application.
///
/// These strings are designed for agricultural workers with varying tech literacy.
/// Principles:
/// - Use simple, direct language (8th grade reading level)
/// - Avoid ML jargon: no "inference", "tensor", "model", "classifier"
/// - Use action-oriented phrasing
/// - Include examples and guidance
library;

abstract final class FarmerStrings {
  // ── General ────────────────────────────────────────────────────────────────
  static const String appName = 'PomeScan';
  static const String appSubtitle = 'Check your pomegranates in seconds';

  // ── Ripeness Detection ─────────────────────────────────────────────────────
  static const String ripeScanTitle = 'Scan for Ripeness';
  static const String ripeScanDescription =
      'Find ripe, semi-ripe, and unripe fruits from one photo';
  static const String ripeScanHint =
      'Point camera at pomegranates from about 12 inches away. Best in daylight.';

  static const String detectButton = 'Scan Now';
  static const String retryButton = 'Try Again';
  static const String selectImageButton = 'Pick a Photo';
  static const String takePhotoButton = 'Take Photo';

  // ── Processing Status ──────────────────────────────────────────────────────
  static const String statusPreparing = '📸 Getting ready...';
  static const String statusAnalyzing = '⏳ Analyzing pomegranates...';
  static const String statusProcessing = '⏳ Processing...';
  static const String statusComplete = '✓ Done!';
  static const String statusLoading = '⏳ Loading model...';
  static const String statusReady = '✓ Ready to scan';

  static const String tipAnalysisTime = 'This usually takes 2-3 seconds.';

  // ── Results - Ripeness ─────────────────────────────────────────────────────
  static const String resultsTitle = 'Ripeness Results';
  static const String ripeLabel = 'Ripe';
  static const String semiRipeLabel = 'Semi-ripe';
  static const String unripeLabel = 'Unripe';

  static String resultsSummary(
      int ripeCount, int semiRipeCount, int unripeCount) {
    final total = ripeCount + semiRipeCount + unripeCount;
    if (total == 0) {
      return 'No pomegranates found in this photo. Try a different angle.';
    }
    if (ripeCount > 0) {
      return '🟢 Most are ripe! Ready to harvest soon.';
    }
    if (semiRipeCount > ripeCount) {
      return '🟡 Mix of ripe and unripe. Check again in 2-3 days.';
    }
    return '🔴 Mostly unripe. Check again later.';
  }

  static const String noFruitDetected =
      '😞 No pomegranates found in this photo. Try a different angle or better lighting.';

  // ── Confidence Levels ──────────────────────────────────────────────────────
  static const String confidenceVeryHigh = 'Very confident ✓';
  static const String confidenceHigh = 'Fairly sure ⚡';
  static const String confidenceMedium = 'Somewhat sure';
  static const String confidenceLow = 'Not sure ?';

  static String confidenceDescription(double confidence) {
    if (confidence >= 0.85) return confidenceVeryHigh;
    if (confidence >= 0.70) return confidenceHigh;
    if (confidence >= 0.50) return confidenceMedium;
    return confidenceLow;
  }

  // ── Disease Detection ──────────────────────────────────────────────────────
  static const String diseaseCheckTitle = 'Check for Disease';
  static const String diseaseCheckDescription =
      'Identify common pomegranate diseases from a leaf or fruit photo';
  static const String diseaseCheckHint =
      'Take a clear photo in daylight. Include affected area if possible.';

  static const String diseaseHealthy = 'Healthy';
  static const String diseaseHealthyMessage =
      'No disease detected. The plant looks healthy!';

  static const String diseaseDetected = 'Disease Found';
  static String diseaseFoundMessage(String diseaseName) =>
      'Your plant may have $diseaseName. See treatment options below.';

  static const String viewTreatmentGuide = 'Learn How to Treat';
  static const String treatmentInstructions = 'Treatment Options';

  // ── Errors - Image Related ─────────────────────────────────────────────────
  static const String errorImageInvalid =
      '❌ This image couldn\'t be read. Try a JPG or PNG photo.';
  static const String errorImageEmpty =
      '❌ The image file is empty. Pick a different photo.';
  static const String errorImageLarge =
      '⚠️ This image is very large and might slow down the scan. Smaller photos work better.';
  static const String errorImageDecode =
      '❌ Couldn\'t read this image. Try another photo.';

  // ── Errors - Model/Processing ─────────────────────────────────────────────
  static const String errorProcessing =
      '❌ Something went wrong during scanning. Please try again.';
  static const String errorModelNotReady =
      '⏳ The app is still getting ready. Please wait a moment and try again.';
  static const String errorModelMissing =
      '❌ Detection model is missing. Please reinstall the app.';
  static const String errorOutOfMemory =
      '❌ Not enough memory. Try a smaller photo or close other apps.';
  static const String errorGeneral = '❌ Scanning failed. Please try again.';

  static const String errorSuggestion =
      'Would you like to try a different photo?';
  static const String errorSuggestionRetry =
      'Tap "Try Again" to scan another photo.';

  // ── Errors - Permission ────────────────────────────────────────────────────
  static const String permissionCameraTitle = 'Camera Permission';
  static const String permissionCameraMessage =
      'We need camera access to take photos of your pomegranates. This is only used on your phone.';
  static const String permissionGalleryTitle = 'Photo Library Permission';
  static const String permissionGalleryMessage =
      'We need permission to access your photos. This is only used to find pomegranate photos.';

  // ── Knowledge Base ─────────────────────────────────────────────────────────
  static const String learnDiseases = 'Learn About Diseases';
  static const String learnPlantation = 'Plantation Tips';
  static const String learnHarvesting = 'Harvest Guide';

  static const String diseaseExplanation =
      'Common pomegranate diseases and how to spot them early.';
  static const String plantationExplanation =
      'Best practices for growing healthy pomegranates.';
  static const String harvestingExplanation =
      'When and how to harvest pomegranates at peak ripeness.';

  // ── Settings / About ───────────────────────────────────────────────────────
  static const String settingsTitle = 'Settings';
  static const String aboutTitle = 'About PomeScan';
  static const String helpTitle = 'Help & Tips';

  static const String aboutMessage =
      'PomeScan helps you check pomegranate ripeness and spot diseases quickly. Made for farmers.';
  static const String aboutVersion = 'Version';

  // ── Guidance & Tips ────────────────────────────────────────────────────────
  static const String tipPhotoQuality =
      '💡 Tip: Better photos = better results';
  static const String tipDaylight = '💡 Tip: Scan in daylight or good lighting';
  static const String tipDistance = '💡 Tip: Hold camera 12 inches (30cm) away';
  static const String tipMultiplePhotos =
      '💡 Tip: Take multiple photos for accuracy';
  static const String tipClearView =
      '💡 Tip: Show the fruit clearly, not the whole tree';

  // ── Navigation & Actions ───────────────────────────────────────────────────
  static const String backButton = 'Back';
  static const String homeButton = 'Home';
  static const String nextButton = 'Next';
  static const String skipButton = 'Skip';
  static const String closeButton = 'Close';
  static const String doneButton = 'Done';

  // ── Onboarding ─────────────────────────────────────────────────────────────
  static const String onboardingTitle = 'Welcome to PomeScan!';
  static const String onboardingStep1Title = '📸 Scan for Ripeness';
  static const String onboardingStep1Description =
      'Take a photo of your pomegranates and find out which are ripe and ready to pick.';

  static const String onboardingStep2Title = '🔬 Check for Disease';
  static const String onboardingStep2Description =
      'Identify common diseases early so you can treat them quickly.';

  static const String onboardingStep3Title = '📚 Learn & Grow';
  static const String onboardingStep3Description =
      'Access farming tips, disease guides, and harvest recommendations.';

  static const String onboardingStart = 'Get Started';
}
