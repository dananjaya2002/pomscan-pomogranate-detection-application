library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProcessingStatusOverlay extends StatelessWidget {
  const ProcessingStatusOverlay({
    super.key,
    required this.status,
    required this.statusTitle,
    this.description,
  });

  final String status;

  final String statusTitle;

  final String? description;

  @override
  Widget build(BuildContext context) {
    final isLoading = status == 'loading' || status == 'processing';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor().withAlpha(150),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              ),
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor().withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: _getStatusColor(),
                  size: 28,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            statusTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'complete':
        return AppColors.ripe;
      case 'loading':
      case 'processing':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}

class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels = const [],
  });

  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Step $currentStep of $totalSteps${stepLabels.isNotEmpty ? ': ${stepLabels[currentStep - 1]}' : ''}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ConfidenceIndicator extends StatelessWidget {
  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    required this.label,
  });

  final double confidence;
  final String label;

  String _getConfidenceLabel() {
    if (confidence >= 0.85) return '✓ Very confident';
    if (confidence >= 0.70) return '⚡ Fairly sure';
    if (confidence >= 0.50) return '≈ Somewhat sure';
    return '? Not sure';
  }

  Color _getConfidenceColor() {
    if (confidence >= 0.85) return AppColors.ripe;
    if (confidence >= 0.70) return AppColors.semiRipe;
    if (confidence >= 0.50) return AppColors.unripe;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getConfidenceColor().withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getConfidenceColor().withAlpha(100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getConfidenceLabel(),
            style: TextStyle(
              color: _getConfidenceColor(),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 4,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor()),
            ),
          ),
        ],
      ),
    );
  }
}
