import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/storage/application/storage_providers.dart';
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/presentation/storage_manager_page.dart';
import 'package:life_timeline/features/storage/presentation/widgets/storage_components.dart';

void main() {
  testWidgets(
    'storage manager renders empty state in dark mode at large text',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageOverviewProvider.overrideWith((ref) async => _overview()),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: const StorageManagerPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('Life Timeline uses'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('archive progress exposes a reduced-motion live status', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: StorageOperationProgressView(
              progress: ArchiveProgress(phase: ArchivePhase.decrypting),
              label: 'Retrieving the original',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Authenticating and decrypting locally'), findsOneWidget);
    final semantics = tester.getSemantics(
      find.byType(StorageOperationProgressView),
    );
    expect(semantics.label, contains('Retrieving the original'));
  });
}

StorageOverview _overview() {
  final inventory = StorageInventory(
    breakdown: const StorageBreakdown(databaseBytes: 1024),
    attachments: const [],
    managedFiles: const [],
    duplicateGroups: const [],
    archivedContentBytes: 0,
    archivedContentCount: 0,
    referencedContentCount: 0,
    unavailableContentCount: 0,
    missingManagedFileCount: 0,
    reclaimableCacheBytes: 0,
  );
  return StorageOverview(
    inventory: inventory,
    protection: CopyProtectionSummary(items: const []),
    health: const StorageHealth(
      appStorageBytes: 1024,
      reclaimableCacheBytes: 0,
      duplicateBytes: 0,
      archivedBytes: 0,
      warningLevel: StorageWarningLevel.healthy,
      recommendedAction: 'No urgent storage action is needed.',
    ),
    backupHealth: const BackupHealth(),
  );
}
