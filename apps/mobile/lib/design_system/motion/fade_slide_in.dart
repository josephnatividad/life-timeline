import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/motion/app_motion.dart';

/// A restrained one-time reveal for visible content.
final class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.standard,
    this.offset = AppMotion.revealOffset,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) {
      return child;
    }

    return _DelayedTween(
      delay: delay,
      duration: duration,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, offset * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

final class _DelayedTween extends StatefulWidget {
  const _DelayedTween({
    required this.builder,
    required this.child,
    required this.delay,
    required this.duration,
  });

  final ValueWidgetBuilder<double> builder;
  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<_DelayedTween> createState() => _DelayedTweenState();
}

final class _DelayedTweenState extends State<_DelayedTween> {
  var _visible = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _visible = true;
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) {
          setState(() => _visible = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: _visible ? 1 : 0),
    duration: widget.duration,
    curve: AppMotion.standardCurve,
    builder: widget.builder,
    child: widget.child,
  );
}
