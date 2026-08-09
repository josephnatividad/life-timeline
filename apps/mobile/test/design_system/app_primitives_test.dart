import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';

void main() {
  testWidgets('AppButton exposes variants and disables a loading action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: Column(
          children: [
            AppButton(label: 'Primary', onPressed: () {}),
            AppButton(
              label: 'Secondary',
              onPressed: () {},
              variant: AppButtonVariant.secondary,
            ),
            AppButton(
              label: 'Tertiary',
              onPressed: () {},
              variant: AppButtonVariant.tertiary,
            ),
            AppButton(
              label: 'Delete',
              onPressed: () {},
              variant: AppButtonVariant.destructive,
            ),
            AppButton(label: 'Saving', loading: true, onPressed: () {}),
          ],
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.byType(FilledButton), findsNWidgets(3));
    final savingButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Saving'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(savingButton.onPressed, isNull);
  });

  testWidgets('AppSearchField clears through an accessible action', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'memory');
    addTearDown(controller.dispose);
    String? changedValue;

    await tester.pumpWidget(
      _TestApp(
        child: AppSearchField(
          controller: controller,
          hintText: 'Search memories',
          onChanged: (value) => changedValue = value,
        ),
      ),
    );

    expect(find.byTooltip('Clear search'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(changedValue, isEmpty);
  });

  testWidgets(
    'privacy and timeline state are not communicated by color alone',
    (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        const _TestApp(
          child: Column(
            children: [
              PrivacyBadge(level: PrivacyBadgeLevel.neverShare),
              TimelineNode(
                icon: AppIcons.time,
                label: 'Approximate date memory',
                selected: true,
                state: TimelineNodeState.candidate,
              ),
              TimelineConnector(),
            ],
          ),
        ),
      );

      expect(find.bySemanticsLabel('Never share'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Approximate date memory. Candidate. Selected'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Timeline connector'), findsNothing);
      semantics.dispose();
    },
  );

  testWidgets('core states reflow at large text scale without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        textScaler: const TextScaler.linear(2),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppEmptyState(
                title: 'Nothing here yet',
                message: 'Add an item when you are ready.',
                actionLabel: 'Add item',
                onAction: () {},
              ),
              const AppLoadingState(label: 'Loading local records'),
              AppErrorState(
                title: 'Could not open this item',
                message: 'Your local data was not changed.',
                actionLabel: 'Try again',
                onAction: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Loading local records'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}

final class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScaler});

  final Widget child;
  final TextScaler? textScaler;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light(),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: Scaffold(body: SafeArea(child: child)),
      ),
    ),
  );
}
