import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/motion/app_motion.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';
import 'package:life_timeline/design_system/tokens/app_radius.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

enum AppButtonVariant { primary, secondary, tertiary, destructive }

final class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.expanded = false,
    this.icon,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    super.key,
  });

  final bool expanded;
  final AppIconData? icon;
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final child = Semantics(
      liveRegion: loading,
      label: loading ? '$label, loading' : null,
      child: _ButtonContent(icon: icon, label: label, loading: loading),
    );
    final callback = loading ? null : onPressed;
    final style = ButtonStyle(
      animationDuration: AppMotion.resolve(context, AppMotion.quick),
      minimumSize: const WidgetStatePropertyAll(
        Size(0, AppIconSize.touchTarget),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
    );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      AppButtonVariant.tertiary => TextButton(
        onPressed: callback,
        style: style,
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: callback,
        style: style.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.error,
          ),
          foregroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.onError,
          ),
        ),
        child: child,
      ),
    };

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

final class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.icon,
    required this.label,
    required this.loading,
  });

  final AppIconData? icon;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: AppSpacing.xs,
    children: [
      if (loading)
        SizedBox.square(
          dimension: AppIconSize.compact,
          child: AppMotion.reduced(context)
              ? const AppIcon(icon: AppIcons.loading, size: AppIconSize.compact)
              : const CircularProgressIndicator(strokeWidth: 2),
        )
      else if (icon case final icon?)
        AppIcon(icon: icon, size: AppIconSize.compact),
      Text(label, textAlign: TextAlign.center),
    ],
  );
}
