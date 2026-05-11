/// Card widget that displays the disease classification result.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../info/domain/entities/info_item.dart';
import '../../../info/presentation/pages/info_detail_page.dart';
import '../../../info/presentation/providers/info_provider.dart';
import '../../domain/entities/disease_result.dart';

class DiseaseResultCard extends ConsumerWidget {
  const DiseaseResultCard({super.key, required this.result});

  final DiseaseResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (result.isHealthy) {
      return _HealthyCard();
    }
    return _DiseaseCard(result: result, ref: ref, context: context);
  }
}

// ── Healthy result ────────────────────────────────────────────────────────────

class _HealthyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: AppColors.ripe.withAlpha(100)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.ripe.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('✅', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Healthy',
                  style: TextStyle(
                    color: AppColors.ripe,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No disease detected. The plant appears healthy.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Disease result ────────────────────────────────────────────────────────────

class _DiseaseCard extends StatelessWidget {
  const _DiseaseCard({
    required this.result,
    required this.ref,
    required this.context,
  });

  final DiseaseResult result;
  final WidgetRef ref;
  final BuildContext context;

  Color get _accentColor =>
      AppConstants.diseaseColors[result.label] ?? AppColors.accent;

  String get _displayName {
    // Humanise raw model class names
    switch (result.label) {
      case 'Bacterial_Blight':
        return 'Bacterial Blight';
      case 'Alternaria':
        return 'Alternaria (Fruit Rot)';
      default:
        return result.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidencePct = (result.confidence * 100).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: _accentColor.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accentColor.withAlpha(25),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusLarge),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _accentColor.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '🔬',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Confidence: $confidencePct%',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _ConfidenceBadge(
                    confidence: result.confidence, color: _accentColor),
              ],
            ),
          ),
          // Confidence bar
          LinearProgressIndicator(
            value: result.confidence,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            minHeight: 3,
          ),
          // Action
          Padding(
            padding: const EdgeInsets.all(14),
            child:
                _ViewDetailsButton(result: result, accentColor: _accentColor),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence, required this.color});
  final double confidence;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        '${(confidence * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ViewDetailsButton extends ConsumerWidget {
  const _ViewDetailsButton({
    required this.result,
    required this.accentColor,
  });

  final DiseaseResult result;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoId = AppConstants.diseaseLabelToInfoId[result.label] ?? '';
    if (infoId.isEmpty) return const SizedBox.shrink();

    final diseasesAsync = ref.watch(infoProvider(InfoType.diseases));

    return diseasesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        final match = items.where((i) => i.id == infoId).toList();
        if (match.isEmpty) return const SizedBox.shrink();
        final item = match.first;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor.withAlpha(30),
              foregroundColor: accentColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: accentColor.withAlpha(80)),
              ),
            ),
            icon: const Icon(Icons.info_outline_rounded, size: 18),
            label: const Text(
              'View Full Details',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      InfoDetailPage(item: item, accent: accentColor),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
