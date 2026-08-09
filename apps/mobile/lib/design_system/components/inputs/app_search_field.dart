import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/components/actions/app_icon_button.dart';
import 'package:life_timeline/design_system/components/inputs/app_text_field.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';

final class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.semanticLabel = 'Search',
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String semanticLabel;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

final class _AppSearchFieldState extends State<AppSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) => Semantics(
    textField: true,
    label: widget.semanticLabel,
    child: AppTextField(
      controller: widget.controller,
      enabled: widget.enabled,
      hintText: widget.hintText,
      label: widget.semanticLabel,
      leadingIcon: AppIcons.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      suffix: widget.controller.text.isEmpty
          ? null
          : AppIconButton(
              icon: AppIcons.clear,
              label: 'Clear search',
              onPressed: () {
                widget.controller.clear();
                widget.onChanged?.call('');
              },
            ),
    ),
  );
}
