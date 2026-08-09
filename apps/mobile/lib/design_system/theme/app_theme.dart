import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/motion/app_page_transitions.dart';
import 'package:life_timeline/design_system/tokens/app_colors.dart';
import 'package:life_timeline/design_system/tokens/app_elevation.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';
import 'package:life_timeline/design_system/tokens/app_radius.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';
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
      onSurfaceVariant: textSecondary,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surfaceSecondary,
      surfaceContainerHigh: surfaceSecondary,
      surfaceContainerHighest: surfaceSecondary,
      outline: border,
      outlineVariant: divider,
      surfaceTint: Colors.transparent,
      // The PDD does not yet define dark semantic colors. Keep Material's
      // generated dark error role until the missing token receives approval.
      error: brightness == Brightness.light
          ? AppColors.lightDanger
          : generatedScheme.error,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.smallControl),
      borderSide: BorderSide(color: border),
    );

    return ThemeData(
      brightness: brightness,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: AppElevation.overlay,
        modalBackgroundColor: surface,
        modalElevation: AppElevation.overlay,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
        showDragHandle: true,
      ),
      buttonTheme: const ButtonThemeData(
        minWidth: AppIconSize.touchTarget,
        height: AppIconSize.touchTarget,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: surface,
        elevation: AppElevation.flat,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: border),
        ),
      ),
      colorScheme: colorScheme,
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSecondary,
        selectedColor: primarySoft,
        disabledColor: surfaceSecondary,
        labelStyle: AppTypography.label.copyWith(color: textSecondary),
        secondaryLabelStyle: AppTypography.label.copyWith(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        side: BorderSide(color: border),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: AppElevation.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.largeCard),
        ),
      ),
      dividerColor: divider,
      dividerTheme: DividerThemeData(color: divider, space: 1, thickness: 1),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size.square(AppIconSize.touchTarget),
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: AppTypography.body.copyWith(color: textSecondary),
        hintStyle: AppTypography.body.copyWith(color: textSecondary),
        errorStyle: AppTypography.bodySmall.copyWith(color: colorScheme.error),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: AppElevation.flat,
        indicatorColor: primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.label.copyWith(
            color: states.contains(WidgetState.selected)
                ? primary
                : textSecondary,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
        },
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
