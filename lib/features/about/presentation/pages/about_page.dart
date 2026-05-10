/// About Us page.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── Logo & name ───────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppTheme.redGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withAlpha(80),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🍎', style: TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'PomeScan',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-Powered Pomegranate Ripeness Detection',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Project description ───────────────────────────────────────────
          _InfoCard(
            title: 'About the Project',
            content:
                'PomeScan is a final-year research project that uses on-device '
                'artificial intelligence to detect and classify the ripeness of '
                'pomegranate fruits in real time directly from the phone camera.\n\n'
                'The AI model — YOLO11 exported to TFLite — classifies each '
                'detected fruit as Ripe, Semi-Ripe, or Unripe at up to 15 '
                'frames per second, enabling farmers to make precise, '
                'data-driven harvest decisions without any internet connection.',
          ),

          const SizedBox(height: 12),

          // ── Tech stack ────────────────────────────────────────────────────
          Container(
            decoration: AppTheme.cardDecoration(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TECHNOLOGY STACK',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TechChip('Flutter 3.x', AppColors.accent),
                    _TechChip('Dart 3.x', AppColors.accent),
                    _TechChip('YOLO11', AppColors.primaryLight),
                    _TechChip('TFLite 0.12', AppColors.primaryLight),
                    _TechChip('GPU Delegate', AppColors.harvestingAccent),
                    _TechChip('NNAPI', AppColors.harvestingAccent),
                    _TechChip('Riverpod 2.x', AppColors.semiRipe),
                    _TechChip('Dart Isolates', AppColors.semiRipe),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Project context ───────────────────────────────────────────────
          _InfoCard(
            title: 'Academic Context',
            content: 'Department of Computer Engineering\n'
                'Faculty of Engineering\n'
                'Final Year Research Project — Year 3, Semester 2\n\n'
                'This project explores the feasibility of deploying large '
                'object detection models on mid-range Android devices using '
                'hardware acceleration delegates and an efficient inference '
                'pipeline optimised for real-time agricultural applications.',
          ),

          const SizedBox(height: 12),

          // ── Disclaimer ────────────────────────────────────────────────────
          Container(
            decoration: AppTheme.cardDecoration(
              borderColor: AppColors.textMuted.withAlpha(40),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              'This application is intended for research and educational '
              'purposes. Detection results are AI-generated estimates and '
              'should not replace expert agronomic assessment.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.65,
                ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(70), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
