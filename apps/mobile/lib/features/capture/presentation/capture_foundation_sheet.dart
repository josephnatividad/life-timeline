import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/components/overlays/app_bottom_sheet.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

final class CaptureFoundationSheet extends StatelessWidget {
  const CaptureFoundationSheet({required this.onAddMemory, super.key});

  final VoidCallback onAddMemory;

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
        ListTile(
          key: const Key('capture-manual-memory'),
          contentPadding: EdgeInsets.zero,
          leading: const AppIcon(icon: AppIcons.capture),
          title: const Text('Add memory manually'),
          subtitle: const Text('Create a confirmed timeline memory.'),
          trailing: const AppIcon(icon: AppIcons.next),
          onTap: onAddMemory,
        ),
      ],
    ),
  );
}
