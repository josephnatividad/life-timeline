import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/stories/application/story_template_catalog.dart';
import 'package:life_timeline/features/stories/domain/milestone_models.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

final class StoryTemplateChooser extends StatelessWidget {
  const StoryTemplateChooser({
    required this.source,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ValueChanged<StoryTemplateId> onSelected;
  final StoryTemplateId selected;
  final StorySource source;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Story template chooser',
    child: Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final template in StoryTemplateCatalog.forSource(source))
          AppChip(
            key: Key('story-template-${template.id.name}'),
            label: template.label,
            icon: AppIcons.stories,
            selected: template.id == selected,
            onSelected: (_) => onSelected(template.id),
          ),
      ],
    ),
  );
}

final class StoryThemeChooser extends StatelessWidget {
  const StoryThemeChooser({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ValueChanged<StoryThemeVariant> onSelected;
  final StoryThemeVariant selected;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Story color theme chooser',
    child: Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final variant in StoryThemeVariant.values)
          AppChip(
            key: Key('story-theme-${variant.name}'),
            label: _themeLabel(variant),
            selected: variant == selected,
            onSelected: (_) => onSelected(variant),
          ),
      ],
    ),
  );
}

final class StoryPrivacySelector extends StatelessWidget {
  const StoryPrivacySelector({
    required this.source,
    required this.selection,
    required this.onChanged,
    super.key,
  });

  final ValueChanged<StoryPrivacySelection> onChanged;
  final StoryPrivacySelection selection;
  final StorySource source;

  @override
  Widget build(BuildContext context) {
    final eligibleFields = source.fields.where(
      (field) =>
          field.privacyClassification != PrivacyClassification.neverShare,
    );
    final protectedItemCount =
        source.fields
            .where(
              (field) =>
                  field.privacyClassification ==
                  PrivacyClassification.neverShare,
            )
            .length +
        source.media
            .where(
              (media) =>
                  media.privacyClassification ==
                  PrivacyClassification.neverShare,
            )
            .length;
    return Semantics(
      container: true,
      label: 'Choose what appears in the Story',
      child: Column(
        children: [
          for (final field in eligibleFields)
            _PrivacyToggle(
              key: Key('story-field-${field.id}'),
              label: field.label,
              supportingText: _privacyLabel(field.privacyClassification),
              selected: selection.includedFieldIds.contains(field.id),
              onChanged: (selected) {
                final ids = {...selection.includedFieldIds};
                selected ? ids.add(field.id) : ids.remove(field.id);
                onChanged(selection.copyWith(includedFieldIds: ids));
              },
            ),
          for (final media in source.media)
            if (media.privacyClassification != PrivacyClassification.neverShare)
              _PrivacyToggle(
                key: Key('story-media-${media.id}'),
                label: media.label,
                supportingText:
                    '${_privacyLabel(media.privacyClassification)} · review the image itself',
                selected: selection.includedMediaIds.contains(media.id),
                onChanged: (selected) {
                  final ids = {...selection.includedMediaIds};
                  selected ? ids.add(media.id) : ids.remove(media.id);
                  onChanged(selection.copyWith(includedMediaIds: ids));
                },
              ),
          if (protectedItemCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppIcon(icon: AppIcons.lock),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '$protectedItemCount protected ${protectedItemCount == 1 ? 'item is' : 'items are'} always kept out of Stories.',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

final class StoryPrivacyReview extends StatelessWidget {
  const StoryPrivacyReview({required this.composition, super.key});

  final StoryComposition composition;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AppSectionHeader(
        title: 'Included',
        supportingText: 'This is exactly what the rendered Story can use.',
      ),
      const SizedBox(height: AppSpacing.sm),
      if (composition.fields.isEmpty && composition.media.isEmpty)
        const Text('Only the template and optional attribution are included.'),
      for (final field in composition.fields)
        _ReviewRow(
          icon: AppIcons.success,
          label: field.label,
          value: field.value,
        ),
      for (final media in composition.media)
        _ReviewRow(
          icon: AppIcons.image,
          label: media.label,
          value: 'Selected photo',
        ),
      const SizedBox(height: AppSpacing.xl),
      const AppSectionHeader(
        title: 'Kept private',
        supportingText: 'Values in this section are not passed to rendering.',
      ),
      const SizedBox(height: AppSpacing.sm),
      if (composition.excludedFields.isEmpty)
        const Text('No additional source fields were available.'),
      for (final field in composition.excludedFields)
        _ReviewRow(
          icon: AppIcons.lock,
          label: field.label,
          value: _exclusionLabel(field),
        ),
      if (composition.media.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.md),
        const _ReviewRow(
          icon: AppIcons.privacy,
          label: 'Photo review',
          value: 'Check selected photos for visible private details.',
        ),
      ],
    ],
  );
}

final class StoryMilestoneCard extends StatelessWidget {
  const StoryMilestoneCard({
    required this.milestone,
    required this.onCreateStory,
    super.key,
  });

  final MilestoneCandidate milestone;
  final VoidCallback onCreateStory;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSignatureIcon(
                kind: AppSignatureIconKind.timelineMilestone,
                color: colors.primary,
                semanticLabel: 'Timeline milestone',
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                milestone.headline,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                milestone.detail,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Create milestone Story',
                icon: AppIcons.stories,
                onPressed: onCreateStory,
                variant: AppButtonVariant.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PrivacyToggle extends StatelessWidget {
  const _PrivacyToggle({
    required this.label,
    required this.supportingText,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String label;
  final ValueChanged<bool> onChanged;
  final bool selected;
  final String supportingText;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(supportingText),
    secondary: AppIcon(
      icon: selected ? AppIcons.success : AppIcons.lock,
      semanticLabel: selected ? 'Included' : 'Not included',
    ),
    value: selected,
    onChanged: onChanged,
  );
}

final class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final AppIconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(icon: icon, size: AppIconSize.compact),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xxs),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    ),
  );
}

String _themeLabel(StoryThemeVariant variant) => switch (variant) {
  StoryThemeVariant.paper => 'Paper',
  StoryThemeVariant.indigo => 'Indigo',
  StoryThemeVariant.midnight => 'Midnight',
  StoryThemeVariant.warm => 'Warm',
};

String _privacyLabel(PrivacyClassification classification) =>
    switch (classification) {
      PrivacyClassification.shareSafe => 'Suggested for sharing',
      PrivacyClassification.personal => 'Private by default',
      PrivacyClassification.sensitive => 'Extra care required',
      PrivacyClassification.neverShare => 'Always protected',
    };

String _exclusionLabel(StoryExcludedField field) => switch (field.reason) {
  StoryExclusionReason.protectedAlways => 'Always protected',
  StoryExclusionReason.privateByDefault => 'Private by default',
  StoryExclusionReason.notSelected => 'Not selected',
  StoryExclusionReason.unsupported => 'Not used by this template',
};
