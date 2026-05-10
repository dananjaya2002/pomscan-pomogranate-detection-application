/// Generic list page for a knowledge-base section (diseases / plantation / harvesting).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/info_item.dart';
import '../providers/info_provider.dart';
import 'info_detail_page.dart';

class InfoListPage extends ConsumerWidget {
  const InfoListPage({super.key, required this.type});

  final InfoType type;

  Color _accentFor(InfoType type) {
    switch (type) {
      case InfoType.diseases:
        return AppColors.diseasesAccent;
      case InfoType.plantation:
        return AppColors.plantationAccent;
      case InfoType.harvesting:
        return AppColors.harvestingAccent;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(infoProvider(type));
    final accent = _accentFor(type);

    return Scaffold(
      appBar: AppBar(
        title: Text(type.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: asyncItems.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryLight),
        ),
        error: (e, _) => Center(
          child: Text(
            'Failed to load content: $e',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        data: (items) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _ItemCard(item: items[index], accent: accent),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.accent});

  final InfoItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InfoDetailPage(item: item, accent: accent),
          ),
        ),
        child: Container(
          decoration: AppTheme.cardDecoration(
            borderColor: accent.withAlpha(60),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  border: Border.all(color: accent.withAlpha(60), width: 1),
                ),
                child: Center(
                  child: Text(item.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (item.details['severity'] != null)
                          _SeverityChip(
                            severity: item.details['severity'] as String,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (item.tips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${item.tips.length} tips  →',
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.severity});
  final String severity;

  Color get _color {
    switch (severity.toLowerCase()) {
      case 'very high':
        return AppColors.unripe;
      case 'high':
        return AppColors.semiRipe;
      default:
        return AppColors.ripe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withAlpha(80), width: 1),
      ),
      child: Text(
        severity,
        style: TextStyle(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
