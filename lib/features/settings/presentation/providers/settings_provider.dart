library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/entities/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (_) => const SettingsRepository(),
);

final class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    return ref.read(settingsRepositoryProvider).load();
  }

  AppSettings get current => state.valueOrNull ?? const AppSettings();

  Future<void> updateCameraQuality(CameraQuality quality) =>
      _update((s) => s.copyWith(cameraQuality: quality));

  Future<void> updatePerformanceMode(PerformanceMode mode) =>
      _update((s) => s.copyWith(performanceMode: mode));

  Future<void> updateRealtimeFrameInterval(RealtimeFrameInterval interval) =>
      _update((s) => s.copyWith(realtimeFrameInterval: interval));
  Future<void> updateAdaptiveFrameSkipping(bool enabled) =>
      _update((s) => s.copyWith(adaptiveFrameSkipping: enabled));

  Future<void> updateConfidenceThreshold(double value) =>
      _update((s) => s.copyWith(confidenceThreshold: value));

  Future<void> updateMaxDetections(int value) =>
      _update((s) => s.copyWith(maxDetections: value));

  Future<void> updateModelInputSize(ModelInputSize size) =>
      _update((s) => s.copyWith(modelInputSize: size));

  Future<void> _update(AppSettings Function(AppSettings) updater) async {
    final current = state.valueOrNull ?? const AppSettings();
    final next = updater(current);
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
