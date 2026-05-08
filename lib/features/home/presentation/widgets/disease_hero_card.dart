import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../disease_detection/presentation/pages/disease_detection_page.dart';
import 'model_chip.dart';

class DiseaseHeroCard extends StatelessWidget {
  const DiseaseHeroCard({super.key, required this.modelReady});
  final bool modelReady;

  @override
  Widget build(BuildContext context) {
    const accentDark = Color(0xFF7B1A12);
    const accentMid = Color(0xFFC0392B);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [accentDark, accentMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: accentMid.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detect Diseases',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check disease symptoms from a photo\nand get care guidance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              ModelChip(ready: modelReady),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.biotech_rounded, size: 22),
              label: const Text(
                'Start Disease Scan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DiseaseDetectionPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad);
  }
}
