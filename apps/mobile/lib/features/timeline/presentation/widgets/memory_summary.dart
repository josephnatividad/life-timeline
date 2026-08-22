import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class MemoryPrivacyBadge extends StatelessWidget {
  const MemoryPrivacyBadge({required this.classification, super.key});

  final PrivacyClassification classification;

  @override
  Widget build(BuildContext context) => PrivacyBadge(
    level: switch (classification) {
      PrivacyClassification.shareSafe => PrivacyBadgeLevel.shareSafe,
      PrivacyClassification.personal => PrivacyBadgeLevel.personal,
      PrivacyClassification.sensitive => PrivacyBadgeLevel.sensitive,
      PrivacyClassification.neverShare => PrivacyBadgeLevel.neverShare,
    },
  );
}

final class MemorySummary extends StatelessWidget {
  const MemorySummary({
    required this.memory,
    this.showPrimary = true,
    this.showSecondary = true,
    this.evidenceSection,
    super.key,
  });

  final TimelineMemory memory;
  final bool showPrimary;
  final bool showSecondary;
  final Widget? evidenceSection;

  @override
  Widget build(BuildContext context) {
    final event = memory.event;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPrimary) ...[
          Text(event.title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            TemporalDisplay.label(event.temporalValue),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppBadge(label: event.eventType ?? 'Memory', icon: AppIcons.time),
              if (memory.category case final category?)
                AppBadge(label: category.name, icon: AppIcons.explore),
              MemoryPrivacyBadge(
                classification: event.metadata.privacyClassification,
              ),
            ],
          ),
          if (event.description case final description?) ...[
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(title: 'About this memory'),
            const SizedBox(height: AppSpacing.sm),
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ],
        if (showSecondary)
          if (memory.relatedEntity case final entity?) ...[
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(title: 'Related'),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(icon: AppIcons.you),
              title: Text(entity.name),
              subtitle: Text(entity.entityType),
            ),
          ],
        if (showSecondary && evidenceSection != null) ...[
          const SizedBox(height: AppSpacing.xl),
          AppSectionHeader(title: 'Evidence'),
          const SizedBox(height: AppSpacing.sm),
          evidenceSection!,
        ],
        if (showSecondary) ...[
          const SizedBox(height: AppSpacing.xl),
          AppSectionHeader(title: 'Timeline history'),
          const SizedBox(height: AppSpacing.sm),
          _MetadataRow(
            label: 'Created',
            value: MaterialLocalizations.of(
              context,
            ).formatMediumDate(event.metadata.createdAt.toLocal()),
          ),
          _MetadataRow(
            label: 'Last updated',
            value: MaterialLocalizations.of(
              context,
            ).formatMediumDate(event.metadata.updatedAt.toLocal()),
          ),
          _MetadataRow(
            label: 'Status',
            value: event.metadata.lifecycle == RecordLifecycle.archived
                ? 'Archived'
                : 'Active',
          ),
        ],
      ],
    );
  }
}

final class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}
