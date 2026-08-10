import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class LifecycleMemoryCard extends StatelessWidget {
  const LifecycleMemoryCard({
    required this.memory,
    required this.primaryActionIcon,
    required this.primaryActionLabel,
    this.onOpen,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.secondaryActionLabel,
    super.key,
  });

  final TimelineMemory memory;
  final VoidCallback? onOpen;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final AppIconData primaryActionIcon;
  final String primaryActionLabel;
  final AppIconData? secondaryActionIcon;
  final String? secondaryActionLabel;

  @override
  Widget build(BuildContext context) => MemoryCard(
    title: memory.event.title,
    metadata: TemporalDisplay.label(memory.event.temporalValue),
    subtitle: memory.event.eventType,
    semanticLabel:
        '${memory.event.title}. ${TemporalDisplay.label(memory.event.temporalValue)}',
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onPrimaryAction != null)
          AppIconButton(
            icon: primaryActionIcon,
            label: primaryActionLabel,
            onPressed: onPrimaryAction,
          ),
        if (onSecondaryAction != null &&
            secondaryActionIcon != null &&
            secondaryActionLabel != null)
          AppIconButton(
            icon: secondaryActionIcon!,
            label: secondaryActionLabel!,
            color: Theme.of(context).colorScheme.error,
            onPressed: onSecondaryAction,
          ),
      ],
    ),
    onTap: onOpen,
  );
}
