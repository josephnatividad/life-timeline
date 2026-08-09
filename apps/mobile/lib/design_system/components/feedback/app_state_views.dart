import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/components/actions/app_button.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/motion/app_motion.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

final class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.message,
    required this.title,
    this.actionLabel,
    this.icon = AppIcons.information,
    this.onAction,
    super.key,
  });

  final String? actionLabel;
  final AppIconData icon;
  final String message;
  final VoidCallback? onAction;
  final String title;

  @override
  Widget build(BuildContext context) => _AppStateLayout(
    actionLabel: actionLabel,
    icon: icon,
    message: message,
    onAction: onAction,
    title: title,
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
  });

  final String? actionLabel;
  final AppIconData icon;
  final Color? iconColor;
  final String message;
  final VoidCallback? onAction;
  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            icon: icon,
            color: iconColor,
            semanticLabel: iconColor == null ? null : 'Error',
            size: AppIconSize.signature,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: actionLabel!,
              onPressed: onAction,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ],
      ),
    ),
  );
}
