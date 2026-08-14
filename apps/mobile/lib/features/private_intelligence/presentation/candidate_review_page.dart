import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/private_intelligence/application/confirm_candidate_use_case.dart';
import 'package:life_timeline/features/private_intelligence/application/intelligence_providers.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/shared/domain/model/memory_candidate.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

final class CandidateReviewPage extends ConsumerWidget {
  const CandidateReviewPage({required this.candidateId, super.key});
  final String candidateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(candidateProvider(candidateId));
    return AppScaffold(
      appBar: AppBar(title: const Text('Review memory')),
      body: candidate.when(
        loading: () =>
            const Center(child: AppLoadingState(label: 'Opening review')),
        error: (error, stack) => Center(
          child: AppErrorState(
            title: 'Review unavailable',
            message: 'This suggestion could not be opened locally.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(candidateProvider(candidateId)),
          ),
        ),
        data: (value) => value == null
            ? const Center(
                child: AppEmptyState(
                  title: 'Suggestion not found',
                  message: 'It may already have been resolved.',
                ),
              )
            : _CandidateReviewForm(candidate: value),
      ),
    );
  }
}

final class _CandidateReviewForm extends ConsumerStatefulWidget {
  const _CandidateReviewForm({required this.candidate});
  final MemoryCandidate candidate;

  @override
  ConsumerState<_CandidateReviewForm> createState() =>
      _CandidateReviewFormState();
}

final class _CandidateReviewFormState
    extends ConsumerState<_CandidateReviewForm> {
  late final TextEditingController _title;
  late final List<TextEditingController> _fields;
  late final TextEditingController _newEntity;
  String? _linkedEntityId;
  bool _saving = false;
  bool _ignored = false;
  bool _addReminder = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.candidate.title);
    _fields = [
      for (final field in widget.candidate.extractedFields)
        TextEditingController(text: field.value),
    ];
    final proposal = widget.candidate.entityProposals.isEmpty
        ? null
        : widget.candidate.entityProposals.first;
    _linkedEntityId = proposal?.suggestedEntityId;
    _newEntity = TextEditingController(
      text: proposal?.suggestedEntityId == null ? proposal?.name : null,
    );
  }

  @override
  void dispose() {
    _title.dispose();
    for (final controller in _fields) {
      controller.dispose();
    }
    _newEntity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ignored) {
      return Center(
        child: AppEmptyState(
          title: 'Suggestion ignored',
          message: 'It will stay out of your timeline.',
          actionLabel: 'Undo',
          onAction: _undoIgnore,
        ),
      );
    }
    final candidate = widget.candidate;
    final proposal = candidate.entityProposals.isEmpty
        ? null
        : candidate.entityProposals.first;
    final reminderSuggestion = CandidateReminderSuggestion.from(
      candidate.documentType,
      candidate.extractedFields,
    );
    final isManualDocument =
        candidate.extractedFields.isEmpty &&
        candidate.overallConfidence == null;
    return SingleChildScrollView(
      child: ScreenContainer(
        maxWidth: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntelligenceCard(
              title: isManualDocument
                  ? 'A private document draft'
                  : 'A reviewable suggestion',
              body: isManualDocument
                  ? 'No text was read automatically. Add a clear title, then confirm when this document belongs in your timeline.'
                  : _confidenceCopy(candidate.overallConfidence),
            ),
            if (candidate.possibleDuplicateEventId case final eventId?) ...[
              const SizedBox(height: AppSpacing.md),
              IntelligenceCard(
                title: 'This may already be in your timeline',
                body:
                    'The title and date match an existing memory. Compare them before confirming.',
                actionLabel: 'View existing memory',
                onAction: () => context.pushNamed(
                  AppRoute.memoryDetail.name,
                  pathParameters: {'memoryId': eventId},
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppBadge(
                  label: isManualDocument
                      ? 'Document evidence'
                      : _documentLabel(candidate.documentType),
                ),
                PrivacyBadge(
                  level: PrivacyBadgeLevel
                      .values[candidate.metadata.privacyClassification.index],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              key: const Key('candidate-title'),
              controller: _title,
              label: 'Memory title',
              helperText: 'This becomes the timeline title after confirmation.',
            ),
            for (
              var index = 0;
              index < candidate.extractedFields.length;
              index++
            ) ...[
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                key: Key('candidate-field-$index'),
                controller: _fields[index],
                label: _fieldLabel(candidate.extractedFields[index].key),
                helperText: _fieldConfidence(candidate.extractedFields[index]),
              ),
            ],
            if (proposal != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Related item',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (proposal.suggestedEntityId != null)
                ListTile(
                  title: Text('Link to ${proposal.name}'),
                  subtitle: Text(proposal.matchReasons.join(' · ')),
                  trailing: _linkedEntityId == proposal.suggestedEntityId
                      ? const AppIcon(icon: AppIcons.success)
                      : null,
                  onTap: () => setState(
                    () => _linkedEntityId = proposal.suggestedEntityId,
                  ),
                ),
              ListTile(
                title: const Text('Create a new related item'),
                trailing: _linkedEntityId == null
                    ? const AppIcon(icon: AppIcons.success)
                    : null,
                onTap: () => setState(() => _linkedEntityId = null),
              ),
              if (_linkedEntityId == null)
                AppTextField(
                  controller: _newEntity,
                  label: 'Related item name',
                ),
            ],
            if (reminderSuggestion != null) ...[
              const SizedBox(height: AppSpacing.xl),
              IntelligenceCard(
                title: 'Reminder suggestion',
                body:
                    '${_fieldLabel(reminderSuggestion.type.name)} date found. ${_reminderLeadLabel(reminderSuggestion.leadTime)} is a useful starting point.',
              ),
              SwitchListTile.adaptive(
                key: const Key('candidate-add-reminder'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Add reminder when confirmed'),
                subtitle: const Text(
                  'Nothing is scheduled until you choose this option.',
                ),
                value: _addReminder,
                onChanged: (value) => setState(() => _addReminder = value),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              key: const Key('confirm-candidate'),
              label: 'Confirm to timeline',
              icon: AppIcons.success,
              expanded: true,
              loading: _saving,
              onPressed: _saving ? null : _confirm,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              key: const Key('ignore-candidate'),
              label: 'Ignore suggestion',
              variant: AppButtonVariant.tertiary,
              expanded: true,
              onPressed: _saving ? null : _ignore,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    try {
      final fields = <ExtractedField>[
        for (
          var index = 0;
          index < widget.candidate.extractedFields.length;
          index++
        )
          widget.candidate.extractedFields[index].copyWith(
            value: _fields[index].text.trim(),
            reviewRecommended: false,
          ),
      ];
      final eventId = await ref
          .read(confirmCandidateUseCaseProvider)
          .call(
            widget.candidate.metadata.id,
            CandidateReviewDraft(
              title: _title.text,
              fields: fields,
              linkedEntityId: _linkedEntityId,
              createEntityName: _linkedEntityId == null
                  ? _newEntity.text
                  : null,
              createSuggestedReminder: _addReminder,
            ),
          );
      ref.invalidate(pendingCandidatesProvider);
      if (!mounted) return;
      context.pushReplacementNamed(
        AppRoute.memoryDetail.name,
        pathParameters: {'memoryId': eventId},
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This memory could not be confirmed. Your candidate is still safe.',
          ),
        ),
      );
      setState(() => _saving = false);
    }
  }

  Future<void> _ignore() async {
    await ref
        .read(candidateReviewRepositoryProvider)
        .setReviewStatus(
          widget.candidate.metadata.id,
          CandidateReviewStatus.ignored,
          DateTime.now(),
        );
    ref.invalidate(pendingCandidatesProvider);
    if (mounted) setState(() => _ignored = true);
  }

  Future<void> _undoIgnore() async {
    await ref
        .read(candidateReviewRepositoryProvider)
        .setReviewStatus(
          widget.candidate.metadata.id,
          CandidateReviewStatus.pending,
          DateTime.now(),
        );
    ref.invalidate(pendingCandidatesProvider);
    if (mounted) setState(() => _ignored = false);
  }
}

String _reminderLeadLabel(ReminderLeadTime value) => switch (value) {
  ReminderLeadTime.thirtyDays => '30 days before',
  ReminderLeadTime.ninetyDays => '90 days before',
  ReminderLeadTime.sixMonths => '6 months before',
  _ => 'A reminder',
};

String _confidenceCopy(double? confidence) {
  if (confidence == null || confidence < 0.55) {
    return 'The document type or several fields are uncertain. Check them before confirming.';
  }
  if (confidence < 0.75) {
    return 'Some details may need correction. Nothing reaches your timeline without confirmation.';
  }
  return 'The local reading looks useful. Please confirm the important details.';
}

String _fieldConfidence(ExtractedField field) {
  if (field.privacyClassification == PrivacyClassification.neverShare) {
    return 'Never share · verify carefully';
  }
  if (field.confidence < 0.7 || field.reviewRecommended) {
    return 'Needs a closer look';
  }
  return 'Read locally from the image';
}

String _documentLabel(DocumentType type) =>
    '${_fieldLabel(type.name)} suggestion';

String _fieldLabel(String value) {
  final spaced = value.replaceAllMapped(
    RegExp(r'([A-Z])'),
    (match) => ' ${match.group(1)}',
  );
  return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}
