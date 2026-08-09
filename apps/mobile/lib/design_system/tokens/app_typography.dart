import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const display = TextStyle(
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w600,
  );
  static const hero = TextStyle(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w600,
  );
  static const title1 = TextStyle(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w600,
  );
  static const title2 = TextStyle(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
  );
  static const title3 = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );
  static const bodyLarge = TextStyle(fontSize: 17, height: 26 / 17);
  static const body = TextStyle(fontSize: 15, height: 22 / 15);
  static const bodySmall = TextStyle(fontSize: 13, height: 18 / 13);
  static const label = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
  );
  static const caption = TextStyle(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w500,
  );

  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) => TextTheme(
    displayLarge: display.copyWith(color: primary),
    displayMedium: hero.copyWith(color: primary),
    headlineLarge: title1.copyWith(color: primary),
    headlineMedium: title2.copyWith(color: primary),
    titleLarge: title3.copyWith(color: primary),
    bodyLarge: bodyLarge.copyWith(color: primary),
    bodyMedium: body.copyWith(color: primary),
    bodySmall: bodySmall.copyWith(color: secondary),
    labelLarge: label.copyWith(color: primary),
    labelSmall: caption.copyWith(color: secondary),
  );
}
