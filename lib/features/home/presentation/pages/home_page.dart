/// Home dashboard — entry point after the splash screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../detection/presentation/providers/static_detection_provider.dart';
import '../../../disease_detection/presentation/providers/disease_detection_provider.dart';

// Extracted widgets
import '../widgets/static_scan_card.dart';
import '../widgets/disease_hero_card.dart';
import '../widgets/knowledge_base_cards.dart';
import '../widgets/onboarding_tips_card.dart';
import '../widgets/quick_access_grid.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staticModelState = ref.watch(staticModelInitProvider);
    final staticModelReady =
        staticModelState.hasValue && !staticModelState.hasError;

    final diseaseModelState = ref.watch(diseaseModelInitProvider);
    final diseaseModelReady =
        diseaseModelState.hasValue && !diseaseModelState.hasError;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),
                const _SectionHeader(title: 'Quick Scan')
                    .animate()
                    .fade(duration: 400.ms),
                const SizedBox(height: 16),
                StaticScanCard(modelReady: staticModelReady),
                const SizedBox(height: 16),
                DiseaseHeroCard(modelReady: diseaseModelReady),
                const SizedBox(height: 16),
                const OnboardingTipsCard(),
                const SizedBox(height: 32),
                const _SectionHeader(title: 'Knowledge Base')
                    .animate()
                    .fade(duration: 400.ms, delay: 200.ms),
                const SizedBox(height: 16),
                const InfoCardsRow(),
                const SizedBox(height: 32),
                const _SectionHeader(title: 'App')
                    .animate()
                    .fade(duration: 400.ms, delay: 400.ms),
                const SizedBox(height: 16),
                const QuickAccessGrid(),
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      elevation: 0,
      expandedHeight: 110,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                _HomeLogoMark(),
                SizedBox(width: 10),
                Text(
                  'PomeScan',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            )
                .animate()
                .fade(duration: 500.ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
            const SizedBox(height: 2),
            Text(
              'Simple farming assistant',
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fade(duration: 500.ms, delay: 100.ms),
          ],
        ),
      ),
    );
  }
}

class _HomeLogoMark extends StatelessWidget {
  const _HomeLogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white24),
      ),
      child: const Icon(
        Icons.spa_rounded,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.divider.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
