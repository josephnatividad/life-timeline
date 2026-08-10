import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/tokens/app_radius.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

/// Presentation-only base for a memory/event summary.
///
/// Domain objects, temporal precision, privacy state, and actions are supplied
/// by the caller through text and composed widgets.
final class MemoryCard extends StatelessWidget {
  const MemoryCard({
    required this.title,
    this.badge,
    this.image,
    this.metadata,
    this.onTap,
    this.semanticLabel,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final Widget? badge;
  final Widget? image;
  final String? metadata;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? subtitle;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final useStackedActions =
        trailing != null && MediaQuery.textScalerOf(context).scale(1) >= 1.3;
    final summary = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (image case final image?) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.smallControl),
            child: image,
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (metadata case final metadata?) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(metadata, style: Theme.of(context).textTheme.labelSmall),
              ],
              if (subtitle case final subtitle?) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
              if (badge case final badge?) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(alignment: Alignment.centerLeft, child: badge),
              ],
            ],
          ),
        ),
        if (!useStackedActions)
          if (trailing case final trailing?) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing,
          ],
      ],
    );
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          summary,
          if (useStackedActions) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      container: true,
      label: semanticLabel,
      child: Card(
        child: onTap == null
            ? content
            : InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: onTap,
                child: content,
              ),
      ),
    );
  }
}
