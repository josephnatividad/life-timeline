import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';

final class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    this.icon,
    this.onDeleted,
    this.onSelected,
    this.selected = false,
    super.key,
  });

  final AppIconData? icon;
  final String label;
  final VoidCallback? onDeleted;
  final ValueChanged<bool>? onSelected;
  final bool selected;

  @override
  Widget build(BuildContext context) => FilterChip(
    avatar: icon == null
        ? null
        : AppIcon(icon: icon!, size: AppIconSize.compact),
    label: Text(label),
    onDeleted: onDeleted,
    onSelected: onSelected,
    selected: selected,
    showCheckmark: false,
  );
}
