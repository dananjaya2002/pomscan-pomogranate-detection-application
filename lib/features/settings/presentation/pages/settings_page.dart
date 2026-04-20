/// Full-screen settings page.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(settingsProvider);
    final settings = asyncSettings.valueOrNull ?? const AppSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Quality / Performance ─────────────────────────────────────────
          _SectionHeader(title: 'Performance & Quality'),
          _SettingsCard(
            children: [
              _SegmentedRow<CameraQuality>(
                label: 'Camera Resolution',
                description: 'Higher = sharper feed but slower inference',
                values: CameraQuality.values,
                selected: settings.cameraQuality,
                labelOf: (v) => v.label,
                hintOf: (v) => v.hint,
                onChanged:
                    (v) => ref
                        .read(settingsProvider.notifier)
                        .updateCameraQuality(v),
              ),
              _Divider(),
              _SegmentedRow<PerformanceMode>(
                label: 'Processing Speed',
                description: 'Controls how many camera frames are analysed',
                values: PerformanceMode.values,
                selected: settings.performanceMode,
                labelOf: (v) => v.label,
                hintOf: (v) => v.hint,
                onChanged:
                    (v) => ref
                        .read(settingsProvider.notifier)
                        .updatePerformanceMode(v),
              ),
              _Divider(),
              _SegmentedRow<ModelInputSize>(
                label: 'Preprocessing Quality',
                description:
                    'Sampling resolution before inference. Lower = faster YUV conversion.',
                values: ModelInputSize.values,
                selected: settings.modelInputSize,
                labelOf: (v) => v.label,
                hintOf: (v) => v.hint,
                onChanged:
                    (v) => ref
                        .read(settingsProvider.notifier)
                        .updateModelInputSize(v),
              ),
            ],
          ),

          // ── Detection Filters ─────────────────────────────────────────────
          _SectionHeader(title: 'Detection Filters'),
          _SettingsCard(
            children: [
              _SliderRow(
                label: 'Min Confidence',
                description:
                    'Only show detections above this score. Higher = fewer but more confident boxes.',
                value: settings.confidenceThreshold,
                min: 0.25,
                max: 0.85,
                divisions: 12,
                displayValue:
                    '${(settings.confidenceThreshold * 100).round()}%',
                onChanged:
                    (v) => ref
                        .read(settingsProvider.notifier)
                        .updateConfidenceThreshold(v),
              ),
              _Divider(),
              _SliderRow(
                label: 'Max Detections',
                description: 'Maximum number of bounding boxes shown at once.',
                value: settings.maxDetections.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                displayValue: '${settings.maxDetections}',
                onChanged:
                    (v) => ref
                        .read(settingsProvider.notifier)
                        .updateMaxDetections(v.round()),
              ),
            ],
          ),

          // ── About ─────────────────────────────────────────────────────────
          _SectionHeader(title: 'Information'),
          _SettingsCard(
            children: [
              _InfoRow(label: 'Model', value: 'YOLO11 (3-class)'),
              _Divider(),
              _InfoRow(
                label: 'Input Size',
                value:
                    '${settings.modelInputSize.pixels} × 640 px (model 640×640)',
              ),
              _Divider(),
              _InfoRow(label: 'Framework', value: 'TFLite 0.12'),
              _Divider(),
              _InfoRow(label: 'App Version', value: '1.0.0'),
            ],
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              'Settings are saved automatically',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppColors.divider);
}

class _SegmentedRow<T> extends StatelessWidget {
  const _SegmentedRow({
    required this.label,
    required this.description,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.hintOf,
    required this.onChanged,
  });

  final String label;
  final String description;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final String Function(T) hintOf;
  final void Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 3),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children:
                values.map((v) {
                  final isSelected = v == selected;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: v == values.last ? 0 : 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => onChanged(v),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primaryLight
                                      : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                labelOf(v),
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? AppColors.primaryLight
                                          : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hintOf(v),
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? AppColors.primaryLight.withAlpha(
                                            153,
                                          )
                                          : AppColors.textMuted,
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.description,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  final String label;
  final String description;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
