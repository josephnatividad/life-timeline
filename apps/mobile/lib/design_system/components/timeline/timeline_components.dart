import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/motion/app_motion.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';
import 'package:life_timeline/design_system/tokens/app_radius.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

enum TimelineNodeState { confirmed, candidate, milestone }

final class TimelineNode extends StatelessWidget {
  const TimelineNode({
    required this.icon,
    required this.label,
    this.selected = false,
    this.state = TimelineNodeState.confirmed,
    super.key,
  });

  final AppIconData icon;
  final String label;
  final bool selected;
  final TimelineNodeState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final stateLabel = switch (state) {
      TimelineNodeState.confirmed => 'Confirmed',
      TimelineNodeState.candidate => 'Candidate',
      TimelineNodeState.milestone => 'Milestone',
    };
    final foreground = selected || state == TimelineNodeState.milestone
        ? colors.primary
        : colors.onSurfaceVariant;
    final background = selected
        ? colors.primaryContainer
        : colors.surfaceContainer;

    return Semantics(
      image: true,
      label: '$label. $stateLabel${selected ? '. Selected' : ''}',
      selected: selected,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: AppMotion.resolve(context, AppMotion.quick),
          curve: AppMotion.standardCurve,
          width: AppSpacing.xxxl,
          height: AppSpacing.xxxl,
          decoration: BoxDecoration(
            color: background,
            border: Border.all(
              color: selected ? colors.primary : colors.outline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Center(
            child: AppIcon(
              icon: icon,
              color: foreground,
              size: AppIconSize.compact,
            ),
          ),
        ),
      ),
    );
  }
}

final class TimelineConnector extends StatelessWidget {
  const TimelineConnector({
    this.emphasized = false,
    this.height = AppSpacing.huge,
    super.key,
  });

  final bool emphasized;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thickness = theme.dividerTheme.thickness ?? 1;

    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        child: Center(
          child: SizedBox(
            width: thickness,
            child: ColoredBox(
              color: emphasized
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
        ),
      ),
    );
  }
}

final class TimelineSectionHeader extends StatelessWidget {
  const TimelineSectionHeader({
    required this.period,
    this.description,
    this.trailing,
    super.key,
  });

  final String? description;
  final String period;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    header: true,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(period, style: Theme.of(context).textTheme.headlineMedium),
              if (description case final description?) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing case final trailing?) ...[
          const SizedBox(width: AppSpacing.md),
          trailing,
        ],
      ],
    ),
  );
}
