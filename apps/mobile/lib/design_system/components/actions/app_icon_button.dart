import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';

final class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.iconSize = AppIconSize.standard,
    super.key,
  });

  final Color? color;
  final AppIconData icon;
  final double iconSize;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: label,
    child: Tooltip(
      message: label,
      child: IconButton(
        onPressed: onPressed,
        icon: AppIcon(icon: icon, color: color, size: iconSize),
      ),
    ),
  );
}
