/// FPS counter badge widget — top-left overlay.
///
/// Colour-codes the badge based on throughput:
///   • green  ≥ 15 fps  — smooth
///   • amber   5–14 fps — acceptable
///   • red    < 5 fps   — too slow
///   • grey   0.0       — not yet measuring
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/detection_provider.dart';

/// Small overlay badge showing real-time inference FPS.
final class FpsCounter extends ConsumerWidget {
  const FpsCounter({super.key});

  static Color _badgeColor(double fps) {
    if (fps <= 0.0) return const Color(0xFF607D8B); // grey — no reading yet
    if (fps < 5) return const Color(0xFFF44336);    // red
    if (fps < 15) return const Color(0xFFFF9800);   // amber
    return const Color(0xFF4CAF50);                 // green
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fps = ref.watch(detectionProvider.select((s) => s.fps));

    final color = _badgeColor(fps);
    final label = fps <= 0.0 ? '— FPS' : '${fps.toStringAsFixed(1)} FPS';

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12.0,
      left: 12.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(153),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(180), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Colour dot indicator
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(128),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
