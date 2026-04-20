/// Bottom dashboard panel — shows per-class detection stats with a
/// frosted-glass backdrop, class counters, confidence bars, and torch control.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../providers/detection_provider.dart';

/// Frosted-glass bottom panel compositing:
///   • Header row: "Detection Results" + total count
///   • Three class cards (Ripe / Semi-Ripe / Unripe) with count + confidence bar
///   • Footer row: app subtitle + torch toggle button
final class DetectionDashboard extends ConsumerWidget {
  const DetectionDashboard({
    super.key,
    required this.torchOn,
    required this.onTorchToggle,
    required this.scanControlEnabled,
  });

  final bool torchOn;
  final VoidCallback onTorchToggle;
  final bool scanControlEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detections = ref.watch(detectionProvider.select((s) => s.detections));
    final isScanActive = ref.watch(
      detectionProvider.select((s) => s.isScanActive),
    );

    // Aggregate counts and collect confidence scores per class.
    final counts = <String, int>{'ripe': 0, 'semi_ripe': 0, 'unripe': 0};
    final confidences = <String, List<double>>{
      'ripe': [],
      'semi_ripe': [],
      'unripe': [],
    };
    for (final d in detections) {
      counts[d.label] = (counts[d.label] ?? 0) + 1;
      confidences[d.label]?.add(d.confidence);
    }

    // Average confidence per class (0.0 when no detections).
    double avgConf(String label) {
      final list = confidences[label] ?? [];
      if (list.isEmpty) return 0.0;
      return list.reduce((a, b) => a + b) / list.length;
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: MediaQuery.of(context).padding.bottom + 14,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(140),
              border: Border(
                top: BorderSide(color: Colors.white.withAlpha(20), width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag handle ──────────────────────────────────────────
                Container(
                  width: 32,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ── Header ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detection Results',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TotalBadge(count: detections.length),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white54,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Class cards ──────────────────────────────────────────
                Row(
                  children: [
                    _ClassCard(
                      label: 'ripe',
                      displayName: 'Ripe',
                      count: counts['ripe']!,
                      avgConf: avgConf('ripe'),
                    ),
                    const SizedBox(width: 8),
                    _ClassCard(
                      label: 'semi_ripe',
                      displayName: 'Semi-Ripe',
                      count: counts['semi_ripe']!,
                      avgConf: avgConf('semi_ripe'),
                    ),
                    const SizedBox(width: 8),
                    _ClassCard(
                      label: 'unripe',
                      displayName: 'Unripe',
                      count: counts['unripe']!,
                      avgConf: avgConf('unripe'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Footer: app subtitle + torch button ──────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Pomegranate Ripeness Detector',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Point camera at pomegranates',
                          style: TextStyle(
                            color: Colors.white.withAlpha(77),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ScanButton(
                          enabled: scanControlEnabled,
                          isScanning: isScanActive,
                          onTap: () =>
                              ref.read(detectionProvider.notifier).toggleScan(),
                        ),
                        const SizedBox(width: 10),
                        _TorchButton(torchOn: torchOn, onTap: onTorchToggle),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Total badge ───────────────────────────────────────────────────────────────

class _TotalBadge extends StatelessWidget {
  const _TotalBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count == 0 ? 'None detected' : '$count detected',
        style: TextStyle(
          color: count == 0 ? Colors.white38 : Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Per-class card ────────────────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.label,
    required this.displayName,
    required this.count,
    required this.avgConf,
  });

  final String label;
  final String displayName;
  final int count;
  final double avgConf;

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.classColors[label] ?? Colors.white;
    final hasDetection = count > 0;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: hasDetection ? color.withAlpha(30) : Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                hasDetection ? color.withAlpha(80) : Colors.white.withAlpha(20),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot + count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: hasDetection ? color : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    color: hasDetection ? color : Colors.white30,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Class name
            Text(
              displayName,
              style: TextStyle(
                color: hasDetection ? Colors.white70 : Colors.white30,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Confidence bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: avgConf,
                backgroundColor: Colors.white.withAlpha(15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  hasDetection ? color : Colors.white12,
                ),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 3),
            // Confidence text
            Text(
              hasDetection
                  ? '${(avgConf * 100).toStringAsFixed(0)}% conf'
                  : '—',
              style: TextStyle(
                color: hasDetection ? Colors.white38 : Colors.white24,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({
    required this.enabled,
    required this.isScanning,
    required this.onTap,
  });

  final bool enabled;
  final bool isScanning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = !enabled
        ? Colors.white.withAlpha(12)
        : isScanning
            ? const Color(0xFF2E7D32).withAlpha(90)
            : const Color(0xFF1976D2).withAlpha(90);
    final borderColor = !enabled
        ? Colors.white24
        : isScanning
            ? const Color(0xFF66BB6A)
            : const Color(0xFF64B5F6);
    final icon = isScanning
        ? Icons.pause_circle_rounded
        : Icons.play_circle_fill_rounded;
    final label = !enabled
        ? 'Idle'
        : isScanning
            ? 'Scanning...'
            : 'Start Scan';

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: enabled ? Colors.white : Colors.white38, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white38,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Torch button ──────────────────────────────────────────────────────────────

class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.torchOn, required this.onTap});
  final bool torchOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              torchOn ? Colors.amber.withAlpha(45) : Colors.white.withAlpha(18),
          border: Border.all(
            color: torchOn ? Colors.amber : Colors.white30,
            width: 1.5,
          ),
          boxShadow: torchOn
              ? [
                  BoxShadow(
                    color: Colors.amber.withAlpha(77),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          torchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
          color: torchOn ? Colors.amber : Colors.white54,
          size: 22,
        ),
      ),
    );
  }
}
