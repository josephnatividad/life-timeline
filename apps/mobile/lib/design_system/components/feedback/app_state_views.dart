import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/components/actions/app_button.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/motion/app_motion.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

enum AppEmptyStateVariant { hero, section, compact }

final class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    this.actionLabel,
    this.icon = AppIcons.information,
    this.message,
    this.onAction,
    this.onSecondaryAction,
    this.secondaryActionLabel,
    this.variant = AppEmptyStateVariant.hero,
    super.key,
  });

  final String? actionLabel;
  final AppIconData icon;
  final String? message;
  final VoidCallback? onAction;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;
  final String title;
  final AppEmptyStateVariant variant;

  @override
  Widget build(BuildContext context) => _AppStateLayout(
    actionLabel: actionLabel,
    icon: icon,
    message: message,
    onAction: onAction,
    onSecondaryAction: onSecondaryAction,
    secondaryActionLabel: secondaryActionLabel,
    title: title,
    variant: variant,
  );
}

/// A query completed successfully, but its current query or filters matched
/// no content. This is intentionally distinct from a genuinely empty source.
final class AppNoResultsState extends StatelessWidget {
  const AppNoResultsState({
    required this.title,
    this.actionLabel,
    this.message,
    this.onAction,
    this.variant = AppEmptyStateVariant.hero,
    super.key,
  });

  final String? actionLabel;
  final String? message;
  final VoidCallback? onAction;
  final String title;
  final AppEmptyStateVariant variant;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'No results',
    child: AppEmptyState(
      title: title,
      message: message,
      actionLabel: actionLabel,
      icon: AppIcons.search,
      onAction: onAction,
      variant: variant,
    ),
  );
}

/// A capability or requested local resource is not currently available.
final class AppUnavailableState extends StatelessWidget {
  const AppUnavailableState({
    required this.title,
    this.actionLabel,
    this.icon = AppIcons.information,
    this.message,
    this.onAction,
    this.variant = AppEmptyStateVariant.hero,
    super.key,
  });

  final String? actionLabel;
  final AppIconData icon;
  final String? message;
  final VoidCallback? onAction;
  final String title;
  final AppEmptyStateVariant variant;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Unavailable',
    child: AppEmptyState(
      title: title,
      message: message,
      actionLabel: actionLabel,
      icon: icon,
      onAction: onAction,
      variant: variant,
    ),
  );
}

/// A capability exists, but the user must grant or establish access first.
final class AppPermissionRequiredState extends StatelessWidget {
  const AppPermissionRequiredState({
    required this.title,
    this.actionLabel,
    this.message,
    this.onAction,
    this.variant = AppEmptyStateVariant.hero,
    super.key,
  });

  final String? actionLabel;
  final String? message;
  final VoidCallback? onAction;
  final String title;
  final AppEmptyStateVariant variant;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Permission required',
    child: AppEmptyState(
      title: title,
      message: message,
      actionLabel: actionLabel,
      icon: AppIcons.privacy,
      onAction: onAction,
      variant: variant,
    ),
  );
}

/// A zero state that represents a successful, clear, or completed condition.
final class AppCompletedState extends StatelessWidget {
  const AppCompletedState({
    required this.title,
    this.actionLabel,
    this.icon = AppIcons.success,
    this.message,
    this.onAction,
    this.variant = AppEmptyStateVariant.hero,
    super.key,
  });

  final String? actionLabel;
  final AppIconData icon;
  final String? message;
  final VoidCallback? onAction;
  final String title;
  final AppEmptyStateVariant variant;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Complete',
    child: AppEmptyState(
      title: title,
      message: message,
      actionLabel: actionLabel,
      icon: icon,
      onAction: onAction,
      variant: variant,
    ),
  );
}

final class AppLoadingState extends StatelessWidget {
  const AppLoadingState({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: AppIconSize.feature,
            child: AppMotion.reduced(context)
                ? const AppIcon(
                    icon: AppIcons.loading,
                    size: AppIconSize.feature,
                  )
                : const CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    ),
  );
}

final class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.message,
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String? actionLabel;
  final String message;
  final VoidCallback? onAction;
  final String title;

  @override
  Widget build(BuildContext context) => _AppStateLayout(
    actionLabel: actionLabel,
    icon: AppIcons.error,
    iconColor: Theme.of(context).colorScheme.error,
    message: message,
    onAction: onAction,
    title: title,
  );
}

final class _AppStateLayout extends StatelessWidget {
  const _AppStateLayout({
    required this.icon,
    required this.message,
    required this.title,
    this.actionLabel,
    this.iconColor,
    this.onAction,
    this.onSecondaryAction,
    this.secondaryActionLabel,
    this.variant = AppEmptyStateVariant.hero,
  });

  final String? actionLabel;
  final AppIconData icon;
  final Color? iconColor;
  final String? message;
  final VoidCallback? onAction;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;
  final String title;
  final AppEmptyStateVariant variant;

  @override
  Widget build(BuildContext context) {
    final compact = variant == AppEmptyStateVariant.compact;
    final section = variant == AppEmptyStateVariant.section;
    final alignment = compact || section
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final textAlign = compact || section ? TextAlign.start : TextAlign.center;
    final padding = switch (variant) {
      AppEmptyStateVariant.hero => const EdgeInsets.all(AppSpacing.xl),
      AppEmptyStateVariant.section => const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      AppEmptyStateVariant.compact => const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
      ),
    };
    return Semantics(
      container: true,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignment,
          children: [
            if (!compact) ...[
              AppIcon(
                icon: icon,
                color: iconColor,
                semanticLabel: iconColor == null ? null : 'Error',
                size: section ? AppIconSize.feature : AppIconSize.signature,
              ),
              SizedBox(height: section ? AppSpacing.sm : AppSpacing.md),
            ],
            Text(
              title,
              style: compact
                  ? Theme.of(context).textTheme.titleMedium
                  : Theme.of(context).textTheme.titleLarge,
              textAlign: textAlign,
            ),
            if (message case final message? when message.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: compact
                    ? Theme.of(context).textTheme.bodyMedium
                    : Theme.of(context).textTheme.bodyLarge,
                textAlign: textAlign,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(
                height: compact || section ? AppSpacing.sm : AppSpacing.lg,
              ),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.secondary,
              ),
            ],
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: secondaryActionLabel!,
                onPressed: onSecondaryAction,
                variant: AppButtonVariant.tertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
