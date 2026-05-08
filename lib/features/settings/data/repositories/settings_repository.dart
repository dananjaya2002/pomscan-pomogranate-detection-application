/// Persists [AppSettings] to [SharedPreferences].
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';

abstract final class _Keys {
  static const cameraQuality = 'settings.camera_quality';
  static const performanceMode = 'settings.performance_mode';
  static const realtimeFrameInterval = 'settings.realtime_frame_interval';
  static const adaptiveFrameSkipping = 'settings.adaptive_frame_skipping';
  static const confidenceThreshold = 'settings.confidence_threshold';
  static const maxDetections = 'settings.max_detections';
  static const modelInputSize = 'settings.model_input_size';
}

final class SettingsRepository {
  const SettingsRepository();

  /// Loads persisted settings, falling back to defaults if not yet saved.
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    final cqIndex = prefs.getInt(_Keys.cameraQuality);
    final pmIndex = prefs.getInt(_Keys.performanceMode);
    final fiIndex = prefs.getInt(_Keys.realtimeFrameInterval);
    final adaptive = prefs.getBool(_Keys.adaptiveFrameSkipping);
    final conf = prefs.getDouble(_Keys.confidenceThreshold);
    final maxDet = prefs.getInt(_Keys.maxDetections);
    final misIndex = prefs.getInt(_Keys.modelInputSize);

    return AppSettings(
      cameraQuality: cqIndex != null
          ? CameraQuality.values[cqIndex.clamp(
              0,
              CameraQuality.values.length - 1,
            )]
          : CameraQuality.medium,
      performanceMode: pmIndex != null
          ? PerformanceMode.values[pmIndex.clamp(
              0,
              PerformanceMode.values.length - 1,
            )]
          : PerformanceMode.balanced,
      realtimeFrameInterval: fiIndex != null
          ? RealtimeFrameInterval.values[fiIndex.clamp(
              0,
              RealtimeFrameInterval.values.length - 1,
            )]
          : RealtimeFrameInterval.every5,
      adaptiveFrameSkipping: adaptive ?? true,
      confidenceThreshold: conf?.clamp(0.25, 0.85) ?? 0.45,
      maxDetections: maxDet?.clamp(1, 10) ?? 10,
      modelInputSize: misIndex != null
          ? ModelInputSize.values[misIndex.clamp(
              0,
              ModelInputSize.values.length - 1,
            )]
          : ModelInputSize.quality,
    );
  }

  /// Persists all settings fields.
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_Keys.cameraQuality, settings.cameraQuality.index),
      prefs.setInt(_Keys.performanceMode, settings.performanceMode.index),
      prefs.setInt(
        _Keys.realtimeFrameInterval,
        settings.realtimeFrameInterval.index,
      ),
      prefs.setBool(
        _Keys.adaptiveFrameSkipping,
        settings.adaptiveFrameSkipping,
      ),
      prefs.setDouble(_Keys.confidenceThreshold, settings.confidenceThreshold),
      prefs.setInt(_Keys.maxDetections, settings.maxDetections),
      prefs.setInt(_Keys.modelInputSize, settings.modelInputSize.index),
    ]);
  }
}
