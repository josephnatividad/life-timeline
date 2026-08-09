import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/tokens/app_typography.dart';

/// Typography roles available inside a Story rendering boundary.
///
/// Actual templates may become more expressive later, but they must compose
/// these centralized roles instead of introducing untracked text styles.
abstract final class StoryTypography {
  static const title = AppTypography.hero;
  static const heading = AppTypography.title1;
  static const body = AppTypography.bodyLarge;
  static const metadata = AppTypography.label;

  static TextTheme textTheme(Color foreground) => TextTheme(
    displayMedium: title.copyWith(color: foreground),
    headlineLarge: heading.copyWith(color: foreground),
    bodyLarge: body.copyWith(color: foreground),
    labelLarge: metadata.copyWith(color: foreground),
  );
}
