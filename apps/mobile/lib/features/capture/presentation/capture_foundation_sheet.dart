import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/components/overlays/app_bottom_sheet.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

final class CaptureFoundationSheet extends StatelessWidget {
  const CaptureFoundationSheet({super.key});

  @override
  Widget build(BuildContext context) => AppBottomSheet(
    title: 'Capture',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppIcon(
          icon: AppIcons.capture,
          semanticLabel: 'Capture',
          size: 32,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Capture modes will be added in a separate feature implementation.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
