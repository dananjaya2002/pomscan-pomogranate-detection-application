/// Riverpod providers for the disease classification pipeline.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/datasources/disease_model_datasource.dart';
import '../../data/repositories/disease_detection_repository_impl.dart';
import '../../domain/entities/disease_result.dart';
import '../../domain/usecases/run_disease_detection_usecase.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

final _diseaseModelDataSourceProvider = Provider<DiseaseModelDataSource>(
  (_) => DiseaseModelDataSource(),
);

final _diseaseRepositoryProvider = Provider<DiseaseDetectionRepositoryImpl>(
  (ref) => DiseaseDetectionRepositoryImpl(
    modelDataSource: ref.watch(_diseaseModelDataSourceProvider),
  ),
);

final runDiseaseDetectionUseCaseProvider = Provider<RunDiseaseDetectionUseCase>(
  (ref) => RunDiseaseDetectionUseCase(ref.watch(_diseaseRepositoryProvider)),
);

// ── Model initialisation ──────────────────────────────────────────────────────

/// Resolves once the disease TFLite model is fully loaded and tensors
/// are allocated.  Watch on the home screen to show a readiness chip.
final diseaseModelInitProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(_diseaseRepositoryProvider);
  await repo.initialise();
});

// ── Detection state ───────────────────────────────────────────────────────────

@immutable
final class DiseaseDetectionState {
  const DiseaseDetectionState({
    this.isProcessing = false,
    this.result,
    this.pickedImage,
    this.errorMessage,
  });

  final bool isProcessing;
  final DiseaseResult? result;
  final File? pickedImage;
  final String? errorMessage;

  DiseaseDetectionState copyWith({
    bool? isProcessing,
    DiseaseResult? result,
    File? pickedImage,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) =>
      DiseaseDetectionState(
        isProcessing: isProcessing ?? this.isProcessing,
        result: clearResult ? null : result ?? this.result,
        pickedImage: pickedImage ?? this.pickedImage,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

final class DiseaseDetectionNotifier
    extends StateNotifier<DiseaseDetectionState> {
  DiseaseDetectionNotifier(this._useCase)
      : super(const DiseaseDetectionState());

  final RunDiseaseDetectionUseCase _useCase;

  Future<void> pickAndDetect(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null) return;

    final file = File(picked.path);
    state = state.copyWith(
      pickedImage: file,
      isProcessing: true,
      clearResult: true,
      clearError: true,
    );

    try {
      final bytes = await file.readAsBytes();
      final result = await _useCase(bytes);
      state = state.copyWith(result: result, isProcessing: false);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Detection failed: $e',
      );
    }
  }

  void reset() {
    state = const DiseaseDetectionState();
  }
}

final diseaseDetectionProvider = StateNotifierProvider.autoDispose<
    DiseaseDetectionNotifier, DiseaseDetectionState>(
  (ref) => DiseaseDetectionNotifier(
    ref.watch(runDiseaseDetectionUseCaseProvider),
  ),
);
