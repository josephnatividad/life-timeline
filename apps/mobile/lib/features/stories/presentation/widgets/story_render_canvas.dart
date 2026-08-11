import 'dart:io';

import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

final class StoryRenderCanvas extends StatelessWidget {
  const StoryRenderCanvas({
    required this.composition,
    this.boundaryKey,
    this.config = const StoryRenderConfig(),
    super.key,
  });

  final GlobalKey? boundaryKey;
  final StoryComposition composition;
  final StoryRenderConfig config;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    key: boundaryKey,
    child: SizedBox(
      width: config.logicalWidth,
      height: config.logicalHeight,
      child: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.noScaling),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ColoredBox(
            color: _palette(composition.themeVariant).background,
            child: switch (composition.templateId) {
              StoryTemplateId.minimal => _MinimalStory(composition),
              StoryTemplateId.photo => _PhotoStory(composition),
              StoryTemplateId.stats => _StatsStory(composition),
              StoryTemplateId.journey => _JourneyStory(composition),
              StoryTemplateId.thenNow => _ThenNowStory(composition),
            },
          ),
        ),
      ),
    ),
  );
}

final class StoryPreviewSurface extends StatelessWidget {
  const StoryPreviewSurface({
    required this.composition,
    this.boundaryKey,
    this.config = const StoryRenderConfig(),
    super.key,
  });

  final GlobalKey? boundaryKey;
  final StoryComposition composition;
  final StoryRenderConfig config;

  @override
  Widget build(BuildContext context) => StorySurface(
    aspectRatio: 9 / 16,
    semanticLabel: 'Preview of the sanitized Story',
    child: FittedBox(
      fit: BoxFit.contain,
      child: StoryRenderCanvas(
        boundaryKey: boundaryKey,
        composition: composition,
        config: config,
      ),
    ),
  );
}

final class _MinimalStory extends StatelessWidget {
  const _MinimalStory(this.composition);

  final StoryComposition composition;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(composition.themeVariant);
    return _StoryFrame(
      composition: composition,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Container(width: 48, height: 4, color: palette.accent),
          const SizedBox(height: AppSpacing.xl),
          _StoryTitle(_title(composition), color: palette.foreground),
          if (_supporting(composition) case final supporting?) ...[
            const SizedBox(height: AppSpacing.md),
            _StoryBody(supporting, color: palette.muted),
          ],
          const Spacer(flex: 3),
          _MetadataLine(composition: composition, palette: palette),
        ],
      ),
    );
  }
}

final class _PhotoStory extends StatelessWidget {
  const _PhotoStory(this.composition);

  final StoryComposition composition;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(composition.themeVariant);
    final media = composition.media.firstOrNull;
    return Stack(
      fit: StackFit.expand,
      children: [
        _StoryImage(media: media, palette: palette),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.darkBackground.withValues(alpha: 0.88),
              ],
            ),
          ),
        ),
        _StoryFrame(
          composition: composition,
          palette: const _StoryPalette(
            background: Colors.transparent,
            foreground: AppColors.darkTextPrimary,
            muted: AppColors.darkTextSecondary,
            accent: AppColors.darkPrimary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              _StoryTitle(
                _title(composition),
                color: AppColors.darkTextPrimary,
              ),
              if (_supporting(composition) case final supporting?) ...[
                const SizedBox(height: AppSpacing.sm),
                _StoryBody(supporting, color: AppColors.darkTextSecondary),
              ],
              const SizedBox(height: AppSpacing.xl),
              _MetadataLine(
                composition: composition,
                palette: const _StoryPalette(
                  background: Colors.transparent,
                  foreground: AppColors.darkTextPrimary,
                  muted: AppColors.darkTextSecondary,
                  accent: AppColors.darkPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _StatsStory extends StatelessWidget {
  const _StatsStory(this.composition);

  final StoryComposition composition;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(composition.themeVariant);
    final metric =
        composition.firstOfKind(StoryFieldKind.statistic) ??
        composition.firstOfKind(StoryFieldKind.year);
    return _StoryFrame(
      composition: composition,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            metric?.value ?? 'One moment',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: StoryTypography.title.copyWith(
              color: palette.accent,
              fontSize: 64,
              height: 0.98,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _StoryTitle(_title(composition), color: palette.foreground),
          if (_supporting(composition, excluding: metric)
              case final value?) ...[
            const SizedBox(height: AppSpacing.md),
            _StoryBody(value, color: palette.muted),
          ],
          const Spacer(),
          _MetadataLine(composition: composition, palette: palette),
        ],
      ),
    );
  }
}

final class _JourneyStory extends StatelessWidget {
  const _JourneyStory(this.composition);

  final StoryComposition composition;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(composition.themeVariant);
    final labels = composition.fields
        .where(
          (field) =>
              field.kind == StoryFieldKind.year ||
              field.kind == StoryFieldKind.location ||
              field.kind == StoryFieldKind.date,
        )
        .take(3)
        .toList();
    return _StoryFrame(
      composition: composition,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StoryBody('A chapter in motion', color: palette.accent),
          const SizedBox(height: AppSpacing.xl),
          _StoryTitle(_title(composition), color: palette.foreground),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 7,
                  top: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                  child: Container(width: 2, color: palette.accent),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final field
                        in labels.isEmpty
                            ? [
                                StoryField(
                                  id: 'journey.moment',
                                  label: 'Moment',
                                  value: 'A moment worth carrying forward',
                                  kind: StoryFieldKind.detail,
                                  privacyClassification:
                                      PrivacyClassification.shareSafe,
                                ),
                              ]
                            : labels)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: palette.background,
                              border: Border.all(
                                color: palette.accent,
                                width: 3,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  field.label,
                                  style: StoryTypography.metadata.copyWith(
                                    color: palette.muted,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                _StoryBody(
                                  field.value,
                                  color: palette.foreground,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _MetadataLine(composition: composition, palette: palette),
        ],
      ),
    );
  }
}

final class _ThenNowStory extends StatelessWidget {
  const _ThenNowStory(this.composition);

  final StoryComposition composition;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(composition.themeVariant);
    final thenTitle = composition.field('then.title')?.value ?? 'Then';
    final nowTitle = composition.field('now.title')?.value ?? 'Now';
    final thenYear = composition.field('then.year')?.value;
    final nowYear = composition.field('now.year')?.value;
    return _StoryFrame(
      composition: composition,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StoryBody('Then & Now', color: palette.accent),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _PairPanel(
                    label: 'Then',
                    title: thenTitle,
                    year: thenYear,
                    media: composition.media
                        .where((media) => media.id.startsWith('then.'))
                        .firstOrNull,
                    palette: palette,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: _PairPanel(
                    label: 'Now',
                    title: nowTitle,
                    year: nowYear,
                    media: composition.media
                        .where((media) => media.id.startsWith('now.'))
                        .firstOrNull,
                    palette: palette,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _MetadataLine(composition: composition, palette: palette),
        ],
      ),
    );
  }
}

final class _PairPanel extends StatelessWidget {
  const _PairPanel({
    required this.label,
    required this.title,
    required this.year,
    required this.media,
    required this.palette,
  });

  final String label;
  final StoryMedia? media;
  final _StoryPalette palette;
  final String title;
  final String? year;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(AppRadius.card),
    child: Stack(
      fit: StackFit.expand,
      children: [
        _StoryImage(media: media, palette: palette),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.darkBackground.withValues(alpha: 0.82),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                year == null ? label : '$label · $year',
                style: StoryTypography.metadata.copyWith(
                  color: AppColors.darkPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: StoryTypography.heading.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

final class _StoryFrame extends StatelessWidget {
  const _StoryFrame({
    required this.composition,
    required this.palette,
    required this.child,
  });

  final Widget child;
  final StoryComposition composition;
  final _StoryPalette palette;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.xxl),
    child: DefaultTextStyle.merge(
      style: StoryTypography.body.copyWith(color: palette.foreground),
      child: child,
    ),
  );
}

final class _StoryTitle extends StatelessWidget {
  const _StoryTitle(this.value, {required this.color});

  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) => Text(
    value,
    maxLines: 4,
    overflow: TextOverflow.ellipsis,
    style: StoryTypography.title.copyWith(color: color),
  );
}

final class _StoryBody extends StatelessWidget {
  const _StoryBody(this.value, {required this.color});

  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) => Text(
    value,
    maxLines: 4,
    overflow: TextOverflow.ellipsis,
    style: StoryTypography.body.copyWith(color: color),
  );
}

final class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.composition, required this.palette});

  final StoryComposition composition;
  final _StoryPalette palette;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: palette.accent,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Text(
          composition.branding.showAttribution
              ? composition.branding.attribution
              : 'A private Story',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StoryTypography.metadata.copyWith(color: palette.muted),
        ),
      ),
    ],
  );
}

final class _StoryImage extends StatelessWidget {
  const _StoryImage({required this.media, required this.palette});

  final StoryMedia? media;
  final _StoryPalette palette;

  @override
  Widget build(BuildContext context) {
    final path = media?.localPath;
    if (path == null) return _ImageFallback(palette: palette);
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) =>
          _ImageFallback(palette: palette),
    );
  }
}

final class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.palette});

  final _StoryPalette palette;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: palette.background,
    child: Center(
      child: AppSignatureIcon(
        kind: AppSignatureIconKind.story,
        color: palette.accent,
        size: AppIconSize.signature,
      ),
    ),
  );
}

String _title(StoryComposition composition) =>
    composition.field('public.title')?.value ??
    composition.firstOfKind(StoryFieldKind.title)?.value ??
    'A moment remembered';

String? _supporting(StoryComposition composition, {StoryField? excluding}) {
  final preferred = [
    StoryFieldKind.caption,
    StoryFieldKind.detail,
    StoryFieldKind.date,
    StoryFieldKind.location,
    StoryFieldKind.year,
    StoryFieldKind.category,
  ];
  for (final kind in preferred) {
    for (final field in composition.fields) {
      if (!identical(field, excluding) && field.kind == kind) {
        return field.value;
      }
    }
  }
  return null;
}

_StoryPalette _palette(StoryThemeVariant variant) => switch (variant) {
  StoryThemeVariant.paper => const _StoryPalette(
    background: AppColors.lightSurface,
    foreground: AppColors.lightTextPrimary,
    muted: AppColors.lightTextSecondary,
    accent: AppColors.lightPrimary,
  ),
  StoryThemeVariant.indigo => const _StoryPalette(
    background: AppColors.lightPrimarySoft,
    foreground: AppColors.lightTextPrimary,
    muted: AppColors.lightTextSecondary,
    accent: AppColors.lightPrimary,
  ),
  StoryThemeVariant.midnight => const _StoryPalette(
    background: AppColors.darkBackground,
    foreground: AppColors.darkTextPrimary,
    muted: AppColors.darkTextSecondary,
    accent: AppColors.darkPrimary,
  ),
  StoryThemeVariant.warm => const _StoryPalette(
    background: AppColors.lightSurfaceSecondary,
    foreground: AppColors.lightTextPrimary,
    muted: AppColors.lightTextSecondary,
    accent: AppColors.lightWarning,
  ),
};

final class _StoryPalette {
  const _StoryPalette({
    required this.background,
    required this.foreground,
    required this.muted,
    required this.accent,
  });

  final Color accent;
  final Color background;
  final Color foreground;
  final Color muted;
}
