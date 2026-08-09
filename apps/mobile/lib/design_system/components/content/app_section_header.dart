import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

final class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.action,
    this.supportingText,
    super.key,
  });

  final Widget? action;
  final String? supportingText;
  final String title;

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (supportingText case final supportingText?) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(supportingText, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );

    if (action == null) {
      return text;
    }

    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          text,
          const SizedBox(height: AppSpacing.xs),
          Align(alignment: Alignment.centerLeft, child: action),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: text),
        const SizedBox(width: AppSpacing.md),
        action!,
      ],
    );
  }
}
