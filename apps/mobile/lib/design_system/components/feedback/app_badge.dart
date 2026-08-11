import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';
import 'package:life_timeline/design_system/tokens/app_radius.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

enum AppBadgeTone { neutral, primary, danger }

final class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.icon,
    this.tone = AppBadgeTone.neutral,
    super.key,
  });

  final AppIconData? icon;
  final String label;
  final AppBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground, border) = switch (tone) {
      AppBadgeTone.neutral => (
        colors.surfaceContainer,
        colors.onSurfaceVariant,
        colors.outlineVariant,
      ),
      AppBadgeTone.primary => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        colors.primary,
      ),
      AppBadgeTone.danger => (
        colors.errorContainer,
        colors.onErrorContainer,
        colors.error,
      ),
    };

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon case final icon?) ...[
                  AppIcon(
                    icon: icon,
                    color: foreground,
                    size: AppIconSize.compact,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PrivacyBadgeLevel { shareSafe, personal, sensitive, neverShare }

final class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({required this.level, super.key});

  final PrivacyBadgeLevel level;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (level) {
      PrivacyBadgeLevel.shareSafe => ('Share safe', AppBadgeTone.neutral),
      PrivacyBadgeLevel.personal => ('Personal', AppBadgeTone.neutral),
      PrivacyBadgeLevel.sensitive => ('Sensitive', AppBadgeTone.primary),
      PrivacyBadgeLevel.neverShare => ('Never share', AppBadgeTone.danger),
    };

    return AppBadge(icon: AppIcons.privacy, label: label, tone: tone);
  }
}
