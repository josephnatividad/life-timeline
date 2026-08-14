import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';

final class MemoryMediaCaptionSheet extends StatefulWidget {
  const MemoryMediaCaptionSheet({required this.initialCaption, super.key});

  final String? initialCaption;

  static Future<String?> show({
    required BuildContext context,
    required String? initialCaption,
  }) => AppBottomSheet.show<String?>(
    context: context,
    builder: (_) => MemoryMediaCaptionSheet(initialCaption: initialCaption),
  );

  @override
  State<MemoryMediaCaptionSheet> createState() =>
      _MemoryMediaCaptionSheetState();
}

final class _MemoryMediaCaptionSheetState
    extends State<MemoryMediaCaptionSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCaption);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppBottomSheet(
    title: 'Photo caption',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          key: const Key('photo-caption-input'),
          controller: _controller,
          label: 'Caption',
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          key: const Key('save-photo-caption'),
          label: 'Save caption',
          expanded: true,
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    ),
  );
}
