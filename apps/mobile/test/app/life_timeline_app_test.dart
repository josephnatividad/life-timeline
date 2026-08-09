import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/app/life_timeline_app.dart';

void main() {
  testWidgets('boots the navigation foundation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LifeTimelineApp()));
    await tester.pumpAndSettle();

    expect(find.text('Life Timeline'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Capture'), findsOneWidget);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });

  testWidgets('keeps Capture as an action instead of a shell branch', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LifeTimelineApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(
      find.text('Explore feature implementation is intentionally deferred.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Capture'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Capture modes will be added in a separate feature implementation.',
      ),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(
      find.text('Explore feature implementation is intentionally deferred.'),
      findsOneWidget,
    );
  });
}
