import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/tokens/app_colors.dart';
import 'package:life_timeline/design_system/tokens/app_radius.dart';
import 'package:life_timeline/design_system/tokens/app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(
    brightness: Brightness.light,
    background: AppColors.lightBackground,
    border: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    primary: AppColors.lightPrimary,
    primarySoft: AppColors.lightPrimarySoft,
    surface: AppColors.lightSurface,
    surfaceSecondary: AppColors.lightSurfaceSecondary,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    border: AppColors.darkBorder,
    divider: AppColors.darkBorder,
    primary: AppColors.darkPrimary,
    primarySoft: AppColors.darkPrimarySoft,
    surface: AppColors.darkSurface,
    surfaceSecondary: AppColors.darkSurfaceSecondary,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color border,
    required Color divider,
    required Color primary,
    required Color primarySoft,
    required Color surface,
    required Color surfaceSecondary,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final generatedScheme = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: primary,
    );
    final colorScheme = generatedScheme.copyWith(
      primary: primary,
      onPrimary: brightness == Brightness.light
          ? AppColors.lightSurface
          : AppColors.darkBackground,
      primaryContainer: primarySoft,
      onPrimaryContainer: textPrimary,
      secondary: primary,
      onSecondary: brightness == Brightness.light
          ? AppColors.lightSurface
          : AppColors.darkBackground,
      secondaryContainer: primarySoft,
      onSecondaryContainer: textPrimary,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surfaceSecondary,
      surfaceContainerHigh: surfaceSecondary,
      surfaceContainerHighest: surfaceSecondary,
      outline: border,
      outlineVariant: divider,
      // The PDD does not yet define dark semantic colors. Keep Material's
      // generated dark error role until the missing token receives approval.
      error: brightness == Brightness.light
          ? AppColors.lightDanger
          : generatedScheme.error,
    );

    return ThemeData(
      brightness: brightness,
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: border),
        ),
      ),
      colorScheme: colorScheme,
      dividerColor: divider,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: primarySoft,
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.label.copyWith(color: textSecondary),
        ),
      ),
      scaffoldBackgroundColor: background,
      textTheme: AppTypography.textTheme(
        primary: textPrimary,
        secondary: textSecondary,
      ),
      useMaterial3: true,
    );
  }
}
