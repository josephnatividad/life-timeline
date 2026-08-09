import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain code does not import framework or infrastructure packages', () {
    final violations = <String>[];

    for (final file in _dartFilesUnder(Directory('lib'))) {
      if (!file.path.replaceAll('\\', '/').contains('/domain/')) {
        continue;
      }

      final source = file.readAsStringSync();
      for (final forbiddenImport in const [
        "package:flutter/",
        "package:flutter_riverpod/",
        "package:drift/",
        "package:drift_flutter/",
      ]) {
        if (source.contains(forbiddenImport)) {
          violations.add('${file.path}: $forbiddenImport');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('Hugeicons is imported only by AppIcons', () {
    final violations = <String>[];

    for (final file in _dartFilesUnder(Directory('lib'))) {
      final normalizedPath = file.path.replaceAll('\\', '/');
      if (normalizedPath.endsWith('/design_system/icons/app_icons.dart')) {
        continue;
      }

      if (file.readAsStringSync().contains('package:hugeicons/')) {
        violations.add(file.path);
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('design system does not depend on product feature modules', () {
    final violations = <String>[];

    for (final file in _dartFilesUnder(Directory('lib/design_system'))) {
      final source = file.readAsStringSync();
      for (final forbiddenImport in const [
        'package:life_timeline/features/',
        'package:life_timeline/shared/',
        'package:life_timeline/app/',
      ]) {
        if (source.contains(forbiddenImport)) {
          violations.add('${file.path}: $forbiddenImport');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

Iterable<File> _dartFilesUnder(Directory directory) => directory
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'));
