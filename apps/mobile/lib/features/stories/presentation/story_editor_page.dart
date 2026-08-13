import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/stories/application/story_providers.dart';
import 'package:life_timeline/features/stories/application/story_template_catalog.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/features/stories/presentation/widgets/story_editor_components.dart';
import 'package:life_timeline/features/stories/presentation/widgets/story_render_canvas.dart';

final class StoryEditorPage extends ConsumerStatefulWidget {
  const StoryEditorPage({required this.source, super.key});

  final StorySource source;

  @override
  ConsumerState<StoryEditorPage> createState() => _StoryEditorPageState();
}

final class _StoryEditorPageState extends ConsumerState<StoryEditorPage> {
  late StorySource _source = widget.source;
  late StoryPrivacySelection _selection = StoryPrivacySelection.defaultsFor(
    widget.source,
  );
  late StoryTemplateId _template =
      widget.source.sourceType == StorySourceType.thenNow
      ? StoryTemplateId.thenNow
      : StoryTemplateId.minimal;
  var _theme = StoryThemeVariant.paper;
  late final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _captionController = TextEditingController();
  var _choosingMedia = false;

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final composition = _compose();
    return AppScaffold(
      appBar: AppBar(title: const Text('Create Story')),
      body: ScreenContainer(
        child: ListView(
          key: const Key('story-editor-content'),
          children: [
            Text(
              _source.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'The editor is local. Only fields selected below can reach the preview.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: AnimatedSwitcher(
                  duration: AppMotion.resolve(context, AppMotion.storyMin),
                  switchInCurve: AppMotion.emphasizedCurve,
                  switchOutCurve: AppMotion.standardCurve,
                  child: StoryPreviewSurface(
                    key: ValueKey(
                      '${_template.name}-${_theme.name}-${composition.fields.length}-${composition.media.length}',
                    ),
                    composition: composition,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const AppSectionHeader(
              title: 'Template',
              supportingText: 'A small set of deliberate layouts.',
            ),
            const SizedBox(height: AppSpacing.sm),
            StoryTemplateChooser(
              source: _source,
              selected: _template,
              onSelected: _selectTemplate,
            ),
            const SizedBox(height: AppSpacing.xxl),
            const AppSectionHeader(
              title: 'Story tone',
              supportingText: 'Approved, tokenized color treatments only.',
            ),
            const SizedBox(height: AppSpacing.sm),
            StoryThemeChooser(
              selected: _theme,
              onSelected: (value) => setState(() => _theme = value),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const AppSectionHeader(
              title: 'Public wording',
              supportingText:
                  'Optional text written specifically for this shared artifact.',
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              key: const Key('story-public-title'),
              controller: _titleController,
              label: 'Public title',
              hintText: 'Optional title for this Story',
              maxLines: 2,
              onChanged: _updatePublicText,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              key: const Key('story-public-caption'),
              controller: _captionController,
              label: 'Public caption',
              hintText: 'Optional context',
              maxLines: 3,
              onChanged: _updatePublicText,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_source.unavailableMedia.isNotEmpty) ...[
              IntelligenceCard(
                title: 'Original photo retrieval needed',
                body:
                    '${_source.unavailableMedia.length} archived ${_source.unavailableMedia.length == 1 ? 'photo needs' : 'photos need'} retrieval before a high-resolution Story can use it.',
                actionLabel: 'Open Storage Manager',
                onAction: () => context.pushNamed(AppRoute.storageManager.name),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              key: const Key('choose-story-photo'),
              label: 'Choose another photo',
              icon: AppIcons.image,
              loading: _choosingMedia,
              onPressed: _choosingMedia ? null : _chooseMedia,
              variant: AppButtonVariant.secondary,
            ),
            const SizedBox(height: AppSpacing.xxl),
            const AppSectionHeader(
              title: 'What may appear',
              supportingText:
                  'Private and sensitive fields start off. Protected fields cannot be enabled.',
            ),
            const SizedBox(height: AppSpacing.sm),
            StoryPrivacySelector(
              source: _source,
              selection: _selection,
              onChanged: (value) => setState(() => _selection = value),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              key: const Key('review-story'),
              label: 'Review & preview',
              icon: AppIcons.preview,
              expanded: true,
              onPressed: () => context.pushNamed(
                AppRoute.storyPreview.name,
                extra: _compose(),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  StoryComposition _compose() => ref
      .read(storyComposerProvider)
      .compose(
        source: _source,
        selection: _selection,
        templateId: _template,
        themeVariant: _theme,
        branding: ref.read(storyBrandingConfigProvider),
      );

  Future<void> _selectTemplate(StoryTemplateId value) async {
    final definition = StoryTemplateCatalog.byId(value);
    final allowed = await ref
        .read(storyTemplateAccessPolicyProvider)
        .canUse(definition);
    if (!mounted) return;
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This optional template is not available.'),
        ),
      );
      return;
    }
    setState(() => _template = value);
  }

  void _updatePublicText(String _) {
    setState(() {
      _selection = _selection.copyWith(
        publicTitle: _titleController.text,
        publicCaption: _captionController.text,
      );
    });
  }

  Future<void> _chooseMedia() async {
    setState(() => _choosingMedia = true);
    try {
      final media = await ref.read(storyMediaPickerProvider).chooseImage();
      if (media == null || !mounted) return;
      final mediaIds = {..._selection.includedMediaIds, media.id};
      setState(() {
        _source = StorySource(
          id: _source.id,
          sourceType: _source.sourceType,
          title: _source.title,
          sourceRecordIds: _source.sourceRecordIds,
          fields: _source.fields,
          media: [..._source.media, media],
          unavailableMedia: _source.unavailableMedia,
          temporalPrecision: _source.temporalPrecision,
        );
        _selection = _selection.copyWith(includedMediaIds: mediaIds);
      });
    } finally {
      if (mounted) setState(() => _choosingMedia = false);
    }
  }
}
