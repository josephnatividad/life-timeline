import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/app/providers/theme_mode_provider.dart';

void main() {
  test('theme mode follows the system until explicitly changed', () {
    final container = ProviderContainer.test();

    expect(container.read(themeModeProvider), ThemeMode.system);

    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });
}
