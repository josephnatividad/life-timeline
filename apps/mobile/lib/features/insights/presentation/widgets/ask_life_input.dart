import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';

final class AskLifeInput extends StatelessWidget {
  const AskLifeInput({
    required this.controller,
    required this.onSubmit,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Ask a question about your confirmed timeline',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          key: const Key('ask-life-input'),
          controller: controller,
          enabled: enabled,
          label: 'Ask your life',
          hintText: 'How many phones have I owned?',
          leadingIcon: AppIcons.intelligence,
          onSubmitted: enabled ? _submit : null,
          textInputAction: TextInputAction.search,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          key: const Key('ask-life-submit'),
          expanded: true,
          icon: AppIcons.intelligence,
          label: 'Find an answer',
          onPressed: enabled ? () => _submit(controller.text) : null,
        ),
      ],
    ),
  );

  void _submit(String value) {
    final question = value.trim();
    if (question.isNotEmpty) onSubmit(question);
  }
}

final class SuggestedQuestionChip extends StatelessWidget {
  const SuggestedQuestionChip({
    required this.label,
    required this.onSelected,
    super.key,
  });

  final String label;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => AppChip(
    label: label,
    icon: AppIcons.intelligence,
    onSelected: (_) => onSelected(),
  );
}
