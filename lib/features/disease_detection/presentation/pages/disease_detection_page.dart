/// Disease detection page — pick an image from the camera or gallery,
/// run the disease classifier, and display a result card.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
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
          'Disease Scan',
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Text(
                  'Use a clear leaf or fruit photo. The scan identifies likely disease type and provides treatment guidance.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              )
                  .animate()
                  .fade(duration: 350.ms)
                  .slideY(begin: 0.05, end: 0),
              const SizedBox(height: 16),
              // Image source picker
              _ImageSourceRow(
                isProcessing: state.isProcessing,
                onPickCamera: () => notifier.pickAndDetect(ImageSource.camera),
                onPickGallery: () =>
                    notifier.pickAndDetect(ImageSource.gallery),
              )
                  .animate()
                  .fade(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
              const SizedBox(height: 24),
              // Selected image preview
              if (state.pickedImage != null) ...[
                _ImagePreview(
                  file: state.pickedImage!,
                  isProcessing: state.isProcessing,
                ).animate().fade(duration: 400.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutQuad),
                const SizedBox(height: 24),
              ],
              // Processing indicator
              if (state.isProcessing) ...[
                const _AnalysingIndicator().animate().fade(duration: 400.ms),
                const SizedBox(height: 24),
              ],
              // Error message
              if (state.errorMessage != null && !state.isProcessing)
                _ErrorBanner(message: state.errorMessage!)
                    .animate()
                    .fade(duration: 400.ms)
                    .shakeX(amount: 3),
              // Result card
              if (state.result != null && !state.isProcessing)
                DiseaseResultCard(result: state.result!)
                    .animate()
                    .fade(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
              // Empty state
              if (state.pickedImage == null && !state.isProcessing)
                const _EmptyState()
                    .animate()
                    .fade(duration: 400.ms, delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Image source row ──────────────────────────────────────────────────────────

class _ImageSourceRow extends StatelessWidget {
  const _ImageSourceRow({
    required this.isProcessing,
    required this.onPickCamera,
    required this.onPickGallery,
  });

  final bool isProcessing;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SourceButton(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            color: AppColors.accent,
            onPressed: isProcessing ? null : onPickCamera,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SourceButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            color: AppColors.primary,
            onPressed: isProcessing ? null : onPickGallery,
          ),
        ),
      ],
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withAlpha(80),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      onPressed: onPressed,
    );
  }
}

// ── Image preview ─────────────────────────────────────────────────────────────

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.file, required this.isProcessing});

  final File file;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.file(
              file,
              fit: BoxFit.cover,
            ),
          ),
          if (isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(100),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Analysing indicator ───────────────────────────────────────────────────────

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

// ── Error banner ──────────────────────────────────────────────────────────────

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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: const [
          Text('🔬', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text(
            'Select an image to check diseases',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Use Camera or Gallery above to pick\na clear pomegranate photo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
