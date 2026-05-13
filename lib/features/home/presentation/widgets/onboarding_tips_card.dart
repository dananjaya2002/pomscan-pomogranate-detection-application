import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/farmer_strings.dart';
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  color: AppColors.harvestingAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Quick photo tips',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _TipLine(text: FarmerStrings.tipDaylight),
          SizedBox(height: 8),
          _TipLine(text: FarmerStrings.tipDistance),
        ],
      ),
    )
        .animate()
        .fade(duration: 350.ms, delay: 220.ms)
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
