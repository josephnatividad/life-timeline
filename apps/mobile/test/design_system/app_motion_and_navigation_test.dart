import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';

void main() {
  testWidgets('FadeSlideIn becomes static with Reduced Motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: FadeSlideIn(child: Text('Quiet content')),
        ),
      ),
    );

    expect(find.text('Quiet content'), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });

  testWidgets('bottom navigation keeps the five approved destinations', (
    tester,
  ) async {
    var selected = -1;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AppBottomNavigationShell(
          selectedIndex: 0,
          onDestinationSelected: (index) => selected = index,
          body: const SizedBox.expand(),
        ),
      ),
    );

    for (final label in const [
      'Timeline',
      'Explore',
      'Capture',
      'Stories',
      'You',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('Capture'));
    expect(selected, 2);
  });

  testWidgets('AppBottomSheet supplies explicit accessible close control', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => AppButton(
            label: 'Open sheet',
            onPressed: () => AppBottomSheet.show<void>(
              context: context,
              builder: (context) => const AppBottomSheet(
                title: 'Choices',
                child: Text('Sheet content'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Choices'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Choices'), findsNothing);
  });

  testWidgets('StorySurface defines a boundary but no fixed template ratio', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const StorySurface(
          semanticLabel: 'Sanitized story preview',
          child: StorySafeArea(child: Text('Approved fields only')),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(RegExp('Sanitized story preview')),
      findsOneWidget,
    );
    expect(find.byType(AspectRatio), findsNothing);
    semantics.dispose();
  });
}
