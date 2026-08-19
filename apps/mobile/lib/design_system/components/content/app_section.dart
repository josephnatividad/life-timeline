import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/components/actions/app_button.dart';
import 'package:life_timeline/design_system/components/content/app_section_header.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

/// Editorial grouping for a screen section without introducing a card surface.
final class AppSection extends StatelessWidget {
  const AppSection({
    required this.child,
    required this.title,
    this.action,
    this.count,
    this.supportingText,
    super.key,
  });

  final Widget? action;
  final Widget child;
  final int? count;
  final String? supportingText;
  final String title;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppSectionHeader(
        title: title,
        count: count,
        supportingText: supportingText,
        action: action,
      ),
      const SizedBox(height: AppSpacing.sm),
      child,
    ],
  );
}

/// A bounded collection preview with one consistent, accessible drill-down.
final class AppCollectionPreview extends StatelessWidget {
  const AppCollectionPreview({
    required this.child,
    required this.title,
    this.count,
    this.onViewAll,
    this.supportingText,
    this.viewAllLabel,
    super.key,
  }) : assert(
         (onViewAll == null) == (viewAllLabel == null),
         'View-all label and callback must be supplied together.',
       );

  final Widget child;
  final int? count;
  final VoidCallback? onViewAll;
  final String? supportingText;
  final String title;
  final String? viewAllLabel;

  @override
  Widget build(BuildContext context) => AppSection(
    title: title,
    count: count,
    supportingText: supportingText,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        if (onViewAll != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: viewAllLabel!,
              variant: AppButtonVariant.tertiary,
              onPressed: onViewAll,
            ),
          ),
        ],
      ],
    ),
  );
}
