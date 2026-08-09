import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';

typedef AppIconData = List<List<dynamic>>;

abstract final class AppIcons {
  static const timeline = HugeIcons.strokeRoundedCalendar03;
  static const explore = HugeIcons.strokeRoundedCompass01;
  static const capture = HugeIcons.strokeRoundedAdd01;
  static const stories = HugeIcons.strokeRoundedBookOpen02;
  static const you = HugeIcons.strokeRoundedUser;
  static const settings = HugeIcons.strokeRoundedSettings01;
  static const search = HugeIcons.strokeRoundedSearch01;
  static const back = HugeIcons.strokeRoundedArrowLeft01;
  static const more = HugeIcons.strokeRoundedMoreHorizontal;
  static const lightTheme = HugeIcons.strokeRoundedSun03;
  static const darkTheme = HugeIcons.strokeRoundedMoon02;
  static const database = HugeIcons.strokeRoundedDatabase01;
  static const privacy = HugeIcons.strokeRoundedShield01;
  static const close = HugeIcons.strokeRoundedCancel01;
  static const clear = HugeIcons.strokeRoundedCancel01;
  static const loading = HugeIcons.strokeRoundedLoading03;
  static const error = HugeIcons.strokeRoundedAlert02;
  static const information = HugeIcons.strokeRoundedInformationCircle;
  static const intelligence = HugeIcons.strokeRoundedSparkles;
  static const success = HugeIcons.strokeRoundedCheckmarkCircle02;
  static const next = HugeIcons.strokeRoundedArrowRight01;
  static const time = HugeIcons.strokeRoundedClock01;
  static const image = HugeIcons.strokeRoundedImage01;
  static const lock = HugeIcons.strokeRoundedLock;
}

enum AppSignatureIconKind {
  lifeIntelligence,
  lifeGraph,
  memory,
  story,
  timelineMilestone,
  privateAi,
}

/// Replaceable boundary for the future custom signature icon set.
///
/// Until approved custom assets exist, [AppSignatureIcon] renders a restrained
/// Hugeicons fallback through [AppIcons].
abstract interface class AppSignatureIconProvider {
  Widget buildIcon(
    BuildContext context,
    AppSignatureIconKind kind, {
    Color? color,
    String? semanticLabel,
    double size,
  });
}

final class AppSignatureIcon extends StatelessWidget {
  const AppSignatureIcon({
    required this.kind,
    this.color,
    this.provider,
    this.semanticLabel,
    this.size = AppIconSize.signature,
    super.key,
  });

  final Color? color;
  final AppSignatureIconKind kind;
  final AppSignatureIconProvider? provider;
  final String? semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) =>
      provider?.buildIcon(
        context,
        kind,
        color: color,
        semanticLabel: semanticLabel,
        size: size,
      ) ??
      AppIcon(
        icon: _fallbackFor(kind),
        color: color,
        semanticLabel: semanticLabel,
        size: size,
      );

  static AppIconData _fallbackFor(AppSignatureIconKind kind) => switch (kind) {
    AppSignatureIconKind.lifeIntelligence => AppIcons.intelligence,
    AppSignatureIconKind.lifeGraph => AppIcons.explore,
    AppSignatureIconKind.memory => AppIcons.image,
    AppSignatureIconKind.story => AppIcons.stories,
    AppSignatureIconKind.timelineMilestone => AppIcons.timeline,
    AppSignatureIconKind.privateAi => AppIcons.lock,
  };
}

final class AppIcon extends StatelessWidget {
  const AppIcon({
    required this.icon,
    this.color,
    this.semanticLabel,
    this.size = AppIconSize.standard,
    super.key,
  });

  final Color? color;
  final AppIconData icon;
  final String? semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconWidget = HugeIcon(
      icon: icon,
      color: color,
      size: size,
      strokeWidth: 2,
    );

    if (semanticLabel case final label?) {
      return Semantics(
        image: true,
        label: label,
        child: ExcludeSemantics(child: iconWidget),
      );
    }

    return ExcludeSemantics(child: iconWidget);
  }
}
