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
    final inputDecorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(inputDecorator.decoration.labelText, isNull);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(changedValue, isEmpty);
  });

  testWidgets('AppDropdownField uses the AppIcons indicator boundary', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      _TestApp(
        child: AppDropdownField<String>(
          initialValue: 'daily',
          label: 'Frequency',
          items: const [
            DropdownMenuItem(value: 'daily', child: Text('Daily')),
            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
          ],
          onChanged: (value) => selected = value,
        ),
      ),
    );

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>),
    );
    expect(dropdown.icon, isA<AppIcon>());
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly').last);
    await tester.pumpAndSettle();
    expect(selected, 'weekly');
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

  testWidgets(
    'empty, no-result, unavailable, permission, and completed states stay distinct',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var secondaryPressed = false;
      await tester.pumpWidget(
        _TestApp(
          dark: true,
          reducedMotion: true,
          textScaler: const TextScaler.linear(2),
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppEmptyState(
                  title: 'Your story starts here',
                  actionLabel: 'Add memory',
                  onAction: () {},
                  secondaryActionLabel: 'Restore timeline',
                  onSecondaryAction: () => secondaryPressed = true,
                ),
                AppNoResultsState(
                  title: 'No memories matched your search',
                  actionLabel: 'Clear search',
                  onAction: () {},
                ),
                const AppUnavailableState(
                  title: "Private text extraction isn't available yet",
                ),
                AppPermissionRequiredState(
                  title: 'Notifications are off',
                  actionLabel: 'Enable notifications',
                  onAction: () {},
                ),
                const AppCompletedState(title: "You're all caught up"),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('No results'), findsOneWidget);
      expect(find.bySemanticsLabel('Unavailable'), findsOneWidget);
      expect(find.bySemanticsLabel('Permission required'), findsOneWidget);
      expect(find.bySemanticsLabel('Complete'), findsOneWidget);
      await tester.ensureVisible(find.text('Restore timeline'));
      await tester.tap(find.text('Restore timeline'));
      expect(secondaryPressed, isTrue);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('MemoryCard stacks lifecycle actions at large text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        textScaler: const TextScaler.linear(2),
        child: SizedBox(
          width: 320,
          child: MemoryCard(
            title: 'A meaningful memory with a descriptive title',
            metadata: 'Approximately 2024',
            subtitle: 'Personal milestone',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIconButton(
                  icon: AppIcons.restore,
                  label: 'Restore memory',
                  onPressed: () {},
                ),
                AppIconButton(
                  icon: AppIcons.trash,
                  label: 'Move memory to Trash',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Restore memory'), findsOneWidget);
    expect(find.byTooltip('Move memory to Trash'), findsOneWidget);
  });

  testWidgets('collection preview exposes count and labeled drill-down', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var opened = false;
    await tester.pumpWidget(
      _TestApp(
        textScaler: const TextScaler.linear(1.8),
        child: SingleChildScrollView(
          child: AppCollectionPreview(
            title: 'Photos',
            count: 24,
            viewAllLabel: 'View all photos',
            onViewAll: () => opened = true,
            child: const Text('Four bounded previews'),
          ),
        ),
      ),
    );

    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.bySemanticsLabel('Photos, 24 items'), findsOneWidget);
    await tester.tap(find.text('View all photos'));
    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}

final class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
    this.dark = false,
    this.reducedMotion = false,
    this.textScaler,
  });

  final Widget child;
  final bool dark;
  final bool reducedMotion;
  final TextScaler? textScaler;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: reducedMotion, textScaler: textScaler),
        child: Scaffold(body: SafeArea(child: child)),
      ),
    ),
  );
}
