import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/app/life_timeline_app.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';

import '../helpers/security_test_controller.dart';

void main() {
  testWidgets('boots the navigation foundation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          securityControllerProvider.overrideWith(
            UnlockedSecurityController.new,
          ),
          timelineMemoriesProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const LifeTimelineApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your story starts here.'), findsOneWidget);
    expect(find.text('Timeline'), findsWidgets);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Capture'), findsOneWidget);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });

  testWidgets('keeps Capture as an action instead of a shell branch', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          securityControllerProvider.overrideWith(
            UnlockedSecurityController.new,
          ),
          timelineMemoriesProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const LifeTimelineApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(
      find.text('Explore feature implementation is intentionally deferred.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Capture'));
    await tester.pumpAndSettle();
    expect(find.text('Add memory manually'), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(
      find.text('Explore feature implementation is intentionally deferred.'),
      findsOneWidget,
    );
  });
}
