import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../info/domain/entities/info_item.dart';
import '../../../info/presentation/pages/info_list_page.dart';

class InfoCardsRow extends StatelessWidget {
  const InfoCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _InfoCard(
          type: InfoType.diseases,
          title: 'Diseases',
          subtitle: 'Identify & treat pomegranate diseases',
          icon: '🦠',
          accentColor: AppColors.accent,
        )
            .animate()
            .fade(duration: 400.ms, delay: 300.ms)
            .slideX(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
        const SizedBox(height: 12),
        const _InfoCard(
          type: InfoType.plantation,
          title: 'Plantation Guide',
          subtitle: 'Site prep, soil, irrigation & more',
          icon: '🌱',
          accentColor: AppColors.primaryLight,
        )
            .animate()
            .fade(duration: 400.ms, delay: 400.ms)
            .slideX(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
        const SizedBox(height: 12),
        const _InfoCard(
          type: InfoType.harvesting,
          title: 'Harvesting Guide',
          subtitle: 'Maturity indicators & post-harvest tips',
          icon: '🌾',
          accentColor: Color(0xFFD4AC0D),
        )
            .animate()
            .fade(duration: 400.ms, delay: 500.ms)
            .slideX(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final InfoType type;
  final String title;
  final String subtitle;
  final String icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => InfoListPage(type: type)),
            );
          },
          splashColor: accentColor.withValues(alpha: 0.1),
          highlightColor: accentColor.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: accentColor, width: 4)),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
