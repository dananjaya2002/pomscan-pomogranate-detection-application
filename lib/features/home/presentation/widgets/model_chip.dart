import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class ModelChip extends StatelessWidget {
  const ModelChip({super.key, required this.ready});
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ready
              ? AppColors.ripe.withValues(alpha: 0.5)
              : AppColors.textMuted.withValues(alpha: 0.3),
        ),
        boxShadow: ready
            ? [
                BoxShadow(
                  color: AppColors.ripe.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ready ? AppColors.ripe : AppColors.textMuted,
            ),
          )
              .animate(target: ready ? 1 : 0)
              .shimmer(duration: 2.seconds, color: Colors.white24),
          const SizedBox(width: 8),
          Text(
            ready ? 'Model\nReady' : 'Loading\nModel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ready ? AppColors.ripe : AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
