import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/application/memory_editor_draft.dart';
import 'package:life_timeline/features/timeline/application/memory_use_cases.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/temporal_input.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

final class MemoryEditor extends ConsumerStatefulWidget {
  const MemoryEditor({required this.onSaved, this.initialDraft, super.key});

  final MemoryEditorDraft? initialDraft;
  final ValueChanged<String> onSaved;

  @override
  ConsumerState<MemoryEditor> createState() => _MemoryEditorState();
}

final class _MemoryEditorState extends ConsumerState<MemoryEditor> {
  late final _title = TextEditingController(text: widget.initialDraft?.title);
  late final _eventType = TextEditingController(
    text: widget.initialDraft?.eventType,
  );
  late final _category = TextEditingController(
    text: widget.initialDraft?.categoryName,
  );
  late final _description = TextEditingController(
    text: widget.initialDraft?.description,
  );
  late final _relatedEntity = TextEditingController(
    text: widget.initialDraft?.relatedEntityName,
  );
  late TemporalValue? _temporalValue = widget.initialDraft?.temporalValue;
  late PrivacyClassification? _privacy =
      widget.initialDraft?.privacyClassification;
  var _showErrors = false;
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _eventType.dispose();
    _category.dispose();
    _description.dispose();
    _relatedEntity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppTextField(
        key: const Key('memory-title'),
        controller: _title,
        label: 'Title',
        hintText: 'What happened?',
        errorText: _showErrors && _title.text.trim().isEmpty
            ? 'Add a title.'
            : null,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        key: const Key('memory-type'),
        controller: _eventType,
        label: 'Memory type',
        hintText: 'Graduated, moved, purchased…',
        errorText: _showErrors && _eventType.text.trim().isEmpty
            ? 'Add a memory type.'
            : null,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        key: const Key('memory-category'),
        controller: _category,
        label: 'Category',
        hintText: 'Education, travel, work…',
        errorText: _showErrors && _category.text.trim().isEmpty
            ? 'Add a category.'
            : null,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: AppSpacing.lg),
      TemporalInput(
        initialValue: widget.initialDraft?.temporalValue,
        onChanged: (value) => _temporalValue = value,
        showError: _showErrors,
      ),
      const SizedBox(height: AppSpacing.lg),
      Text('Privacy', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Choose how this memory should be classified.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final classification in PrivacyClassification.values)
            AppChip(
              key: ValueKey('privacy-${classification.name}'),
              label: _privacyLabel(classification),
              icon: AppIcons.privacy,
              selected: _privacy == classification,
              onSelected: (_) => setState(() => _privacy = classification),
            ),
        ],
      ),
      if (_showErrors && _privacy == null) ...[
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Choose a privacy classification.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      ExpansionTile(
        key: const Key('memory-more-details'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        title: const Text('More details'),
        children: [
          AppTextField(
            key: const Key('memory-description'),
            controller: _description,
            label: 'Description',
            hintText: 'Optional context',
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: const Key('memory-related-entity'),
            controller: _relatedEntity,
            label: 'Related person, place, or thing',
            hintText: 'Optional',
          ),
        ],
      ),
      if (_error case final error?) ...[
        const SizedBox(height: AppSpacing.md),
        Semantics(
          liveRegion: true,
          child: Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        key: const Key('save-memory'),
        label: widget.initialDraft == null ? 'Save memory' : 'Save changes',
        loading: _saving,
        expanded: true,
        onPressed: _save,
      ),
    ],
  );

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _showErrors = true;
      _error = null;
    });
    if (_title.text.trim().isEmpty ||
        _eventType.text.trim().isEmpty ||
        _category.text.trim().isEmpty ||
        _temporalValue == null ||
        _privacy == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      final existing = widget.initialDraft;
      final id = await ref.read(saveMemoryUseCaseProvider)(
        MemoryEditorDraft(
          eventId: existing?.eventId,
          createdAt: existing?.createdAt,
          relatedEntityId: existing?.relatedEntityId,
          relationshipId: existing?.relationshipId,
          categoryId: existing?.categoryId,
          title: _title.text,
          eventType: _eventType.text,
          categoryName: _category.text,
          temporalValue: _temporalValue!,
          privacyClassification: _privacy!,
          lifecycle: existing?.lifecycle ?? RecordLifecycle.confirmed,
          description: _description.text,
          relatedEntityName: _relatedEntity.text,
        ),
      );
      if (mounted) {
        widget.onSaved(id);
      }
    } on MemoryValidationException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } on Object {
      if (mounted) {
        setState(() => _error = 'This memory could not be saved. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String _privacyLabel(PrivacyClassification value) => switch (value) {
    PrivacyClassification.shareSafe => 'Share safe',
    PrivacyClassification.personal => 'Personal',
    PrivacyClassification.sensitive => 'Sensitive',
    PrivacyClassification.neverShare => 'Never share',
  };
}
