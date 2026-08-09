import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

final class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    body: body,
    bottomNavigationBar: bottomNavigationBar,
    floatingActionButton: floatingActionButton,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
  );
}

/// Fluid safe-area content frame with tokenized gutters.
///
/// Numeric responsive breakpoints and default maximum widths remain pending
/// design approval, so callers may opt into a contextual [maxWidth].
final class ScreenContainer extends StatelessWidget {
  const ScreenContainer({
    required this.child,
    this.alignment = Alignment.topCenter,
    this.maxWidth,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.safeArea = true,
    super.key,
  });

  final AlignmentGeometry alignment;
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry padding;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}
