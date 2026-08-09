import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/motion/app_motion.dart';

void main() {
  testWidgets('resolves motion to zero when the OS disables animations', (
    tester,
  ) async {
    late Duration resolvedDuration;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            resolvedDuration = AppMotion.resolve(context, AppMotion.standard);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolvedDuration, Duration.zero);
  });
}
