/// Inference latency badge widget — top-left overlay.
///
/// Colour-codes the badge based on latency:
///   • green   ≤ 120 ms — fast
///   • amber 121–250 ms — acceptable
///   • red     > 250 ms — slow
///   • grey      0.0    — not yet measuring
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/detection_provider.dart';

/// Small overlay badge showing real-time inference latency.
final class FpsCounter extends ConsumerWidget {
  const FpsCounter({super.key});

  static Color _badgeColor(double latencyMs) {
    if (latencyMs <= 0.0) {
      return const Color(0xFF607D8B); // grey — no reading yet
    }
    if (latencyMs > 250) return const Color(0xFFF44336); // red
    if (latencyMs > 120) return const Color(0xFFFF9800); // amber
    return const Color(0xFF4CAF50); // green
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latencyMs = ref.watch(
      detectionProvider.select((s) => s.inferenceLatencyMs),
    );

    final color = _badgeColor(latencyMs);
    final label =
        latencyMs <= 0.0 ? '— Latency' : '${latencyMs.toStringAsFixed(0)} ms';

    return Positioned(
      top: MediaQuery.of(context).padding.top + 52.0,
      right: 12.0,
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
