import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';

class OnboardingTipsCard extends StatelessWidget {
  const OnboardingTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  color: AppColors.harvestingAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Photo Tips For Better Results',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _TipLine(text: 'Use natural daylight when possible.'),
          SizedBox(height: 8),
          _TipLine(text: 'Keep one fruit centered and in focus.'),
          SizedBox(height: 8),
          _TipLine(text: 'Stay 30-60 cm away from the fruit.'),
          SizedBox(height: 8),
          _TipLine(text: 'Avoid blurry photos and heavy shadows.'),
        ],
      ),
    )
        .animate()
        .fade(duration: 400.ms, delay: 260.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad);
  }
}

class _TipLine extends StatelessWidget {
  const _TipLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded,
            color: AppColors.primaryLight, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
