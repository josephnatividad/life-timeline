import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/motion/app_motion.dart';

/// Standard Material 3 screen transition for the application theme.
final class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.reduced(context)) {
      return child;
    }

    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.standardCurve,
      reverseCurve: AppMotion.emphasizedCurve,
    );

    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, AppMotion.revealOffset * (1 - curved.value)),
          child: child,
        ),
      ),
    );
  }
}
