import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/farmer_strings.dart';
import '../providers/disease_detection_provider.dart';
import '../widgets/disease_result_card.dart';

class DiseaseDetectionPage extends ConsumerWidget {
  const DiseaseDetectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diseaseDetectionProvider);
    final notifier = ref.read(diseaseDetectionProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          FarmerStrings.diseaseCheckTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (state.pickedImage != null)
            TextButton(
              onPressed: notifier.reset,
              child: const Text(
                'Reset',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Text(
                  FarmerStrings.diseaseCheckDescription,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  color: AppColors.surfaceVariant,
                  constraints: const BoxConstraints(minHeight: 260),
                  child: Center(
                    child: state.pickedImage == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 50),
                            child: Text(
                              '🔬 Pick a photo to check disease',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Stack(
                            fit: StackFit.loose,
                            children: [
                              Image.file(state.pickedImage!),
                              if (state.isProcessing)
                                Positioned.fill(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: _AnalysingIndicator(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (state.errorMessage != null && !state.isProcessing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ErrorBanner(message: state.errorMessage!),
                ),
              if (state.result != null && !state.isProcessing)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: DiseaseResultCard(result: state.result!),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.isProcessing
                          ? null
                          : () => notifier.pickAndDetect(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(FarmerStrings.takePhotoButton),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.isProcessing
                          ? null
                          : () => notifier.pickAndDetect(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text(FarmerStrings.selectImageButton),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalysingIndicator extends StatelessWidget {
  const _AnalysingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Analysing image…',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(25),
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(color: AppColors.accent.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
