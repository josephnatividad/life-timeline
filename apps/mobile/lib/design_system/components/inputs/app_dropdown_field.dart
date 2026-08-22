import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';

/// A tokenized dropdown that keeps app-owned indicator icons behind [AppIcons].
final class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.items,
    required this.label,
    required this.onChanged,
    this.errorText,
    this.initialValue,
    super.key,
  });

  final String? errorText;
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final String label;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: initialValue,
    decoration: InputDecoration(labelText: label, errorText: errorText),
    icon: const AppIcon(icon: AppIcons.expand, size: AppIconSize.compact),
    items: items,
    onChanged: onChanged,
  );
}
