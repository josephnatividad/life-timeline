import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/theme/app_theme.dart';
import 'package:life_timeline/design_system/tokens/app_colors.dart';
import 'package:life_timeline/design_system/tokens/app_radius.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

void main() {
  test('light and dark themes use the official core tokens', () {
    final light = AppTheme.light();
    final dark = AppTheme.dark();

    expect(light.scaffoldBackgroundColor, AppColors.lightBackground);
    expect(light.colorScheme.primary, AppColors.lightPrimary);
    expect(light.colorScheme.surface, AppColors.lightSurface);

    expect(dark.scaffoldBackgroundColor, AppColors.darkBackground);
    expect(dark.colorScheme.primary, AppColors.darkPrimary);
    expect(dark.colorScheme.surface, AppColors.darkSurface);
  });

  test('spacing and radius primitives remain centralized', () {
    expect(
      const [
        AppSpacing.xxs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
        AppSpacing.huge,
        AppSpacing.massive,
      ],
      const [4, 8, 12, 16, 20, 24, 32, 40, 48, 64],
    );
    expect(AppRadius.smallControl, 8);
    expect(AppRadius.button, 12);
    expect(AppRadius.card, 16);
    expect(AppRadius.largeCard, 20);
    expect(AppRadius.bottomSheet, 28);
  });
}
