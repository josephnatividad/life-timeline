import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/story/story_typography.dart';
import 'package:life_timeline/design_system/tokens/app_radius.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

/// Visual boundary for locally rendered, already-sanitized Story content.
///
/// This widget performs no privacy filtering and intentionally defines no
/// concrete template or export aspect ratio.
final class StorySurface extends StatelessWidget {
  const StorySurface({
    required this.child,
    this.aspectRatio,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticLabel = 'Story preview',
    super.key,
  });

  final double? aspectRatio;
  final Color? backgroundColor;
  final Widget child;
  final Color? foregroundColor;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = foregroundColor ?? colors.onSurface;
    Widget surface = Semantics(
      container: true,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? colors.surface,
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.largeCard),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.largeCard),
          child: DefaultTextStyle.merge(
            style: StoryTypography.body.copyWith(color: foreground),
            child: IconTheme(
              data: IconThemeData(color: foreground),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (aspectRatio case final aspectRatio?) {
      surface = AspectRatio(aspectRatio: aspectRatio, child: surface);
    }

    return surface;
  }
}

final class StorySafeArea extends StatelessWidget {
  const StorySafeArea({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.useDeviceSafeArea = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool useDeviceSafeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (useDeviceSafeArea) {
      content = SafeArea(child: content);
    }
    return content;
  }
}
