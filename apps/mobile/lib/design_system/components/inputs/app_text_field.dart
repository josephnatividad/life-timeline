import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';

final class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.autofillHints,
    this.controller,
    this.enabled = true,
    this.errorText,
    this.helperText,
    this.hintText,
    this.keyboardType,
    this.leadingIcon,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.suffix,
    this.textInputAction,
    super.key,
  });

  final Iterable<String>? autofillHints;
  final TextEditingController? controller;
  final bool enabled;
  final String? errorText;
  final String? helperText;
  final String? hintText;
  final TextInputType? keyboardType;
  final AppIconData? leadingIcon;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final Widget? suffix;
  final String label;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) => TextFormField(
    autofillHints: autofillHints,
    controller: controller,
    enabled: enabled,
    keyboardType: keyboardType,
    maxLines: obscureText ? 1 : maxLines,
    minLines: minLines,
    obscureText: obscureText,
    onChanged: onChanged,
    onFieldSubmitted: onSubmitted,
    textInputAction: textInputAction,
    decoration: InputDecoration(
      errorText: errorText,
      helperText: helperText,
      hintText: hintText,
      labelText: label,
      prefixIcon: leadingIcon == null
          ? null
          : AppIcon(icon: leadingIcon!, size: AppIconSize.standard),
      suffixIcon: suffix,
    ),
  );
}
