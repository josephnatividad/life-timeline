import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

enum AppMotionLevel { static, micro, structural, meaningful, emotional }

abstract final class AppMotion {
  static const instant = Duration(milliseconds: 80);
  static const quick = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 220);
  static const emphasis = Duration(milliseconds: 320);
  static const reveal = Duration(milliseconds: 450);
  static const storyMin = Duration(milliseconds: 600);
  static const storyMax = Duration(milliseconds: 900);

  static const revealOffset = AppSpacing.xs;
  static const standardCurve = Curves.easeOutCubic;
  static const emphasizedCurve = Curves.easeInOutCubic;

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  static Duration resolve(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;

  static Curve resolveCurve(BuildContext context, Curve curve) =>
      reduced(context) ? Curves.linear : curve;

  static AnimationStyle bottomSheetStyle(BuildContext context) =>
      reduced(context)
      ? AnimationStyle.noAnimation
      : const AnimationStyle(duration: emphasis, reverseDuration: standard);
}
