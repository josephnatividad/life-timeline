import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/insights/application/ask_my_life_service.dart';
import 'package:life_timeline/features/insights/application/rule_based_life_query_interpreter.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/features/insights/infrastructure/drift_life_query_executor.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide Entity, Event, Relationship;
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

void main() {
  late AppDatabase database;
  late DriftTimelineRepository repository;
  late DriftLifeQueryExecutor executor;
  late AskMyLifeService service;
  final now = DateTime.utc(2026, 8, 11);

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTimelineRepository(database);
    executor = DriftLifeQueryExecutor(database);
    service = AskMyLifeService(const RuleBasedLifeQueryInterpreter(), executor);

    await _owned(
      repository,
      entityId: 'phone-galaxy',
      entityName: 'Galaxy S8',
      entityType: 'phone',
      eventId: 'event-galaxy-bought',
      eventTitle: 'Bought Galaxy S8',
      temporal: TemporalValue.year(2012),
    );
    await _eventFor(
      repository,
      entityId: 'phone-galaxy',
      eventId: 'event-galaxy-sold',
      eventTitle: 'Sold Galaxy S8',
      eventType: 'Sold',
      temporal: TemporalValue.year(2018),
    );
    await _owned(
      repository,
      entityId: 'phone-iphone',
      entityName: 'iPhone 12',
      entityType: 'smartphone',
      eventId: 'event-iphone-bought',
      eventTitle: 'Bought iPhone 12',
      temporal: TemporalValue.exactDate(year: 2020, month: 1, day: 15),
    );
    await _owned(
      repository,
      entityId: 'phone-archived',
      entityName: 'Archived Phone',
      entityType: 'phone',
      eventId: 'event-phone-archived',
      eventTitle: 'Bought archived phone',
      temporal: TemporalValue.year(2025),
      lifecycle: RecordLifecycle.archived,
    );
    await _owned(
      repository,
      entityId: 'phone-trashed',
      entityName: 'Trashed Phone',
      entityType: 'phone',
      eventId: 'event-phone-trashed',
      eventTitle: 'Bought trashed phone',
      temporal: TemporalValue.year(2024),
      lifecycle: RecordLifecycle.softDeleted,
    );

    await _owned(
      repository,
      entityId: 'computer-old',
      entityName: 'Old Laptop',
      entityType: 'laptop',
      eventId: 'event-computer-old',
      eventTitle: 'Purchased Old Laptop',
      temporal: TemporalValue.month(year: 2018, month: 3),
    );
    await _owned(
      repository,
      entityId: 'computer-current',
      entityName: 'Current Laptop',
      entityType: 'computer',
      eventId: 'event-computer-current',
      eventTitle: 'Purchased Current Laptop',
      temporal: TemporalValue.month(year: 2022, month: 6),
    );
    await _owned(
      repository,
      entityId: 'vehicle-car',
      entityName: 'Family Car',
      entityType: 'vehicle',
      eventId: 'event-car-bought',
      eventTitle: 'Bought Family Car',
      temporal: TemporalValue.year(2017),
    );
    await _owned(
      repository,
      entityId: 'document-passport',
      entityName: 'Passport',
      entityType: 'passport',
      eventId: 'event-passport-issued',
      eventTitle: 'Got Passport',
      temporal: TemporalValue.year(2016),
    );
    await _eventFor(
      repository,
      entityId: 'document-passport',
      eventId: 'event-passport-expiry',
      eventTitle: 'Passport expires',
      eventType: 'Expiration',
      temporal: TemporalValue.exactDate(year: 2026, month: 11, day: 4),
    );
    await _owned(
      repository,
      entityId: 'place-japan',
      entityName: 'Japan',
      entityType: 'country',
      eventId: 'event-japan-trip',
      eventTitle: 'Visited Japan',
      temporal: TemporalValue.year(2025),
      eventType: 'Travel',
    );
    await _owned(
      repository,
      entityId: 'employer-studio',
      entityName: 'Design Studio',
      entityType: 'employer',
      eventId: 'event-job-start',
      eventTitle: 'Joined Design Studio',
      temporal: TemporalValue.month(year: 2023, month: 2),
      eventType: 'Joined',
    );
    await repository.saveEvent(
      Event(
        metadata: _metadata('event-anniversary-exact'),
        title: 'Graduation Day',
        temporalValue: TemporalValue.exactDate(year: 2016, month: 8, day: 11),
        eventType: 'Graduated',
      ),
    );
    await repository.saveEvent(
      Event(
        metadata: _metadata('event-anniversary-year-only'),
        title: 'Year-only milestone',
        temporalValue: TemporalValue.year(2021),
        eventType: 'Milestone',
      ),
    );
    await repository.saveEvent(
      Event(
        metadata: _metadata('event-unknown-date'),
        title: 'Memory with unknown date',
        temporalValue: TemporalValue.unknown(),
        eventType: 'Milestone',
      ),
    );
  });

  tearDown(() => database.close());

  test(
    'question to evidence-backed phone count excludes archive and Trash',
    () async {
      final result = await service.ask(
        'How many phones have I owned?',
        now: now,
      );

      expect(result.status, LifeQueryStatus.answered);
      expect(result.numericValue, 2);
      expect(result.entityIds, containsAll(['phone-galaxy', 'phone-iphone']));
      expect(result.entityIds, isNot(contains('phone-archived')));
      expect(result.entityIds, isNot(contains('phone-trashed')));
    },
  );

  test('latest and previous laptop preserve supporting records', () async {
    final latest = await service.ask(
      'When did I buy my current laptop?',
      now: now,
    );
    final previous = await service.ask(
      'What laptop did I have before this one?',
      now: now,
    );

    expect(latest.headline, 'Current Laptop');
    expect(latest.summary, contains('June 2022'));
    expect(latest.eventIds, contains('event-computer-current'));
    expect(previous.headline, 'Old Laptop');
    expect(
      previous.entityIds,
      containsAll(['computer-old', 'computer-current']),
    );
  });

  test(
    'expiry, vehicles, trips, career, and year summary are typed queries',
    () async {
      final expiry = await service.ask(
        'Which documents expire this year?',
        now: now,
      );
      final vehicles = await service.ask(
        'What vehicles have I owned?',
        now: now,
      );
      final trips = await service.ask('Where did I travel in 2025?', now: now);
      final career = await service.ask(
        'When did I start my current job?',
        now: now,
      );
      final year = await service.ask('What happened in 2026?', now: now);

      expect(expiry.eventIds, ['event-passport-expiry']);
      expect(vehicles.entityIds, ['vehicle-car']);
      expect(trips.eventIds, ['event-japan-trip']);
      expect(career.eventIds, ['event-job-start']);
      expect(year.eventIds, contains('event-passport-expiry'));
      expect(year.metadata['documentMilestones'], '1');
    },
  );

  test('ownership calculations remain precision aware', () async {
    final result = await executor.execute(
      const FindLongestOwnedEntity(LifeEntityCategory.phone),
      now: now,
    );

    expect(result.status, LifeQueryStatus.answered);
    expect(result.headline, 'iPhone 12');
    expect(result.metadata['durationLabel'], startsWith('6 years'));
    expect(result.entityIds, contains('phone-iphone'));
  });

  test(
    'anniversaries require exact dates and totals include unknown dates',
    () async {
      final anniversary = await executor.execute(
        const FindAnniversaryMilestones(),
        now: now,
      );
      final total = await executor.execute(
        const CountConfirmedMemories(),
        now: now,
      );

      expect(anniversary.headline, '10 years ago today');
      expect(anniversary.eventIds, ['event-anniversary-exact']);
      expect(
        anniversary.eventIds,
        isNot(contains('event-anniversary-year-only')),
      );
      expect(total.eventIds, contains('event-unknown-date'));
    },
  );

  test('most active year is selected by a SQL aggregate', () async {
    final result = await executor.execute(const FindMostActiveYear(), now: now);

    expect(result.headline, '2018 was your most active year');
    expect(result.numericValue, 2);
    expect(
      result.eventIds,
      containsAll(['event-galaxy-sold', 'event-computer-old']),
    );
  });

  test('understood question with missing records does not fabricate', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
    );
    final fresh = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(fresh.close);
    final emptyService = AskMyLifeService(
      const RuleBasedLifeQueryInterpreter(),
      DriftLifeQueryExecutor(fresh),
    );

    final result = await emptyService.ask(
      'What vehicles have I owned?',
      now: now,
    );

    expect(result.status, LifeQueryStatus.insufficientData);
    expect(result.supportingRecords, isEmpty);
    expect(result.summary, contains('more vehicles history'));
  });
}

Future<void> _owned(
  DriftTimelineRepository repository, {
  required String entityId,
  required String entityName,
  required String entityType,
  required String eventId,
  required String eventTitle,
  required TemporalValue temporal,
  RecordLifecycle lifecycle = RecordLifecycle.confirmed,
  String eventType = 'Purchased',
}) async {
  await repository.saveEntity(
    Entity(
      metadata: _metadata(entityId),
      name: entityName,
      entityType: entityType,
    ),
  );
  await _eventFor(
    repository,
    entityId: entityId,
    eventId: eventId,
    eventTitle: eventTitle,
    eventType: eventType,
    temporal: temporal,
    lifecycle: lifecycle,
  );
}

Future<void> _eventFor(
  DriftTimelineRepository repository, {
  required String entityId,
  required String eventId,
  required String eventTitle,
  required String eventType,
  required TemporalValue temporal,
  RecordLifecycle lifecycle = RecordLifecycle.confirmed,
}) async {
  await repository.saveEvent(
    Event(
      metadata: _metadata(eventId, lifecycle: lifecycle),
      title: eventTitle,
      temporalValue: temporal,
      eventType: eventType,
    ),
  );
  await repository.saveRelationship(
    Relationship(
      metadata: _metadata('relationship-$eventId'),
      source: TimelineRecordReference(
        type: TimelineRecordType.event,
        id: eventId,
      ),
      target: TimelineRecordReference(
        type: TimelineRecordType.entity,
        id: entityId,
      ),
      relationshipType: 'involves',
    ),
  );
}

RecordMetadata _metadata(
  String id, {
  RecordLifecycle lifecycle = RecordLifecycle.confirmed,
}) {
  final at = DateTime.utc(2026, 1, 1);
  return RecordMetadata(
    id: id,
    privacyClassification: PrivacyClassification.personal,
    lifecycle: lifecycle,
    createdAt: at,
    updatedAt: at,
    deletedAt: lifecycle == RecordLifecycle.softDeleted ? at : null,
  );
}
