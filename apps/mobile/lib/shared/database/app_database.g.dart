// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EntitiesTable extends Entities with TableInfo<$EntitiesTable, Entity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyClassificationMeta =
      const VerificationMeta('privacyClassification');
  @override
  late final GeneratedColumn<String> privacyClassification =
      GeneratedColumn<String>(
        'privacy_classification',
        aliasedName,
        false,
        check: () => privacyClassification.isIn(SchemaValues.privacy),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lifecycleMeta = const VerificationMeta(
    'lifecycle',
  );
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
    'lifecycle',
    aliasedName,
    false,
    check: () => lifecycle.isIn(SchemaValues.lifecycle),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    normalizedName,
    entityType,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('privacy_classification')) {
      context.handle(
        _privacyClassificationMeta,
        privacyClassification.isAcceptableOrUnknown(
          data['privacy_classification']!,
          _privacyClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyClassificationMeta);
    }
    if (data.containsKey('lifecycle')) {
      context.handle(
        _lifecycleMeta,
        lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta),
      );
    } else if (isInserting) {
      context.missing(_lifecycleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      privacyClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_classification'],
      )!,
      lifecycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $EntitiesTable createAlias(String alias) {
    return $EntitiesTable(attachedDatabase, alias);
  }
}

class Entity extends DataClass implements Insertable<Entity> {
  final String id;
  final String privacyClassification;
  final String lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String normalizedName;
  final String entityType;
  final String? notes;
  const Entity({
    required this.id,
    required this.privacyClassification,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.normalizedName,
    required this.entityType,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['privacy_classification'] = Variable<String>(privacyClassification);
    map['lifecycle'] = Variable<String>(lifecycle);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  EntitiesCompanion toCompanion(bool nullToAbsent) {
    return EntitiesCompanion(
      id: Value(id),
      privacyClassification: Value(privacyClassification),
      lifecycle: Value(lifecycle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      normalizedName: Value(normalizedName),
      entityType: Value(entityType),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Entity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entity(
      id: serializer.fromJson<String>(json['id']),
      privacyClassification: serializer.fromJson<String>(
        json['privacyClassification'],
      ),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      entityType: serializer.fromJson<String>(json['entityType']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'privacyClassification': serializer.toJson<String>(privacyClassification),
      'lifecycle': serializer.toJson<String>(lifecycle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'entityType': serializer.toJson<String>(entityType),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Entity copyWith({
    String? id,
    String? privacyClassification,
    String? lifecycle,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    String? normalizedName,
    String? entityType,
    Value<String?> notes = const Value.absent(),
  }) => Entity(
    id: id ?? this.id,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    lifecycle: lifecycle ?? this.lifecycle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    entityType: entityType ?? this.entityType,
    notes: notes.present ? notes.value : this.notes,
  );
  Entity copyWithCompanion(EntitiesCompanion data) {
    return Entity(
      id: data.id.present ? data.id.value : this.id,
      privacyClassification: data.privacyClassification.present
          ? data.privacyClassification.value
          : this.privacyClassification,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entity(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('entityType: $entityType, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    normalizedName,
    entityType,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entity &&
          other.id == this.id &&
          other.privacyClassification == this.privacyClassification &&
          other.lifecycle == this.lifecycle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.entityType == this.entityType &&
          other.notes == this.notes);
}

class EntitiesCompanion extends UpdateCompanion<Entity> {
  final Value<String> id;
  final Value<String> privacyClassification;
  final Value<String> lifecycle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> entityType;
  final Value<String?> notes;
  final Value<int> rowid;
  const EntitiesCompanion({
    this.id = const Value.absent(),
    this.privacyClassification = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.entityType = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntitiesCompanion.insert({
    required String id,
    required String privacyClassification,
    required String lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required String normalizedName,
    required String entityType,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       privacyClassification = Value(privacyClassification),
       lifecycle = Value(lifecycle),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       normalizedName = Value(normalizedName),
       entityType = Value(entityType);
  static Insertable<Entity> custom({
    Expression<String>? id,
    Expression<String>? privacyClassification,
    Expression<String>? lifecycle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? entityType,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (privacyClassification != null)
        'privacy_classification': privacyClassification,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (entityType != null) 'entity_type': entityType,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? privacyClassification,
    Value<String>? lifecycle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? entityType,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return EntitiesCompanion(
      id: id ?? this.id,
      privacyClassification:
          privacyClassification ?? this.privacyClassification,
      lifecycle: lifecycle ?? this.lifecycle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      entityType: entityType ?? this.entityType,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (privacyClassification.present) {
      map['privacy_classification'] = Variable<String>(
        privacyClassification.value,
      );
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntitiesCompanion(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('entityType: $entityType, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyClassificationMeta =
      const VerificationMeta('privacyClassification');
  @override
  late final GeneratedColumn<String> privacyClassification =
      GeneratedColumn<String>(
        'privacy_classification',
        aliasedName,
        false,
        check: () => privacyClassification.isIn(SchemaValues.privacy),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lifecycleMeta = const VerificationMeta(
    'lifecycle',
  );
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
    'lifecycle',
    aliasedName,
    false,
    check: () => lifecycle.isIn(SchemaValues.lifecycle),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temporalPrecisionMeta = const VerificationMeta(
    'temporalPrecision',
  );
  @override
  late final GeneratedColumn<String> temporalPrecision =
      GeneratedColumn<String>(
        'temporal_precision',
        aliasedName,
        false,
        check: () => temporalPrecision.isIn(SchemaValues.temporalPrecision),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _startYearMeta = const VerificationMeta(
    'startYear',
  );
  @override
  late final GeneratedColumn<int> startYear = GeneratedColumn<int>(
    'start_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMonthMeta = const VerificationMeta(
    'startMonth',
  );
  @override
  late final GeneratedColumn<int> startMonth = GeneratedColumn<int>(
    'start_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDayMeta = const VerificationMeta(
    'startDay',
  );
  @override
  late final GeneratedColumn<int> startDay = GeneratedColumn<int>(
    'start_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endYearMeta = const VerificationMeta(
    'endYear',
  );
  @override
  late final GeneratedColumn<int> endYear = GeneratedColumn<int>(
    'end_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMonthMeta = const VerificationMeta(
    'endMonth',
  );
  @override
  late final GeneratedColumn<int> endMonth = GeneratedColumn<int>(
    'end_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDayMeta = const VerificationMeta('endDay');
  @override
  late final GeneratedColumn<int> endDay = GeneratedColumn<int>(
    'end_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedTitleMeta = const VerificationMeta(
    'normalizedTitle',
  );
  @override
  late final GeneratedColumn<String> normalizedTitle = GeneratedColumn<String>(
    'normalized_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    temporalPrecision,
    startYear,
    startMonth,
    startDay,
    endYear,
    endMonth,
    endDay,
    title,
    normalizedTitle,
    description,
    eventType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('privacy_classification')) {
      context.handle(
        _privacyClassificationMeta,
        privacyClassification.isAcceptableOrUnknown(
          data['privacy_classification']!,
          _privacyClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyClassificationMeta);
    }
    if (data.containsKey('lifecycle')) {
      context.handle(
        _lifecycleMeta,
        lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta),
      );
    } else if (isInserting) {
      context.missing(_lifecycleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('temporal_precision')) {
      context.handle(
        _temporalPrecisionMeta,
        temporalPrecision.isAcceptableOrUnknown(
          data['temporal_precision']!,
          _temporalPrecisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temporalPrecisionMeta);
    }
    if (data.containsKey('start_year')) {
      context.handle(
        _startYearMeta,
        startYear.isAcceptableOrUnknown(data['start_year']!, _startYearMeta),
      );
    }
    if (data.containsKey('start_month')) {
      context.handle(
        _startMonthMeta,
        startMonth.isAcceptableOrUnknown(data['start_month']!, _startMonthMeta),
      );
    }
    if (data.containsKey('start_day')) {
      context.handle(
        _startDayMeta,
        startDay.isAcceptableOrUnknown(data['start_day']!, _startDayMeta),
      );
    }
    if (data.containsKey('end_year')) {
      context.handle(
        _endYearMeta,
        endYear.isAcceptableOrUnknown(data['end_year']!, _endYearMeta),
      );
    }
    if (data.containsKey('end_month')) {
      context.handle(
        _endMonthMeta,
        endMonth.isAcceptableOrUnknown(data['end_month']!, _endMonthMeta),
      );
    }
    if (data.containsKey('end_day')) {
      context.handle(
        _endDayMeta,
        endDay.isAcceptableOrUnknown(data['end_day']!, _endDayMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('normalized_title')) {
      context.handle(
        _normalizedTitleMeta,
        normalizedTitle.isAcceptableOrUnknown(
          data['normalized_title']!,
          _normalizedTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedTitleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      privacyClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_classification'],
      )!,
      lifecycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      temporalPrecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temporal_precision'],
      )!,
      startYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_year'],
      ),
      startMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_month'],
      ),
      startDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_day'],
      ),
      endYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_year'],
      ),
      endMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_month'],
      ),
      endDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_day'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      normalizedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      ),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String privacyClassification;
  final String lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String temporalPrecision;
  final int? startYear;
  final int? startMonth;
  final int? startDay;
  final int? endYear;
  final int? endMonth;
  final int? endDay;
  final String title;
  final String normalizedTitle;
  final String? description;
  final String? eventType;
  const Event({
    required this.id,
    required this.privacyClassification,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.temporalPrecision,
    this.startYear,
    this.startMonth,
    this.startDay,
    this.endYear,
    this.endMonth,
    this.endDay,
    required this.title,
    required this.normalizedTitle,
    this.description,
    this.eventType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['privacy_classification'] = Variable<String>(privacyClassification);
    map['lifecycle'] = Variable<String>(lifecycle);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['temporal_precision'] = Variable<String>(temporalPrecision);
    if (!nullToAbsent || startYear != null) {
      map['start_year'] = Variable<int>(startYear);
    }
    if (!nullToAbsent || startMonth != null) {
      map['start_month'] = Variable<int>(startMonth);
    }
    if (!nullToAbsent || startDay != null) {
      map['start_day'] = Variable<int>(startDay);
    }
    if (!nullToAbsent || endYear != null) {
      map['end_year'] = Variable<int>(endYear);
    }
    if (!nullToAbsent || endMonth != null) {
      map['end_month'] = Variable<int>(endMonth);
    }
    if (!nullToAbsent || endDay != null) {
      map['end_day'] = Variable<int>(endDay);
    }
    map['title'] = Variable<String>(title);
    map['normalized_title'] = Variable<String>(normalizedTitle);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || eventType != null) {
      map['event_type'] = Variable<String>(eventType);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      privacyClassification: Value(privacyClassification),
      lifecycle: Value(lifecycle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      temporalPrecision: Value(temporalPrecision),
      startYear: startYear == null && nullToAbsent
          ? const Value.absent()
          : Value(startYear),
      startMonth: startMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(startMonth),
      startDay: startDay == null && nullToAbsent
          ? const Value.absent()
          : Value(startDay),
      endYear: endYear == null && nullToAbsent
          ? const Value.absent()
          : Value(endYear),
      endMonth: endMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(endMonth),
      endDay: endDay == null && nullToAbsent
          ? const Value.absent()
          : Value(endDay),
      title: Value(title),
      normalizedTitle: Value(normalizedTitle),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      eventType: eventType == null && nullToAbsent
          ? const Value.absent()
          : Value(eventType),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      privacyClassification: serializer.fromJson<String>(
        json['privacyClassification'],
      ),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      temporalPrecision: serializer.fromJson<String>(json['temporalPrecision']),
      startYear: serializer.fromJson<int?>(json['startYear']),
      startMonth: serializer.fromJson<int?>(json['startMonth']),
      startDay: serializer.fromJson<int?>(json['startDay']),
      endYear: serializer.fromJson<int?>(json['endYear']),
      endMonth: serializer.fromJson<int?>(json['endMonth']),
      endDay: serializer.fromJson<int?>(json['endDay']),
      title: serializer.fromJson<String>(json['title']),
      normalizedTitle: serializer.fromJson<String>(json['normalizedTitle']),
      description: serializer.fromJson<String?>(json['description']),
      eventType: serializer.fromJson<String?>(json['eventType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'privacyClassification': serializer.toJson<String>(privacyClassification),
      'lifecycle': serializer.toJson<String>(lifecycle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'temporalPrecision': serializer.toJson<String>(temporalPrecision),
      'startYear': serializer.toJson<int?>(startYear),
      'startMonth': serializer.toJson<int?>(startMonth),
      'startDay': serializer.toJson<int?>(startDay),
      'endYear': serializer.toJson<int?>(endYear),
      'endMonth': serializer.toJson<int?>(endMonth),
      'endDay': serializer.toJson<int?>(endDay),
      'title': serializer.toJson<String>(title),
      'normalizedTitle': serializer.toJson<String>(normalizedTitle),
      'description': serializer.toJson<String?>(description),
      'eventType': serializer.toJson<String?>(eventType),
    };
  }

  Event copyWith({
    String? id,
    String? privacyClassification,
    String? lifecycle,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? temporalPrecision,
    Value<int?> startYear = const Value.absent(),
    Value<int?> startMonth = const Value.absent(),
    Value<int?> startDay = const Value.absent(),
    Value<int?> endYear = const Value.absent(),
    Value<int?> endMonth = const Value.absent(),
    Value<int?> endDay = const Value.absent(),
    String? title,
    String? normalizedTitle,
    Value<String?> description = const Value.absent(),
    Value<String?> eventType = const Value.absent(),
  }) => Event(
    id: id ?? this.id,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    lifecycle: lifecycle ?? this.lifecycle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    temporalPrecision: temporalPrecision ?? this.temporalPrecision,
    startYear: startYear.present ? startYear.value : this.startYear,
    startMonth: startMonth.present ? startMonth.value : this.startMonth,
    startDay: startDay.present ? startDay.value : this.startDay,
    endYear: endYear.present ? endYear.value : this.endYear,
    endMonth: endMonth.present ? endMonth.value : this.endMonth,
    endDay: endDay.present ? endDay.value : this.endDay,
    title: title ?? this.title,
    normalizedTitle: normalizedTitle ?? this.normalizedTitle,
    description: description.present ? description.value : this.description,
    eventType: eventType.present ? eventType.value : this.eventType,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      privacyClassification: data.privacyClassification.present
          ? data.privacyClassification.value
          : this.privacyClassification,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      temporalPrecision: data.temporalPrecision.present
          ? data.temporalPrecision.value
          : this.temporalPrecision,
      startYear: data.startYear.present ? data.startYear.value : this.startYear,
      startMonth: data.startMonth.present
          ? data.startMonth.value
          : this.startMonth,
      startDay: data.startDay.present ? data.startDay.value : this.startDay,
      endYear: data.endYear.present ? data.endYear.value : this.endYear,
      endMonth: data.endMonth.present ? data.endMonth.value : this.endMonth,
      endDay: data.endDay.present ? data.endDay.value : this.endDay,
      title: data.title.present ? data.title.value : this.title,
      normalizedTitle: data.normalizedTitle.present
          ? data.normalizedTitle.value
          : this.normalizedTitle,
      description: data.description.present
          ? data.description.value
          : this.description,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('temporalPrecision: $temporalPrecision, ')
          ..write('startYear: $startYear, ')
          ..write('startMonth: $startMonth, ')
          ..write('startDay: $startDay, ')
          ..write('endYear: $endYear, ')
          ..write('endMonth: $endMonth, ')
          ..write('endDay: $endDay, ')
          ..write('title: $title, ')
          ..write('normalizedTitle: $normalizedTitle, ')
          ..write('description: $description, ')
          ..write('eventType: $eventType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    temporalPrecision,
    startYear,
    startMonth,
    startDay,
    endYear,
    endMonth,
    endDay,
    title,
    normalizedTitle,
    description,
    eventType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.privacyClassification == this.privacyClassification &&
          other.lifecycle == this.lifecycle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.temporalPrecision == this.temporalPrecision &&
          other.startYear == this.startYear &&
          other.startMonth == this.startMonth &&
          other.startDay == this.startDay &&
          other.endYear == this.endYear &&
          other.endMonth == this.endMonth &&
          other.endDay == this.endDay &&
          other.title == this.title &&
          other.normalizedTitle == this.normalizedTitle &&
          other.description == this.description &&
          other.eventType == this.eventType);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> privacyClassification;
  final Value<String> lifecycle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> temporalPrecision;
  final Value<int?> startYear;
  final Value<int?> startMonth;
  final Value<int?> startDay;
  final Value<int?> endYear;
  final Value<int?> endMonth;
  final Value<int?> endDay;
  final Value<String> title;
  final Value<String> normalizedTitle;
  final Value<String?> description;
  final Value<String?> eventType;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.privacyClassification = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.temporalPrecision = const Value.absent(),
    this.startYear = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endYear = const Value.absent(),
    this.endMonth = const Value.absent(),
    this.endDay = const Value.absent(),
    this.title = const Value.absent(),
    this.normalizedTitle = const Value.absent(),
    this.description = const Value.absent(),
    this.eventType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String privacyClassification,
    required String lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String temporalPrecision,
    this.startYear = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endYear = const Value.absent(),
    this.endMonth = const Value.absent(),
    this.endDay = const Value.absent(),
    required String title,
    required String normalizedTitle,
    this.description = const Value.absent(),
    this.eventType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       privacyClassification = Value(privacyClassification),
       lifecycle = Value(lifecycle),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       temporalPrecision = Value(temporalPrecision),
       title = Value(title),
       normalizedTitle = Value(normalizedTitle);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? privacyClassification,
    Expression<String>? lifecycle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? temporalPrecision,
    Expression<int>? startYear,
    Expression<int>? startMonth,
    Expression<int>? startDay,
    Expression<int>? endYear,
    Expression<int>? endMonth,
    Expression<int>? endDay,
    Expression<String>? title,
    Expression<String>? normalizedTitle,
    Expression<String>? description,
    Expression<String>? eventType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (privacyClassification != null)
        'privacy_classification': privacyClassification,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (temporalPrecision != null) 'temporal_precision': temporalPrecision,
      if (startYear != null) 'start_year': startYear,
      if (startMonth != null) 'start_month': startMonth,
      if (startDay != null) 'start_day': startDay,
      if (endYear != null) 'end_year': endYear,
      if (endMonth != null) 'end_month': endMonth,
      if (endDay != null) 'end_day': endDay,
      if (title != null) 'title': title,
      if (normalizedTitle != null) 'normalized_title': normalizedTitle,
      if (description != null) 'description': description,
      if (eventType != null) 'event_type': eventType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? privacyClassification,
    Value<String>? lifecycle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? temporalPrecision,
    Value<int?>? startYear,
    Value<int?>? startMonth,
    Value<int?>? startDay,
    Value<int?>? endYear,
    Value<int?>? endMonth,
    Value<int?>? endDay,
    Value<String>? title,
    Value<String>? normalizedTitle,
    Value<String?>? description,
    Value<String?>? eventType,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      privacyClassification:
          privacyClassification ?? this.privacyClassification,
      lifecycle: lifecycle ?? this.lifecycle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      temporalPrecision: temporalPrecision ?? this.temporalPrecision,
      startYear: startYear ?? this.startYear,
      startMonth: startMonth ?? this.startMonth,
      startDay: startDay ?? this.startDay,
      endYear: endYear ?? this.endYear,
      endMonth: endMonth ?? this.endMonth,
      endDay: endDay ?? this.endDay,
      title: title ?? this.title,
      normalizedTitle: normalizedTitle ?? this.normalizedTitle,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (privacyClassification.present) {
      map['privacy_classification'] = Variable<String>(
        privacyClassification.value,
      );
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (temporalPrecision.present) {
      map['temporal_precision'] = Variable<String>(temporalPrecision.value);
    }
    if (startYear.present) {
      map['start_year'] = Variable<int>(startYear.value);
    }
    if (startMonth.present) {
      map['start_month'] = Variable<int>(startMonth.value);
    }
    if (startDay.present) {
      map['start_day'] = Variable<int>(startDay.value);
    }
    if (endYear.present) {
      map['end_year'] = Variable<int>(endYear.value);
    }
    if (endMonth.present) {
      map['end_month'] = Variable<int>(endMonth.value);
    }
    if (endDay.present) {
      map['end_day'] = Variable<int>(endDay.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (normalizedTitle.present) {
      map['normalized_title'] = Variable<String>(normalizedTitle.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('temporalPrecision: $temporalPrecision, ')
          ..write('startYear: $startYear, ')
          ..write('startMonth: $startMonth, ')
          ..write('startDay: $startDay, ')
          ..write('endYear: $endYear, ')
          ..write('endMonth: $endMonth, ')
          ..write('endDay: $endDay, ')
          ..write('title: $title, ')
          ..write('normalizedTitle: $normalizedTitle, ')
          ..write('description: $description, ')
          ..write('eventType: $eventType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EvidenceRecordsTable extends EvidenceRecords
    with TableInfo<$EvidenceRecordsTable, EvidenceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidenceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyClassificationMeta =
      const VerificationMeta('privacyClassification');
  @override
  late final GeneratedColumn<String> privacyClassification =
      GeneratedColumn<String>(
        'privacy_classification',
        aliasedName,
        false,
        check: () => privacyClassification.isIn(SchemaValues.privacy),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lifecycleMeta = const VerificationMeta(
    'lifecycle',
  );
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
    'lifecycle',
    aliasedName,
    false,
    check: () => lifecycle.isIn(SchemaValues.lifecycle),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedTitleMeta = const VerificationMeta(
    'normalizedTitle',
  );
  @override
  late final GeneratedColumn<String> normalizedTitle = GeneratedColumn<String>(
    'normalized_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceTypeMeta = const VerificationMeta(
    'evidenceType',
  );
  @override
  late final GeneratedColumn<String> evidenceType = GeneratedColumn<String>(
    'evidence_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    title,
    normalizedTitle,
    evidenceType,
    summary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidence';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvidenceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('privacy_classification')) {
      context.handle(
        _privacyClassificationMeta,
        privacyClassification.isAcceptableOrUnknown(
          data['privacy_classification']!,
          _privacyClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyClassificationMeta);
    }
    if (data.containsKey('lifecycle')) {
      context.handle(
        _lifecycleMeta,
        lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta),
      );
    } else if (isInserting) {
      context.missing(_lifecycleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('normalized_title')) {
      context.handle(
        _normalizedTitleMeta,
        normalizedTitle.isAcceptableOrUnknown(
          data['normalized_title']!,
          _normalizedTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedTitleMeta);
    }
    if (data.containsKey('evidence_type')) {
      context.handle(
        _evidenceTypeMeta,
        evidenceType.isAcceptableOrUnknown(
          data['evidence_type']!,
          _evidenceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidenceTypeMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EvidenceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvidenceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      privacyClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_classification'],
      )!,
      lifecycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      normalizedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_title'],
      )!,
      evidenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_type'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
    );
  }

  @override
  $EvidenceRecordsTable createAlias(String alias) {
    return $EvidenceRecordsTable(attachedDatabase, alias);
  }
}

class EvidenceRecord extends DataClass implements Insertable<EvidenceRecord> {
  final String id;
  final String privacyClassification;
  final String lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String title;
  final String normalizedTitle;
  final String evidenceType;
  final String? summary;
  const EvidenceRecord({
    required this.id,
    required this.privacyClassification,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.title,
    required this.normalizedTitle,
    required this.evidenceType,
    this.summary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['privacy_classification'] = Variable<String>(privacyClassification);
    map['lifecycle'] = Variable<String>(lifecycle);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['title'] = Variable<String>(title);
    map['normalized_title'] = Variable<String>(normalizedTitle);
    map['evidence_type'] = Variable<String>(evidenceType);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    return map;
  }

  EvidenceRecordsCompanion toCompanion(bool nullToAbsent) {
    return EvidenceRecordsCompanion(
      id: Value(id),
      privacyClassification: Value(privacyClassification),
      lifecycle: Value(lifecycle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      title: Value(title),
      normalizedTitle: Value(normalizedTitle),
      evidenceType: Value(evidenceType),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
    );
  }

  factory EvidenceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvidenceRecord(
      id: serializer.fromJson<String>(json['id']),
      privacyClassification: serializer.fromJson<String>(
        json['privacyClassification'],
      ),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      title: serializer.fromJson<String>(json['title']),
      normalizedTitle: serializer.fromJson<String>(json['normalizedTitle']),
      evidenceType: serializer.fromJson<String>(json['evidenceType']),
      summary: serializer.fromJson<String?>(json['summary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'privacyClassification': serializer.toJson<String>(privacyClassification),
      'lifecycle': serializer.toJson<String>(lifecycle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'title': serializer.toJson<String>(title),
      'normalizedTitle': serializer.toJson<String>(normalizedTitle),
      'evidenceType': serializer.toJson<String>(evidenceType),
      'summary': serializer.toJson<String?>(summary),
    };
  }

  EvidenceRecord copyWith({
    String? id,
    String? privacyClassification,
    String? lifecycle,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? title,
    String? normalizedTitle,
    String? evidenceType,
    Value<String?> summary = const Value.absent(),
  }) => EvidenceRecord(
    id: id ?? this.id,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    lifecycle: lifecycle ?? this.lifecycle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    title: title ?? this.title,
    normalizedTitle: normalizedTitle ?? this.normalizedTitle,
    evidenceType: evidenceType ?? this.evidenceType,
    summary: summary.present ? summary.value : this.summary,
  );
  EvidenceRecord copyWithCompanion(EvidenceRecordsCompanion data) {
    return EvidenceRecord(
      id: data.id.present ? data.id.value : this.id,
      privacyClassification: data.privacyClassification.present
          ? data.privacyClassification.value
          : this.privacyClassification,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      title: data.title.present ? data.title.value : this.title,
      normalizedTitle: data.normalizedTitle.present
          ? data.normalizedTitle.value
          : this.normalizedTitle,
      evidenceType: data.evidenceType.present
          ? data.evidenceType.value
          : this.evidenceType,
      summary: data.summary.present ? data.summary.value : this.summary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceRecord(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('title: $title, ')
          ..write('normalizedTitle: $normalizedTitle, ')
          ..write('evidenceType: $evidenceType, ')
          ..write('summary: $summary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    title,
    normalizedTitle,
    evidenceType,
    summary,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvidenceRecord &&
          other.id == this.id &&
          other.privacyClassification == this.privacyClassification &&
          other.lifecycle == this.lifecycle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.title == this.title &&
          other.normalizedTitle == this.normalizedTitle &&
          other.evidenceType == this.evidenceType &&
          other.summary == this.summary);
}

class EvidenceRecordsCompanion extends UpdateCompanion<EvidenceRecord> {
  final Value<String> id;
  final Value<String> privacyClassification;
  final Value<String> lifecycle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> title;
  final Value<String> normalizedTitle;
  final Value<String> evidenceType;
  final Value<String?> summary;
  final Value<int> rowid;
  const EvidenceRecordsCompanion({
    this.id = const Value.absent(),
    this.privacyClassification = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.normalizedTitle = const Value.absent(),
    this.evidenceType = const Value.absent(),
    this.summary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvidenceRecordsCompanion.insert({
    required String id,
    required String privacyClassification,
    required String lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String title,
    required String normalizedTitle,
    required String evidenceType,
    this.summary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       privacyClassification = Value(privacyClassification),
       lifecycle = Value(lifecycle),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title),
       normalizedTitle = Value(normalizedTitle),
       evidenceType = Value(evidenceType);
  static Insertable<EvidenceRecord> custom({
    Expression<String>? id,
    Expression<String>? privacyClassification,
    Expression<String>? lifecycle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? title,
    Expression<String>? normalizedTitle,
    Expression<String>? evidenceType,
    Expression<String>? summary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (privacyClassification != null)
        'privacy_classification': privacyClassification,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (title != null) 'title': title,
      if (normalizedTitle != null) 'normalized_title': normalizedTitle,
      if (evidenceType != null) 'evidence_type': evidenceType,
      if (summary != null) 'summary': summary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvidenceRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? privacyClassification,
    Value<String>? lifecycle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? title,
    Value<String>? normalizedTitle,
    Value<String>? evidenceType,
    Value<String?>? summary,
    Value<int>? rowid,
  }) {
    return EvidenceRecordsCompanion(
      id: id ?? this.id,
      privacyClassification:
          privacyClassification ?? this.privacyClassification,
      lifecycle: lifecycle ?? this.lifecycle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      title: title ?? this.title,
      normalizedTitle: normalizedTitle ?? this.normalizedTitle,
      evidenceType: evidenceType ?? this.evidenceType,
      summary: summary ?? this.summary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (privacyClassification.present) {
      map['privacy_classification'] = Variable<String>(
        privacyClassification.value,
      );
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (normalizedTitle.present) {
      map['normalized_title'] = Variable<String>(normalizedTitle.value);
    }
    if (evidenceType.present) {
      map['evidence_type'] = Variable<String>(evidenceType.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('title: $title, ')
          ..write('normalizedTitle: $normalizedTitle, ')
          ..write('evidenceType: $evidenceType, ')
          ..write('summary: $summary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelationshipsTable extends Relationships
    with TableInfo<$RelationshipsTable, Relationship> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyClassificationMeta =
      const VerificationMeta('privacyClassification');
  @override
  late final GeneratedColumn<String> privacyClassification =
      GeneratedColumn<String>(
        'privacy_classification',
        aliasedName,
        false,
        check: () => privacyClassification.isIn(SchemaValues.privacy),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lifecycleMeta = const VerificationMeta(
    'lifecycle',
  );
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
    'lifecycle',
    aliasedName,
    false,
    check: () => lifecycle.isIn(SchemaValues.lifecycle),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceEntityIdMeta = const VerificationMeta(
    'sourceEntityId',
  );
  @override
  late final GeneratedColumn<String> sourceEntityId = GeneratedColumn<String>(
    'source_entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entities (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _sourceEventIdMeta = const VerificationMeta(
    'sourceEventId',
  );
  @override
  late final GeneratedColumn<String> sourceEventId = GeneratedColumn<String>(
    'source_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _sourceEvidenceIdMeta = const VerificationMeta(
    'sourceEvidenceId',
  );
  @override
  late final GeneratedColumn<String> sourceEvidenceId = GeneratedColumn<String>(
    'source_evidence_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES evidence (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _targetEntityIdMeta = const VerificationMeta(
    'targetEntityId',
  );
  @override
  late final GeneratedColumn<String> targetEntityId = GeneratedColumn<String>(
    'target_entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entities (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _targetEventIdMeta = const VerificationMeta(
    'targetEventId',
  );
  @override
  late final GeneratedColumn<String> targetEventId = GeneratedColumn<String>(
    'target_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _targetEvidenceIdMeta = const VerificationMeta(
    'targetEvidenceId',
  );
  @override
  late final GeneratedColumn<String> targetEvidenceId = GeneratedColumn<String>(
    'target_evidence_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES evidence (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _relationshipTypeMeta = const VerificationMeta(
    'relationshipType',
  );
  @override
  late final GeneratedColumn<String> relationshipType = GeneratedColumn<String>(
    'relationship_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    sourceEntityId,
    sourceEventId,
    sourceEvidenceId,
    targetEntityId,
    targetEventId,
    targetEvidenceId,
    relationshipType,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<Relationship> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('privacy_classification')) {
      context.handle(
        _privacyClassificationMeta,
        privacyClassification.isAcceptableOrUnknown(
          data['privacy_classification']!,
          _privacyClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyClassificationMeta);
    }
    if (data.containsKey('lifecycle')) {
      context.handle(
        _lifecycleMeta,
        lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta),
      );
    } else if (isInserting) {
      context.missing(_lifecycleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('source_entity_id')) {
      context.handle(
        _sourceEntityIdMeta,
        sourceEntityId.isAcceptableOrUnknown(
          data['source_entity_id']!,
          _sourceEntityIdMeta,
        ),
      );
    }
    if (data.containsKey('source_event_id')) {
      context.handle(
        _sourceEventIdMeta,
        sourceEventId.isAcceptableOrUnknown(
          data['source_event_id']!,
          _sourceEventIdMeta,
        ),
      );
    }
    if (data.containsKey('source_evidence_id')) {
      context.handle(
        _sourceEvidenceIdMeta,
        sourceEvidenceId.isAcceptableOrUnknown(
          data['source_evidence_id']!,
          _sourceEvidenceIdMeta,
        ),
      );
    }
    if (data.containsKey('target_entity_id')) {
      context.handle(
        _targetEntityIdMeta,
        targetEntityId.isAcceptableOrUnknown(
          data['target_entity_id']!,
          _targetEntityIdMeta,
        ),
      );
    }
    if (data.containsKey('target_event_id')) {
      context.handle(
        _targetEventIdMeta,
        targetEventId.isAcceptableOrUnknown(
          data['target_event_id']!,
          _targetEventIdMeta,
        ),
      );
    }
    if (data.containsKey('target_evidence_id')) {
      context.handle(
        _targetEvidenceIdMeta,
        targetEvidenceId.isAcceptableOrUnknown(
          data['target_evidence_id']!,
          _targetEvidenceIdMeta,
        ),
      );
    }
    if (data.containsKey('relationship_type')) {
      context.handle(
        _relationshipTypeMeta,
        relationshipType.isAcceptableOrUnknown(
          data['relationship_type']!,
          _relationshipTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationshipTypeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Relationship map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Relationship(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      privacyClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_classification'],
      )!,
      lifecycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      sourceEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_entity_id'],
      ),
      sourceEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_event_id'],
      ),
      sourceEvidenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_evidence_id'],
      ),
      targetEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_entity_id'],
      ),
      targetEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_event_id'],
      ),
      targetEvidenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_evidence_id'],
      ),
      relationshipType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $RelationshipsTable createAlias(String alias) {
    return $RelationshipsTable(attachedDatabase, alias);
  }
}

class Relationship extends DataClass implements Insertable<Relationship> {
  final String id;
  final String privacyClassification;
  final String lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? sourceEntityId;
  final String? sourceEventId;
  final String? sourceEvidenceId;
  final String? targetEntityId;
  final String? targetEventId;
  final String? targetEvidenceId;
  final String relationshipType;
  final String? notes;
  const Relationship({
    required this.id,
    required this.privacyClassification,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.sourceEntityId,
    this.sourceEventId,
    this.sourceEvidenceId,
    this.targetEntityId,
    this.targetEventId,
    this.targetEvidenceId,
    required this.relationshipType,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['privacy_classification'] = Variable<String>(privacyClassification);
    map['lifecycle'] = Variable<String>(lifecycle);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || sourceEntityId != null) {
      map['source_entity_id'] = Variable<String>(sourceEntityId);
    }
    if (!nullToAbsent || sourceEventId != null) {
      map['source_event_id'] = Variable<String>(sourceEventId);
    }
    if (!nullToAbsent || sourceEvidenceId != null) {
      map['source_evidence_id'] = Variable<String>(sourceEvidenceId);
    }
    if (!nullToAbsent || targetEntityId != null) {
      map['target_entity_id'] = Variable<String>(targetEntityId);
    }
    if (!nullToAbsent || targetEventId != null) {
      map['target_event_id'] = Variable<String>(targetEventId);
    }
    if (!nullToAbsent || targetEvidenceId != null) {
      map['target_evidence_id'] = Variable<String>(targetEvidenceId);
    }
    map['relationship_type'] = Variable<String>(relationshipType);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  RelationshipsCompanion toCompanion(bool nullToAbsent) {
    return RelationshipsCompanion(
      id: Value(id),
      privacyClassification: Value(privacyClassification),
      lifecycle: Value(lifecycle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      sourceEntityId: sourceEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEntityId),
      sourceEventId: sourceEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEventId),
      sourceEvidenceId: sourceEvidenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEvidenceId),
      targetEntityId: targetEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetEntityId),
      targetEventId: targetEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetEventId),
      targetEvidenceId: targetEvidenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetEvidenceId),
      relationshipType: Value(relationshipType),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Relationship.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Relationship(
      id: serializer.fromJson<String>(json['id']),
      privacyClassification: serializer.fromJson<String>(
        json['privacyClassification'],
      ),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      sourceEntityId: serializer.fromJson<String?>(json['sourceEntityId']),
      sourceEventId: serializer.fromJson<String?>(json['sourceEventId']),
      sourceEvidenceId: serializer.fromJson<String?>(json['sourceEvidenceId']),
      targetEntityId: serializer.fromJson<String?>(json['targetEntityId']),
      targetEventId: serializer.fromJson<String?>(json['targetEventId']),
      targetEvidenceId: serializer.fromJson<String?>(json['targetEvidenceId']),
      relationshipType: serializer.fromJson<String>(json['relationshipType']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'privacyClassification': serializer.toJson<String>(privacyClassification),
      'lifecycle': serializer.toJson<String>(lifecycle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'sourceEntityId': serializer.toJson<String?>(sourceEntityId),
      'sourceEventId': serializer.toJson<String?>(sourceEventId),
      'sourceEvidenceId': serializer.toJson<String?>(sourceEvidenceId),
      'targetEntityId': serializer.toJson<String?>(targetEntityId),
      'targetEventId': serializer.toJson<String?>(targetEventId),
      'targetEvidenceId': serializer.toJson<String?>(targetEvidenceId),
      'relationshipType': serializer.toJson<String>(relationshipType),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Relationship copyWith({
    String? id,
    String? privacyClassification,
    String? lifecycle,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> sourceEntityId = const Value.absent(),
    Value<String?> sourceEventId = const Value.absent(),
    Value<String?> sourceEvidenceId = const Value.absent(),
    Value<String?> targetEntityId = const Value.absent(),
    Value<String?> targetEventId = const Value.absent(),
    Value<String?> targetEvidenceId = const Value.absent(),
    String? relationshipType,
    Value<String?> notes = const Value.absent(),
  }) => Relationship(
    id: id ?? this.id,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    lifecycle: lifecycle ?? this.lifecycle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    sourceEntityId: sourceEntityId.present
        ? sourceEntityId.value
        : this.sourceEntityId,
    sourceEventId: sourceEventId.present
        ? sourceEventId.value
        : this.sourceEventId,
    sourceEvidenceId: sourceEvidenceId.present
        ? sourceEvidenceId.value
        : this.sourceEvidenceId,
    targetEntityId: targetEntityId.present
        ? targetEntityId.value
        : this.targetEntityId,
    targetEventId: targetEventId.present
        ? targetEventId.value
        : this.targetEventId,
    targetEvidenceId: targetEvidenceId.present
        ? targetEvidenceId.value
        : this.targetEvidenceId,
    relationshipType: relationshipType ?? this.relationshipType,
    notes: notes.present ? notes.value : this.notes,
  );
  Relationship copyWithCompanion(RelationshipsCompanion data) {
    return Relationship(
      id: data.id.present ? data.id.value : this.id,
      privacyClassification: data.privacyClassification.present
          ? data.privacyClassification.value
          : this.privacyClassification,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      sourceEntityId: data.sourceEntityId.present
          ? data.sourceEntityId.value
          : this.sourceEntityId,
      sourceEventId: data.sourceEventId.present
          ? data.sourceEventId.value
          : this.sourceEventId,
      sourceEvidenceId: data.sourceEvidenceId.present
          ? data.sourceEvidenceId.value
          : this.sourceEvidenceId,
      targetEntityId: data.targetEntityId.present
          ? data.targetEntityId.value
          : this.targetEntityId,
      targetEventId: data.targetEventId.present
          ? data.targetEventId.value
          : this.targetEventId,
      targetEvidenceId: data.targetEvidenceId.present
          ? data.targetEvidenceId.value
          : this.targetEvidenceId,
      relationshipType: data.relationshipType.present
          ? data.relationshipType.value
          : this.relationshipType,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Relationship(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('sourceEntityId: $sourceEntityId, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('sourceEvidenceId: $sourceEvidenceId, ')
          ..write('targetEntityId: $targetEntityId, ')
          ..write('targetEventId: $targetEventId, ')
          ..write('targetEvidenceId: $targetEvidenceId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    sourceEntityId,
    sourceEventId,
    sourceEvidenceId,
    targetEntityId,
    targetEventId,
    targetEvidenceId,
    relationshipType,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Relationship &&
          other.id == this.id &&
          other.privacyClassification == this.privacyClassification &&
          other.lifecycle == this.lifecycle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.sourceEntityId == this.sourceEntityId &&
          other.sourceEventId == this.sourceEventId &&
          other.sourceEvidenceId == this.sourceEvidenceId &&
          other.targetEntityId == this.targetEntityId &&
          other.targetEventId == this.targetEventId &&
          other.targetEvidenceId == this.targetEvidenceId &&
          other.relationshipType == this.relationshipType &&
          other.notes == this.notes);
}

class RelationshipsCompanion extends UpdateCompanion<Relationship> {
  final Value<String> id;
  final Value<String> privacyClassification;
  final Value<String> lifecycle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> sourceEntityId;
  final Value<String?> sourceEventId;
  final Value<String?> sourceEvidenceId;
  final Value<String?> targetEntityId;
  final Value<String?> targetEventId;
  final Value<String?> targetEvidenceId;
  final Value<String> relationshipType;
  final Value<String?> notes;
  final Value<int> rowid;
  const RelationshipsCompanion({
    this.id = const Value.absent(),
    this.privacyClassification = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.sourceEntityId = const Value.absent(),
    this.sourceEventId = const Value.absent(),
    this.sourceEvidenceId = const Value.absent(),
    this.targetEntityId = const Value.absent(),
    this.targetEventId = const Value.absent(),
    this.targetEvidenceId = const Value.absent(),
    this.relationshipType = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelationshipsCompanion.insert({
    required String id,
    required String privacyClassification,
    required String lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.sourceEntityId = const Value.absent(),
    this.sourceEventId = const Value.absent(),
    this.sourceEvidenceId = const Value.absent(),
    this.targetEntityId = const Value.absent(),
    this.targetEventId = const Value.absent(),
    this.targetEvidenceId = const Value.absent(),
    required String relationshipType,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       privacyClassification = Value(privacyClassification),
       lifecycle = Value(lifecycle),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       relationshipType = Value(relationshipType);
  static Insertable<Relationship> custom({
    Expression<String>? id,
    Expression<String>? privacyClassification,
    Expression<String>? lifecycle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? sourceEntityId,
    Expression<String>? sourceEventId,
    Expression<String>? sourceEvidenceId,
    Expression<String>? targetEntityId,
    Expression<String>? targetEventId,
    Expression<String>? targetEvidenceId,
    Expression<String>? relationshipType,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (privacyClassification != null)
        'privacy_classification': privacyClassification,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (sourceEntityId != null) 'source_entity_id': sourceEntityId,
      if (sourceEventId != null) 'source_event_id': sourceEventId,
      if (sourceEvidenceId != null) 'source_evidence_id': sourceEvidenceId,
      if (targetEntityId != null) 'target_entity_id': targetEntityId,
      if (targetEventId != null) 'target_event_id': targetEventId,
      if (targetEvidenceId != null) 'target_evidence_id': targetEvidenceId,
      if (relationshipType != null) 'relationship_type': relationshipType,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelationshipsCompanion copyWith({
    Value<String>? id,
    Value<String>? privacyClassification,
    Value<String>? lifecycle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? sourceEntityId,
    Value<String?>? sourceEventId,
    Value<String?>? sourceEvidenceId,
    Value<String?>? targetEntityId,
    Value<String?>? targetEventId,
    Value<String?>? targetEvidenceId,
    Value<String>? relationshipType,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return RelationshipsCompanion(
      id: id ?? this.id,
      privacyClassification:
          privacyClassification ?? this.privacyClassification,
      lifecycle: lifecycle ?? this.lifecycle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      sourceEntityId: sourceEntityId ?? this.sourceEntityId,
      sourceEventId: sourceEventId ?? this.sourceEventId,
      sourceEvidenceId: sourceEvidenceId ?? this.sourceEvidenceId,
      targetEntityId: targetEntityId ?? this.targetEntityId,
      targetEventId: targetEventId ?? this.targetEventId,
      targetEvidenceId: targetEvidenceId ?? this.targetEvidenceId,
      relationshipType: relationshipType ?? this.relationshipType,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (privacyClassification.present) {
      map['privacy_classification'] = Variable<String>(
        privacyClassification.value,
      );
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (sourceEntityId.present) {
      map['source_entity_id'] = Variable<String>(sourceEntityId.value);
    }
    if (sourceEventId.present) {
      map['source_event_id'] = Variable<String>(sourceEventId.value);
    }
    if (sourceEvidenceId.present) {
      map['source_evidence_id'] = Variable<String>(sourceEvidenceId.value);
    }
    if (targetEntityId.present) {
      map['target_entity_id'] = Variable<String>(targetEntityId.value);
    }
    if (targetEventId.present) {
      map['target_event_id'] = Variable<String>(targetEventId.value);
    }
    if (targetEvidenceId.present) {
      map['target_evidence_id'] = Variable<String>(targetEvidenceId.value);
    }
    if (relationshipType.present) {
      map['relationship_type'] = Variable<String>(relationshipType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('sourceEntityId: $sourceEntityId, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('sourceEvidenceId: $sourceEvidenceId, ')
          ..write('targetEntityId: $targetEntityId, ')
          ..write('targetEventId: $targetEventId, ')
          ..write('targetEvidenceId: $targetEvidenceId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyClassificationMeta =
      const VerificationMeta('privacyClassification');
  @override
  late final GeneratedColumn<String> privacyClassification =
      GeneratedColumn<String>(
        'privacy_classification',
        aliasedName,
        false,
        check: () => privacyClassification.isIn(SchemaValues.privacy),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lifecycleMeta = const VerificationMeta(
    'lifecycle',
  );
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
    'lifecycle',
    aliasedName,
    false,
    check: () => lifecycle.isIn(SchemaValues.lifecycle),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _evidenceIdMeta = const VerificationMeta(
    'evidenceId',
  );
  @override
  late final GeneratedColumn<String> evidenceId = GeneratedColumn<String>(
    'evidence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES evidence (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailRelativePathMeta =
      const VerificationMeta('thumbnailRelativePath');
  @override
  late final GeneratedColumn<String> thumbnailRelativePath =
      GeneratedColumn<String>(
        'thumbnail_relative_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    check: () => ComparableExpr(byteSize).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storageStateMeta = const VerificationMeta(
    'storageState',
  );
  @override
  late final GeneratedColumn<String> storageState = GeneratedColumn<String>(
    'storage_state',
    aliasedName,
    false,
    check: () => storageState.isIn(const [
      'local',
      'referenced',
      'archived',
      'unavailable',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importModeMeta = const VerificationMeta(
    'importMode',
  );
  @override
  late final GeneratedColumn<String> importMode = GeneratedColumn<String>(
    'import_mode',
    aliasedName,
    false,
    check: () => importMode.isIn(const [
      'reference_original',
      'optimized_copy',
      'preserve_original',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    evidenceId,
    displayName,
    relativePath,
    thumbnailRelativePath,
    mimeType,
    byteSize,
    checksum,
    storageState,
    importMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('privacy_classification')) {
      context.handle(
        _privacyClassificationMeta,
        privacyClassification.isAcceptableOrUnknown(
          data['privacy_classification']!,
          _privacyClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyClassificationMeta);
    }
    if (data.containsKey('lifecycle')) {
      context.handle(
        _lifecycleMeta,
        lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta),
      );
    } else if (isInserting) {
      context.missing(_lifecycleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('evidence_id')) {
      context.handle(
        _evidenceIdMeta,
        evidenceId.isAcceptableOrUnknown(data['evidence_id']!, _evidenceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_evidenceIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_relative_path')) {
      context.handle(
        _thumbnailRelativePathMeta,
        thumbnailRelativePath.isAcceptableOrUnknown(
          data['thumbnail_relative_path']!,
          _thumbnailRelativePathMeta,
        ),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    }
    if (data.containsKey('storage_state')) {
      context.handle(
        _storageStateMeta,
        storageState.isAcceptableOrUnknown(
          data['storage_state']!,
          _storageStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storageStateMeta);
    }
    if (data.containsKey('import_mode')) {
      context.handle(
        _importModeMeta,
        importMode.isAcceptableOrUnknown(data['import_mode']!, _importModeMeta),
      );
    } else if (isInserting) {
      context.missing(_importModeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      privacyClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_classification'],
      )!,
      lifecycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      evidenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      ),
      thumbnailRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_relative_path'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      ),
      storageState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_state'],
      )!,
      importMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_mode'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String privacyClassification;
  final String lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String evidenceId;
  final String? displayName;
  final String? relativePath;
  final String? thumbnailRelativePath;
  final String mimeType;
  final int byteSize;
  final String? checksum;
  final String storageState;
  final String importMode;
  const Attachment({
    required this.id,
    required this.privacyClassification,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.evidenceId,
    this.displayName,
    this.relativePath,
    this.thumbnailRelativePath,
    required this.mimeType,
    required this.byteSize,
    this.checksum,
    required this.storageState,
    required this.importMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['privacy_classification'] = Variable<String>(privacyClassification);
    map['lifecycle'] = Variable<String>(lifecycle);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['evidence_id'] = Variable<String>(evidenceId);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || relativePath != null) {
      map['relative_path'] = Variable<String>(relativePath);
    }
    if (!nullToAbsent || thumbnailRelativePath != null) {
      map['thumbnail_relative_path'] = Variable<String>(thumbnailRelativePath);
    }
    map['mime_type'] = Variable<String>(mimeType);
    map['byte_size'] = Variable<int>(byteSize);
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    map['storage_state'] = Variable<String>(storageState);
    map['import_mode'] = Variable<String>(importMode);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      privacyClassification: Value(privacyClassification),
      lifecycle: Value(lifecycle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      evidenceId: Value(evidenceId),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      relativePath: relativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(relativePath),
      thumbnailRelativePath: thumbnailRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailRelativePath),
      mimeType: Value(mimeType),
      byteSize: Value(byteSize),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      storageState: Value(storageState),
      importMode: Value(importMode),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      privacyClassification: serializer.fromJson<String>(
        json['privacyClassification'],
      ),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      evidenceId: serializer.fromJson<String>(json['evidenceId']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      relativePath: serializer.fromJson<String?>(json['relativePath']),
      thumbnailRelativePath: serializer.fromJson<String?>(
        json['thumbnailRelativePath'],
      ),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      storageState: serializer.fromJson<String>(json['storageState']),
      importMode: serializer.fromJson<String>(json['importMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'privacyClassification': serializer.toJson<String>(privacyClassification),
      'lifecycle': serializer.toJson<String>(lifecycle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'evidenceId': serializer.toJson<String>(evidenceId),
      'displayName': serializer.toJson<String?>(displayName),
      'relativePath': serializer.toJson<String?>(relativePath),
      'thumbnailRelativePath': serializer.toJson<String?>(
        thumbnailRelativePath,
      ),
      'mimeType': serializer.toJson<String>(mimeType),
      'byteSize': serializer.toJson<int>(byteSize),
      'checksum': serializer.toJson<String?>(checksum),
      'storageState': serializer.toJson<String>(storageState),
      'importMode': serializer.toJson<String>(importMode),
    };
  }

  Attachment copyWith({
    String? id,
    String? privacyClassification,
    String? lifecycle,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? evidenceId,
    Value<String?> displayName = const Value.absent(),
    Value<String?> relativePath = const Value.absent(),
    Value<String?> thumbnailRelativePath = const Value.absent(),
    String? mimeType,
    int? byteSize,
    Value<String?> checksum = const Value.absent(),
    String? storageState,
    String? importMode,
  }) => Attachment(
    id: id ?? this.id,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    lifecycle: lifecycle ?? this.lifecycle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    evidenceId: evidenceId ?? this.evidenceId,
    displayName: displayName.present ? displayName.value : this.displayName,
    relativePath: relativePath.present ? relativePath.value : this.relativePath,
    thumbnailRelativePath: thumbnailRelativePath.present
        ? thumbnailRelativePath.value
        : this.thumbnailRelativePath,
    mimeType: mimeType ?? this.mimeType,
    byteSize: byteSize ?? this.byteSize,
    checksum: checksum.present ? checksum.value : this.checksum,
    storageState: storageState ?? this.storageState,
    importMode: importMode ?? this.importMode,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      privacyClassification: data.privacyClassification.present
          ? data.privacyClassification.value
          : this.privacyClassification,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      evidenceId: data.evidenceId.present
          ? data.evidenceId.value
          : this.evidenceId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      thumbnailRelativePath: data.thumbnailRelativePath.present
          ? data.thumbnailRelativePath.value
          : this.thumbnailRelativePath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      storageState: data.storageState.present
          ? data.storageState.value
          : this.storageState,
      importMode: data.importMode.present
          ? data.importMode.value
          : this.importMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('evidenceId: $evidenceId, ')
          ..write('displayName: $displayName, ')
          ..write('relativePath: $relativePath, ')
          ..write('thumbnailRelativePath: $thumbnailRelativePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('checksum: $checksum, ')
          ..write('storageState: $storageState, ')
          ..write('importMode: $importMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    evidenceId,
    displayName,
    relativePath,
    thumbnailRelativePath,
    mimeType,
    byteSize,
    checksum,
    storageState,
    importMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.privacyClassification == this.privacyClassification &&
          other.lifecycle == this.lifecycle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.evidenceId == this.evidenceId &&
          other.displayName == this.displayName &&
          other.relativePath == this.relativePath &&
          other.thumbnailRelativePath == this.thumbnailRelativePath &&
          other.mimeType == this.mimeType &&
          other.byteSize == this.byteSize &&
          other.checksum == this.checksum &&
          other.storageState == this.storageState &&
          other.importMode == this.importMode);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> privacyClassification;
  final Value<String> lifecycle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> evidenceId;
  final Value<String?> displayName;
  final Value<String?> relativePath;
  final Value<String?> thumbnailRelativePath;
  final Value<String> mimeType;
  final Value<int> byteSize;
  final Value<String?> checksum;
  final Value<String> storageState;
  final Value<String> importMode;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.privacyClassification = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.evidenceId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.thumbnailRelativePath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.checksum = const Value.absent(),
    this.storageState = const Value.absent(),
    this.importMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String privacyClassification,
    required String lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String evidenceId,
    this.displayName = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.thumbnailRelativePath = const Value.absent(),
    required String mimeType,
    required int byteSize,
    this.checksum = const Value.absent(),
    required String storageState,
    required String importMode,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       privacyClassification = Value(privacyClassification),
       lifecycle = Value(lifecycle),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       evidenceId = Value(evidenceId),
       mimeType = Value(mimeType),
       byteSize = Value(byteSize),
       storageState = Value(storageState),
       importMode = Value(importMode);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? privacyClassification,
    Expression<String>? lifecycle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? evidenceId,
    Expression<String>? displayName,
    Expression<String>? relativePath,
    Expression<String>? thumbnailRelativePath,
    Expression<String>? mimeType,
    Expression<int>? byteSize,
    Expression<String>? checksum,
    Expression<String>? storageState,
    Expression<String>? importMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (privacyClassification != null)
        'privacy_classification': privacyClassification,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (evidenceId != null) 'evidence_id': evidenceId,
      if (displayName != null) 'display_name': displayName,
      if (relativePath != null) 'relative_path': relativePath,
      if (thumbnailRelativePath != null)
        'thumbnail_relative_path': thumbnailRelativePath,
      if (mimeType != null) 'mime_type': mimeType,
      if (byteSize != null) 'byte_size': byteSize,
      if (checksum != null) 'checksum': checksum,
      if (storageState != null) 'storage_state': storageState,
      if (importMode != null) 'import_mode': importMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? privacyClassification,
    Value<String>? lifecycle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? evidenceId,
    Value<String?>? displayName,
    Value<String?>? relativePath,
    Value<String?>? thumbnailRelativePath,
    Value<String>? mimeType,
    Value<int>? byteSize,
    Value<String?>? checksum,
    Value<String>? storageState,
    Value<String>? importMode,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      privacyClassification:
          privacyClassification ?? this.privacyClassification,
      lifecycle: lifecycle ?? this.lifecycle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      evidenceId: evidenceId ?? this.evidenceId,
      displayName: displayName ?? this.displayName,
      relativePath: relativePath ?? this.relativePath,
      thumbnailRelativePath:
          thumbnailRelativePath ?? this.thumbnailRelativePath,
      mimeType: mimeType ?? this.mimeType,
      byteSize: byteSize ?? this.byteSize,
      checksum: checksum ?? this.checksum,
      storageState: storageState ?? this.storageState,
      importMode: importMode ?? this.importMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (privacyClassification.present) {
      map['privacy_classification'] = Variable<String>(
        privacyClassification.value,
      );
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (evidenceId.present) {
      map['evidence_id'] = Variable<String>(evidenceId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (thumbnailRelativePath.present) {
      map['thumbnail_relative_path'] = Variable<String>(
        thumbnailRelativePath.value,
      );
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (storageState.present) {
      map['storage_state'] = Variable<String>(storageState.value);
    }
    if (importMode.present) {
      map['import_mode'] = Variable<String>(importMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('evidenceId: $evidenceId, ')
          ..write('displayName: $displayName, ')
          ..write('relativePath: $relativePath, ')
          ..write('thumbnailRelativePath: $thumbnailRelativePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('checksum: $checksum, ')
          ..write('storageState: $storageState, ')
          ..write('importMode: $importMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryCandidatesTable extends MemoryCandidates
    with TableInfo<$MemoryCandidatesTable, MemoryCandidate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryCandidatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyClassificationMeta =
      const VerificationMeta('privacyClassification');
  @override
  late final GeneratedColumn<String> privacyClassification =
      GeneratedColumn<String>(
        'privacy_classification',
        aliasedName,
        false,
        check: () => privacyClassification.isIn(SchemaValues.privacy),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lifecycleMeta = const VerificationMeta(
    'lifecycle',
  );
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
    'lifecycle',
    aliasedName,
    false,
    check: () => lifecycle.isIn(SchemaValues.lifecycle),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temporalPrecisionMeta = const VerificationMeta(
    'temporalPrecision',
  );
  @override
  late final GeneratedColumn<String> temporalPrecision =
      GeneratedColumn<String>(
        'temporal_precision',
        aliasedName,
        false,
        check: () => temporalPrecision.isIn(SchemaValues.temporalPrecision),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _startYearMeta = const VerificationMeta(
    'startYear',
  );
  @override
  late final GeneratedColumn<int> startYear = GeneratedColumn<int>(
    'start_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMonthMeta = const VerificationMeta(
    'startMonth',
  );
  @override
  late final GeneratedColumn<int> startMonth = GeneratedColumn<int>(
    'start_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDayMeta = const VerificationMeta(
    'startDay',
  );
  @override
  late final GeneratedColumn<int> startDay = GeneratedColumn<int>(
    'start_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endYearMeta = const VerificationMeta(
    'endYear',
  );
  @override
  late final GeneratedColumn<int> endYear = GeneratedColumn<int>(
    'end_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMonthMeta = const VerificationMeta(
    'endMonth',
  );
  @override
  late final GeneratedColumn<int> endMonth = GeneratedColumn<int>(
    'end_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDayMeta = const VerificationMeta('endDay');
  @override
  late final GeneratedColumn<int> endDay = GeneratedColumn<int>(
    'end_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceEvidenceIdMeta = const VerificationMeta(
    'sourceEvidenceId',
  );
  @override
  late final GeneratedColumn<String> sourceEvidenceId = GeneratedColumn<String>(
    'source_evidence_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES evidence (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _confirmedEventIdMeta = const VerificationMeta(
    'confirmedEventId',
  );
  @override
  late final GeneratedColumn<String> confirmedEventId = GeneratedColumn<String>(
    'confirmed_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _documentTypeMeta = const VerificationMeta(
    'documentType',
  );
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
    'document_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _overallConfidenceMeta = const VerificationMeta(
    'overallConfidence',
  );
  @override
  late final GeneratedColumn<double> overallConfidence =
      GeneratedColumn<double>(
        'overall_confidence',
        aliasedName,
        true,
        check: () =>
            overallConfidence.isNull() |
            (ComparableExpr(overallConfidence).isBiggerOrEqualValue(0) &
                ComparableExpr(overallConfidence).isSmallerOrEqualValue(1)),
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _possibleDuplicateEventIdMeta =
      const VerificationMeta('possibleDuplicateEventId');
  @override
  late final GeneratedColumn<String> possibleDuplicateEventId =
      GeneratedColumn<String>(
        'possible_duplicate_event_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES events (id) ON DELETE SET NULL',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    temporalPrecision,
    startYear,
    startMonth,
    startDay,
    endYear,
    endMonth,
    endDay,
    title,
    description,
    sourceEvidenceId,
    confirmedEventId,
    documentType,
    reviewStatus,
    overallConfidence,
    possibleDuplicateEventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_candidates';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryCandidate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('privacy_classification')) {
      context.handle(
        _privacyClassificationMeta,
        privacyClassification.isAcceptableOrUnknown(
          data['privacy_classification']!,
          _privacyClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyClassificationMeta);
    }
    if (data.containsKey('lifecycle')) {
      context.handle(
        _lifecycleMeta,
        lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta),
      );
    } else if (isInserting) {
      context.missing(_lifecycleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('temporal_precision')) {
      context.handle(
        _temporalPrecisionMeta,
        temporalPrecision.isAcceptableOrUnknown(
          data['temporal_precision']!,
          _temporalPrecisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temporalPrecisionMeta);
    }
    if (data.containsKey('start_year')) {
      context.handle(
        _startYearMeta,
        startYear.isAcceptableOrUnknown(data['start_year']!, _startYearMeta),
      );
    }
    if (data.containsKey('start_month')) {
      context.handle(
        _startMonthMeta,
        startMonth.isAcceptableOrUnknown(data['start_month']!, _startMonthMeta),
      );
    }
    if (data.containsKey('start_day')) {
      context.handle(
        _startDayMeta,
        startDay.isAcceptableOrUnknown(data['start_day']!, _startDayMeta),
      );
    }
    if (data.containsKey('end_year')) {
      context.handle(
        _endYearMeta,
        endYear.isAcceptableOrUnknown(data['end_year']!, _endYearMeta),
      );
    }
    if (data.containsKey('end_month')) {
      context.handle(
        _endMonthMeta,
        endMonth.isAcceptableOrUnknown(data['end_month']!, _endMonthMeta),
      );
    }
    if (data.containsKey('end_day')) {
      context.handle(
        _endDayMeta,
        endDay.isAcceptableOrUnknown(data['end_day']!, _endDayMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('source_evidence_id')) {
      context.handle(
        _sourceEvidenceIdMeta,
        sourceEvidenceId.isAcceptableOrUnknown(
          data['source_evidence_id']!,
          _sourceEvidenceIdMeta,
        ),
      );
    }
    if (data.containsKey('confirmed_event_id')) {
      context.handle(
        _confirmedEventIdMeta,
        confirmedEventId.isAcceptableOrUnknown(
          data['confirmed_event_id']!,
          _confirmedEventIdMeta,
        ),
      );
    }
    if (data.containsKey('document_type')) {
      context.handle(
        _documentTypeMeta,
        documentType.isAcceptableOrUnknown(
          data['document_type']!,
          _documentTypeMeta,
        ),
      );
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    }
    if (data.containsKey('overall_confidence')) {
      context.handle(
        _overallConfidenceMeta,
        overallConfidence.isAcceptableOrUnknown(
          data['overall_confidence']!,
          _overallConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('possible_duplicate_event_id')) {
      context.handle(
        _possibleDuplicateEventIdMeta,
        possibleDuplicateEventId.isAcceptableOrUnknown(
          data['possible_duplicate_event_id']!,
          _possibleDuplicateEventIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoryCandidate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryCandidate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      privacyClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_classification'],
      )!,
      lifecycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      temporalPrecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temporal_precision'],
      )!,
      startYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_year'],
      ),
      startMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_month'],
      ),
      startDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_day'],
      ),
      endYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_year'],
      ),
      endMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_month'],
      ),
      endDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_day'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sourceEvidenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_evidence_id'],
      ),
      confirmedEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confirmed_event_id'],
      ),
      documentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_type'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      overallConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_confidence'],
      ),
      possibleDuplicateEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}possible_duplicate_event_id'],
      ),
    );
  }

  @override
  $MemoryCandidatesTable createAlias(String alias) {
    return $MemoryCandidatesTable(attachedDatabase, alias);
  }
}

class MemoryCandidate extends DataClass implements Insertable<MemoryCandidate> {
  final String id;
  final String privacyClassification;
  final String lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String temporalPrecision;
  final int? startYear;
  final int? startMonth;
  final int? startDay;
  final int? endYear;
  final int? endMonth;
  final int? endDay;
  final String title;
  final String? description;
  final String? sourceEvidenceId;
  final String? confirmedEventId;
  final String documentType;
  final String reviewStatus;
  final double? overallConfidence;
  final String? possibleDuplicateEventId;
  const MemoryCandidate({
    required this.id,
    required this.privacyClassification,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.temporalPrecision,
    this.startYear,
    this.startMonth,
    this.startDay,
    this.endYear,
    this.endMonth,
    this.endDay,
    required this.title,
    this.description,
    this.sourceEvidenceId,
    this.confirmedEventId,
    required this.documentType,
    required this.reviewStatus,
    this.overallConfidence,
    this.possibleDuplicateEventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['privacy_classification'] = Variable<String>(privacyClassification);
    map['lifecycle'] = Variable<String>(lifecycle);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['temporal_precision'] = Variable<String>(temporalPrecision);
    if (!nullToAbsent || startYear != null) {
      map['start_year'] = Variable<int>(startYear);
    }
    if (!nullToAbsent || startMonth != null) {
      map['start_month'] = Variable<int>(startMonth);
    }
    if (!nullToAbsent || startDay != null) {
      map['start_day'] = Variable<int>(startDay);
    }
    if (!nullToAbsent || endYear != null) {
      map['end_year'] = Variable<int>(endYear);
    }
    if (!nullToAbsent || endMonth != null) {
      map['end_month'] = Variable<int>(endMonth);
    }
    if (!nullToAbsent || endDay != null) {
      map['end_day'] = Variable<int>(endDay);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || sourceEvidenceId != null) {
      map['source_evidence_id'] = Variable<String>(sourceEvidenceId);
    }
    if (!nullToAbsent || confirmedEventId != null) {
      map['confirmed_event_id'] = Variable<String>(confirmedEventId);
    }
    map['document_type'] = Variable<String>(documentType);
    map['review_status'] = Variable<String>(reviewStatus);
    if (!nullToAbsent || overallConfidence != null) {
      map['overall_confidence'] = Variable<double>(overallConfidence);
    }
    if (!nullToAbsent || possibleDuplicateEventId != null) {
      map['possible_duplicate_event_id'] = Variable<String>(
        possibleDuplicateEventId,
      );
    }
    return map;
  }

  MemoryCandidatesCompanion toCompanion(bool nullToAbsent) {
    return MemoryCandidatesCompanion(
      id: Value(id),
      privacyClassification: Value(privacyClassification),
      lifecycle: Value(lifecycle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      temporalPrecision: Value(temporalPrecision),
      startYear: startYear == null && nullToAbsent
          ? const Value.absent()
          : Value(startYear),
      startMonth: startMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(startMonth),
      startDay: startDay == null && nullToAbsent
          ? const Value.absent()
          : Value(startDay),
      endYear: endYear == null && nullToAbsent
          ? const Value.absent()
          : Value(endYear),
      endMonth: endMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(endMonth),
      endDay: endDay == null && nullToAbsent
          ? const Value.absent()
          : Value(endDay),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sourceEvidenceId: sourceEvidenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEvidenceId),
      confirmedEventId: confirmedEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedEventId),
      documentType: Value(documentType),
      reviewStatus: Value(reviewStatus),
      overallConfidence: overallConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(overallConfidence),
      possibleDuplicateEventId: possibleDuplicateEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(possibleDuplicateEventId),
    );
  }

  factory MemoryCandidate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryCandidate(
      id: serializer.fromJson<String>(json['id']),
      privacyClassification: serializer.fromJson<String>(
        json['privacyClassification'],
      ),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      temporalPrecision: serializer.fromJson<String>(json['temporalPrecision']),
      startYear: serializer.fromJson<int?>(json['startYear']),
      startMonth: serializer.fromJson<int?>(json['startMonth']),
      startDay: serializer.fromJson<int?>(json['startDay']),
      endYear: serializer.fromJson<int?>(json['endYear']),
      endMonth: serializer.fromJson<int?>(json['endMonth']),
      endDay: serializer.fromJson<int?>(json['endDay']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      sourceEvidenceId: serializer.fromJson<String?>(json['sourceEvidenceId']),
      confirmedEventId: serializer.fromJson<String?>(json['confirmedEventId']),
      documentType: serializer.fromJson<String>(json['documentType']),
      reviewStatus: serializer.fromJson<String>(json['reviewStatus']),
      overallConfidence: serializer.fromJson<double?>(
        json['overallConfidence'],
      ),
      possibleDuplicateEventId: serializer.fromJson<String?>(
        json['possibleDuplicateEventId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'privacyClassification': serializer.toJson<String>(privacyClassification),
      'lifecycle': serializer.toJson<String>(lifecycle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'temporalPrecision': serializer.toJson<String>(temporalPrecision),
      'startYear': serializer.toJson<int?>(startYear),
      'startMonth': serializer.toJson<int?>(startMonth),
      'startDay': serializer.toJson<int?>(startDay),
      'endYear': serializer.toJson<int?>(endYear),
      'endMonth': serializer.toJson<int?>(endMonth),
      'endDay': serializer.toJson<int?>(endDay),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'sourceEvidenceId': serializer.toJson<String?>(sourceEvidenceId),
      'confirmedEventId': serializer.toJson<String?>(confirmedEventId),
      'documentType': serializer.toJson<String>(documentType),
      'reviewStatus': serializer.toJson<String>(reviewStatus),
      'overallConfidence': serializer.toJson<double?>(overallConfidence),
      'possibleDuplicateEventId': serializer.toJson<String?>(
        possibleDuplicateEventId,
      ),
    };
  }

  MemoryCandidate copyWith({
    String? id,
    String? privacyClassification,
    String? lifecycle,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? temporalPrecision,
    Value<int?> startYear = const Value.absent(),
    Value<int?> startMonth = const Value.absent(),
    Value<int?> startDay = const Value.absent(),
    Value<int?> endYear = const Value.absent(),
    Value<int?> endMonth = const Value.absent(),
    Value<int?> endDay = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> sourceEvidenceId = const Value.absent(),
    Value<String?> confirmedEventId = const Value.absent(),
    String? documentType,
    String? reviewStatus,
    Value<double?> overallConfidence = const Value.absent(),
    Value<String?> possibleDuplicateEventId = const Value.absent(),
  }) => MemoryCandidate(
    id: id ?? this.id,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    lifecycle: lifecycle ?? this.lifecycle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    temporalPrecision: temporalPrecision ?? this.temporalPrecision,
    startYear: startYear.present ? startYear.value : this.startYear,
    startMonth: startMonth.present ? startMonth.value : this.startMonth,
    startDay: startDay.present ? startDay.value : this.startDay,
    endYear: endYear.present ? endYear.value : this.endYear,
    endMonth: endMonth.present ? endMonth.value : this.endMonth,
    endDay: endDay.present ? endDay.value : this.endDay,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    sourceEvidenceId: sourceEvidenceId.present
        ? sourceEvidenceId.value
        : this.sourceEvidenceId,
    confirmedEventId: confirmedEventId.present
        ? confirmedEventId.value
        : this.confirmedEventId,
    documentType: documentType ?? this.documentType,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    overallConfidence: overallConfidence.present
        ? overallConfidence.value
        : this.overallConfidence,
    possibleDuplicateEventId: possibleDuplicateEventId.present
        ? possibleDuplicateEventId.value
        : this.possibleDuplicateEventId,
  );
  MemoryCandidate copyWithCompanion(MemoryCandidatesCompanion data) {
    return MemoryCandidate(
      id: data.id.present ? data.id.value : this.id,
      privacyClassification: data.privacyClassification.present
          ? data.privacyClassification.value
          : this.privacyClassification,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      temporalPrecision: data.temporalPrecision.present
          ? data.temporalPrecision.value
          : this.temporalPrecision,
      startYear: data.startYear.present ? data.startYear.value : this.startYear,
      startMonth: data.startMonth.present
          ? data.startMonth.value
          : this.startMonth,
      startDay: data.startDay.present ? data.startDay.value : this.startDay,
      endYear: data.endYear.present ? data.endYear.value : this.endYear,
      endMonth: data.endMonth.present ? data.endMonth.value : this.endMonth,
      endDay: data.endDay.present ? data.endDay.value : this.endDay,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      sourceEvidenceId: data.sourceEvidenceId.present
          ? data.sourceEvidenceId.value
          : this.sourceEvidenceId,
      confirmedEventId: data.confirmedEventId.present
          ? data.confirmedEventId.value
          : this.confirmedEventId,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      overallConfidence: data.overallConfidence.present
          ? data.overallConfidence.value
          : this.overallConfidence,
      possibleDuplicateEventId: data.possibleDuplicateEventId.present
          ? data.possibleDuplicateEventId.value
          : this.possibleDuplicateEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryCandidate(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('temporalPrecision: $temporalPrecision, ')
          ..write('startYear: $startYear, ')
          ..write('startMonth: $startMonth, ')
          ..write('startDay: $startDay, ')
          ..write('endYear: $endYear, ')
          ..write('endMonth: $endMonth, ')
          ..write('endDay: $endDay, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('sourceEvidenceId: $sourceEvidenceId, ')
          ..write('confirmedEventId: $confirmedEventId, ')
          ..write('documentType: $documentType, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('overallConfidence: $overallConfidence, ')
          ..write('possibleDuplicateEventId: $possibleDuplicateEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    temporalPrecision,
    startYear,
    startMonth,
    startDay,
    endYear,
    endMonth,
    endDay,
    title,
    description,
    sourceEvidenceId,
    confirmedEventId,
    documentType,
    reviewStatus,
    overallConfidence,
    possibleDuplicateEventId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryCandidate &&
          other.id == this.id &&
          other.privacyClassification == this.privacyClassification &&
          other.lifecycle == this.lifecycle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.temporalPrecision == this.temporalPrecision &&
          other.startYear == this.startYear &&
          other.startMonth == this.startMonth &&
          other.startDay == this.startDay &&
          other.endYear == this.endYear &&
          other.endMonth == this.endMonth &&
          other.endDay == this.endDay &&
          other.title == this.title &&
          other.description == this.description &&
          other.sourceEvidenceId == this.sourceEvidenceId &&
          other.confirmedEventId == this.confirmedEventId &&
          other.documentType == this.documentType &&
          other.reviewStatus == this.reviewStatus &&
          other.overallConfidence == this.overallConfidence &&
          other.possibleDuplicateEventId == this.possibleDuplicateEventId);
}

class MemoryCandidatesCompanion extends UpdateCompanion<MemoryCandidate> {
  final Value<String> id;
  final Value<String> privacyClassification;
  final Value<String> lifecycle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> temporalPrecision;
  final Value<int?> startYear;
  final Value<int?> startMonth;
  final Value<int?> startDay;
  final Value<int?> endYear;
  final Value<int?> endMonth;
  final Value<int?> endDay;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> sourceEvidenceId;
  final Value<String?> confirmedEventId;
  final Value<String> documentType;
  final Value<String> reviewStatus;
  final Value<double?> overallConfidence;
  final Value<String?> possibleDuplicateEventId;
  final Value<int> rowid;
  const MemoryCandidatesCompanion({
    this.id = const Value.absent(),
    this.privacyClassification = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.temporalPrecision = const Value.absent(),
    this.startYear = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endYear = const Value.absent(),
    this.endMonth = const Value.absent(),
    this.endDay = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.sourceEvidenceId = const Value.absent(),
    this.confirmedEventId = const Value.absent(),
    this.documentType = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.overallConfidence = const Value.absent(),
    this.possibleDuplicateEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryCandidatesCompanion.insert({
    required String id,
    required String privacyClassification,
    required String lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String temporalPrecision,
    this.startYear = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endYear = const Value.absent(),
    this.endMonth = const Value.absent(),
    this.endDay = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.sourceEvidenceId = const Value.absent(),
    this.confirmedEventId = const Value.absent(),
    this.documentType = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.overallConfidence = const Value.absent(),
    this.possibleDuplicateEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       privacyClassification = Value(privacyClassification),
       lifecycle = Value(lifecycle),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       temporalPrecision = Value(temporalPrecision),
       title = Value(title);
  static Insertable<MemoryCandidate> custom({
    Expression<String>? id,
    Expression<String>? privacyClassification,
    Expression<String>? lifecycle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? temporalPrecision,
    Expression<int>? startYear,
    Expression<int>? startMonth,
    Expression<int>? startDay,
    Expression<int>? endYear,
    Expression<int>? endMonth,
    Expression<int>? endDay,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? sourceEvidenceId,
    Expression<String>? confirmedEventId,
    Expression<String>? documentType,
    Expression<String>? reviewStatus,
    Expression<double>? overallConfidence,
    Expression<String>? possibleDuplicateEventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (privacyClassification != null)
        'privacy_classification': privacyClassification,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (temporalPrecision != null) 'temporal_precision': temporalPrecision,
      if (startYear != null) 'start_year': startYear,
      if (startMonth != null) 'start_month': startMonth,
      if (startDay != null) 'start_day': startDay,
      if (endYear != null) 'end_year': endYear,
      if (endMonth != null) 'end_month': endMonth,
      if (endDay != null) 'end_day': endDay,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (sourceEvidenceId != null) 'source_evidence_id': sourceEvidenceId,
      if (confirmedEventId != null) 'confirmed_event_id': confirmedEventId,
      if (documentType != null) 'document_type': documentType,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (overallConfidence != null) 'overall_confidence': overallConfidence,
      if (possibleDuplicateEventId != null)
        'possible_duplicate_event_id': possibleDuplicateEventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryCandidatesCompanion copyWith({
    Value<String>? id,
    Value<String>? privacyClassification,
    Value<String>? lifecycle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? temporalPrecision,
    Value<int?>? startYear,
    Value<int?>? startMonth,
    Value<int?>? startDay,
    Value<int?>? endYear,
    Value<int?>? endMonth,
    Value<int?>? endDay,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? sourceEvidenceId,
    Value<String?>? confirmedEventId,
    Value<String>? documentType,
    Value<String>? reviewStatus,
    Value<double?>? overallConfidence,
    Value<String?>? possibleDuplicateEventId,
    Value<int>? rowid,
  }) {
    return MemoryCandidatesCompanion(
      id: id ?? this.id,
      privacyClassification:
          privacyClassification ?? this.privacyClassification,
      lifecycle: lifecycle ?? this.lifecycle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      temporalPrecision: temporalPrecision ?? this.temporalPrecision,
      startYear: startYear ?? this.startYear,
      startMonth: startMonth ?? this.startMonth,
      startDay: startDay ?? this.startDay,
      endYear: endYear ?? this.endYear,
      endMonth: endMonth ?? this.endMonth,
      endDay: endDay ?? this.endDay,
      title: title ?? this.title,
      description: description ?? this.description,
      sourceEvidenceId: sourceEvidenceId ?? this.sourceEvidenceId,
      confirmedEventId: confirmedEventId ?? this.confirmedEventId,
      documentType: documentType ?? this.documentType,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      possibleDuplicateEventId:
          possibleDuplicateEventId ?? this.possibleDuplicateEventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (privacyClassification.present) {
      map['privacy_classification'] = Variable<String>(
        privacyClassification.value,
      );
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (temporalPrecision.present) {
      map['temporal_precision'] = Variable<String>(temporalPrecision.value);
    }
    if (startYear.present) {
      map['start_year'] = Variable<int>(startYear.value);
    }
    if (startMonth.present) {
      map['start_month'] = Variable<int>(startMonth.value);
    }
    if (startDay.present) {
      map['start_day'] = Variable<int>(startDay.value);
    }
    if (endYear.present) {
      map['end_year'] = Variable<int>(endYear.value);
    }
    if (endMonth.present) {
      map['end_month'] = Variable<int>(endMonth.value);
    }
    if (endDay.present) {
      map['end_day'] = Variable<int>(endDay.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sourceEvidenceId.present) {
      map['source_evidence_id'] = Variable<String>(sourceEvidenceId.value);
    }
    if (confirmedEventId.present) {
      map['confirmed_event_id'] = Variable<String>(confirmedEventId.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (overallConfidence.present) {
      map['overall_confidence'] = Variable<double>(overallConfidence.value);
    }
    if (possibleDuplicateEventId.present) {
      map['possible_duplicate_event_id'] = Variable<String>(
        possibleDuplicateEventId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryCandidatesCompanion(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('temporalPrecision: $temporalPrecision, ')
          ..write('startYear: $startYear, ')
          ..write('startMonth: $startMonth, ')
          ..write('startDay: $startDay, ')
          ..write('endYear: $endYear, ')
          ..write('endMonth: $endMonth, ')
          ..write('endDay: $endDay, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('sourceEvidenceId: $sourceEvidenceId, ')
          ..write('confirmedEventId: $confirmedEventId, ')
          ..write('documentType: $documentType, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('overallConfidence: $overallConfidence, ')
          ..write('possibleDuplicateEventId: $possibleDuplicateEventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldProvenanceRowsTable extends FieldProvenanceRows
    with TableInfo<$FieldProvenanceRowsTable, FieldProvenanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldProvenanceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entities (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _evidenceIdMeta = const VerificationMeta(
    'evidenceId',
  );
  @override
  late final GeneratedColumn<String> evidenceId = GeneratedColumn<String>(
    'evidence_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES evidence (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relationshipIdMeta = const VerificationMeta(
    'relationshipId',
  );
  @override
  late final GeneratedColumn<String> relationshipId = GeneratedColumn<String>(
    'relationship_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES relationships (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
    'attachment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attachments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _memoryCandidateIdMeta = const VerificationMeta(
    'memoryCandidateId',
  );
  @override
  late final GeneratedColumn<String> memoryCandidateId =
      GeneratedColumn<String>(
        'memory_candidate_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES memory_candidates (id) ON DELETE CASCADE',
        ),
      );
  static const VerificationMeta _fieldNameMeta = const VerificationMeta(
    'fieldName',
  );
  @override
  late final GeneratedColumn<String> fieldName = GeneratedColumn<String>(
    'field_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    check: () => sourceType.isIn(const [
      'user',
      'attachment',
      'import',
      'system',
      'rule',
      'local_model',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extractionMethodMeta = const VerificationMeta(
    'extractionMethod',
  );
  @override
  late final GeneratedColumn<String> extractionMethod = GeneratedColumn<String>(
    'extraction_method',
    aliasedName,
    false,
    check: () => extractionMethod.isIn(const [
      'manual',
      'imported',
      'metadata',
      'deterministic',
      'ocr',
      'on_device_model',
      'unknown',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    check: () =>
        confidence.isNull() |
        (ComparableExpr(confidence).isBiggerOrEqualValue(0) &
            ComparableExpr(confidence).isSmallerOrEqualValue(1)),
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userConfirmedMeta = const VerificationMeta(
    'userConfirmed',
  );
  @override
  late final GeneratedColumn<bool> userConfirmed = GeneratedColumn<bool>(
    'user_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_confirmed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _privacyClassificationMeta =
      const VerificationMeta('privacyClassification');
  @override
  late final GeneratedColumn<String> privacyClassification =
      GeneratedColumn<String>(
        'privacy_classification',
        aliasedName,
        false,
        check: () => privacyClassification.isIn(SchemaValues.privacy),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityId,
    eventId,
    evidenceId,
    relationshipId,
    attachmentId,
    memoryCandidateId,
    fieldName,
    sourceId,
    sourceType,
    extractionMethod,
    confidence,
    userConfirmed,
    privacyClassification,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_provenance';
  @override
  VerificationContext validateIntegrity(
    Insertable<FieldProvenanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    }
    if (data.containsKey('evidence_id')) {
      context.handle(
        _evidenceIdMeta,
        evidenceId.isAcceptableOrUnknown(data['evidence_id']!, _evidenceIdMeta),
      );
    }
    if (data.containsKey('relationship_id')) {
      context.handle(
        _relationshipIdMeta,
        relationshipId.isAcceptableOrUnknown(
          data['relationship_id']!,
          _relationshipIdMeta,
        ),
      );
    }
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    }
    if (data.containsKey('memory_candidate_id')) {
      context.handle(
        _memoryCandidateIdMeta,
        memoryCandidateId.isAcceptableOrUnknown(
          data['memory_candidate_id']!,
          _memoryCandidateIdMeta,
        ),
      );
    }
    if (data.containsKey('field_name')) {
      context.handle(
        _fieldNameMeta,
        fieldName.isAcceptableOrUnknown(data['field_name']!, _fieldNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldNameMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('extraction_method')) {
      context.handle(
        _extractionMethodMeta,
        extractionMethod.isAcceptableOrUnknown(
          data['extraction_method']!,
          _extractionMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extractionMethodMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('user_confirmed')) {
      context.handle(
        _userConfirmedMeta,
        userConfirmed.isAcceptableOrUnknown(
          data['user_confirmed']!,
          _userConfirmedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userConfirmedMeta);
    }
    if (data.containsKey('privacy_classification')) {
      context.handle(
        _privacyClassificationMeta,
        privacyClassification.isAcceptableOrUnknown(
          data['privacy_classification']!,
          _privacyClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyClassificationMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FieldProvenanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldProvenanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      ),
      evidenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_id'],
      ),
      relationshipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_id'],
      ),
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_id'],
      ),
      memoryCandidateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_candidate_id'],
      ),
      fieldName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_name'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      extractionMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extraction_method'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      userConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_confirmed'],
      )!,
      privacyClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_classification'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FieldProvenanceRowsTable createAlias(String alias) {
    return $FieldProvenanceRowsTable(attachedDatabase, alias);
  }
}

class FieldProvenanceRow extends DataClass
    implements Insertable<FieldProvenanceRow> {
  final String id;
  final String? entityId;
  final String? eventId;
  final String? evidenceId;
  final String? relationshipId;
  final String? attachmentId;
  final String? memoryCandidateId;
  final String fieldName;
  final String sourceId;
  final String sourceType;
  final String extractionMethod;
  final double? confidence;
  final bool userConfirmed;
  final String privacyClassification;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FieldProvenanceRow({
    required this.id,
    this.entityId,
    this.eventId,
    this.evidenceId,
    this.relationshipId,
    this.attachmentId,
    this.memoryCandidateId,
    required this.fieldName,
    required this.sourceId,
    required this.sourceType,
    required this.extractionMethod,
    this.confidence,
    required this.userConfirmed,
    required this.privacyClassification,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<String>(eventId);
    }
    if (!nullToAbsent || evidenceId != null) {
      map['evidence_id'] = Variable<String>(evidenceId);
    }
    if (!nullToAbsent || relationshipId != null) {
      map['relationship_id'] = Variable<String>(relationshipId);
    }
    if (!nullToAbsent || attachmentId != null) {
      map['attachment_id'] = Variable<String>(attachmentId);
    }
    if (!nullToAbsent || memoryCandidateId != null) {
      map['memory_candidate_id'] = Variable<String>(memoryCandidateId);
    }
    map['field_name'] = Variable<String>(fieldName);
    map['source_id'] = Variable<String>(sourceId);
    map['source_type'] = Variable<String>(sourceType);
    map['extraction_method'] = Variable<String>(extractionMethod);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['user_confirmed'] = Variable<bool>(userConfirmed);
    map['privacy_classification'] = Variable<String>(privacyClassification);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FieldProvenanceRowsCompanion toCompanion(bool nullToAbsent) {
    return FieldProvenanceRowsCompanion(
      id: Value(id),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      evidenceId: evidenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(evidenceId),
      relationshipId: relationshipId == null && nullToAbsent
          ? const Value.absent()
          : Value(relationshipId),
      attachmentId: attachmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentId),
      memoryCandidateId: memoryCandidateId == null && nullToAbsent
          ? const Value.absent()
          : Value(memoryCandidateId),
      fieldName: Value(fieldName),
      sourceId: Value(sourceId),
      sourceType: Value(sourceType),
      extractionMethod: Value(extractionMethod),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      userConfirmed: Value(userConfirmed),
      privacyClassification: Value(privacyClassification),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FieldProvenanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldProvenanceRow(
      id: serializer.fromJson<String>(json['id']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      eventId: serializer.fromJson<String?>(json['eventId']),
      evidenceId: serializer.fromJson<String?>(json['evidenceId']),
      relationshipId: serializer.fromJson<String?>(json['relationshipId']),
      attachmentId: serializer.fromJson<String?>(json['attachmentId']),
      memoryCandidateId: serializer.fromJson<String?>(
        json['memoryCandidateId'],
      ),
      fieldName: serializer.fromJson<String>(json['fieldName']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      extractionMethod: serializer.fromJson<String>(json['extractionMethod']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      userConfirmed: serializer.fromJson<bool>(json['userConfirmed']),
      privacyClassification: serializer.fromJson<String>(
        json['privacyClassification'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityId': serializer.toJson<String?>(entityId),
      'eventId': serializer.toJson<String?>(eventId),
      'evidenceId': serializer.toJson<String?>(evidenceId),
      'relationshipId': serializer.toJson<String?>(relationshipId),
      'attachmentId': serializer.toJson<String?>(attachmentId),
      'memoryCandidateId': serializer.toJson<String?>(memoryCandidateId),
      'fieldName': serializer.toJson<String>(fieldName),
      'sourceId': serializer.toJson<String>(sourceId),
      'sourceType': serializer.toJson<String>(sourceType),
      'extractionMethod': serializer.toJson<String>(extractionMethod),
      'confidence': serializer.toJson<double?>(confidence),
      'userConfirmed': serializer.toJson<bool>(userConfirmed),
      'privacyClassification': serializer.toJson<String>(privacyClassification),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FieldProvenanceRow copyWith({
    String? id,
    Value<String?> entityId = const Value.absent(),
    Value<String?> eventId = const Value.absent(),
    Value<String?> evidenceId = const Value.absent(),
    Value<String?> relationshipId = const Value.absent(),
    Value<String?> attachmentId = const Value.absent(),
    Value<String?> memoryCandidateId = const Value.absent(),
    String? fieldName,
    String? sourceId,
    String? sourceType,
    String? extractionMethod,
    Value<double?> confidence = const Value.absent(),
    bool? userConfirmed,
    String? privacyClassification,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FieldProvenanceRow(
    id: id ?? this.id,
    entityId: entityId.present ? entityId.value : this.entityId,
    eventId: eventId.present ? eventId.value : this.eventId,
    evidenceId: evidenceId.present ? evidenceId.value : this.evidenceId,
    relationshipId: relationshipId.present
        ? relationshipId.value
        : this.relationshipId,
    attachmentId: attachmentId.present ? attachmentId.value : this.attachmentId,
    memoryCandidateId: memoryCandidateId.present
        ? memoryCandidateId.value
        : this.memoryCandidateId,
    fieldName: fieldName ?? this.fieldName,
    sourceId: sourceId ?? this.sourceId,
    sourceType: sourceType ?? this.sourceType,
    extractionMethod: extractionMethod ?? this.extractionMethod,
    confidence: confidence.present ? confidence.value : this.confidence,
    userConfirmed: userConfirmed ?? this.userConfirmed,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FieldProvenanceRow copyWithCompanion(FieldProvenanceRowsCompanion data) {
    return FieldProvenanceRow(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      evidenceId: data.evidenceId.present
          ? data.evidenceId.value
          : this.evidenceId,
      relationshipId: data.relationshipId.present
          ? data.relationshipId.value
          : this.relationshipId,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      memoryCandidateId: data.memoryCandidateId.present
          ? data.memoryCandidateId.value
          : this.memoryCandidateId,
      fieldName: data.fieldName.present ? data.fieldName.value : this.fieldName,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      extractionMethod: data.extractionMethod.present
          ? data.extractionMethod.value
          : this.extractionMethod,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      userConfirmed: data.userConfirmed.present
          ? data.userConfirmed.value
          : this.userConfirmed,
      privacyClassification: data.privacyClassification.present
          ? data.privacyClassification.value
          : this.privacyClassification,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldProvenanceRow(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('eventId: $eventId, ')
          ..write('evidenceId: $evidenceId, ')
          ..write('relationshipId: $relationshipId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('memoryCandidateId: $memoryCandidateId, ')
          ..write('fieldName: $fieldName, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceType: $sourceType, ')
          ..write('extractionMethod: $extractionMethod, ')
          ..write('confidence: $confidence, ')
          ..write('userConfirmed: $userConfirmed, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityId,
    eventId,
    evidenceId,
    relationshipId,
    attachmentId,
    memoryCandidateId,
    fieldName,
    sourceId,
    sourceType,
    extractionMethod,
    confidence,
    userConfirmed,
    privacyClassification,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldProvenanceRow &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.eventId == this.eventId &&
          other.evidenceId == this.evidenceId &&
          other.relationshipId == this.relationshipId &&
          other.attachmentId == this.attachmentId &&
          other.memoryCandidateId == this.memoryCandidateId &&
          other.fieldName == this.fieldName &&
          other.sourceId == this.sourceId &&
          other.sourceType == this.sourceType &&
          other.extractionMethod == this.extractionMethod &&
          other.confidence == this.confidence &&
          other.userConfirmed == this.userConfirmed &&
          other.privacyClassification == this.privacyClassification &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FieldProvenanceRowsCompanion extends UpdateCompanion<FieldProvenanceRow> {
  final Value<String> id;
  final Value<String?> entityId;
  final Value<String?> eventId;
  final Value<String?> evidenceId;
  final Value<String?> relationshipId;
  final Value<String?> attachmentId;
  final Value<String?> memoryCandidateId;
  final Value<String> fieldName;
  final Value<String> sourceId;
  final Value<String> sourceType;
  final Value<String> extractionMethod;
  final Value<double?> confidence;
  final Value<bool> userConfirmed;
  final Value<String> privacyClassification;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FieldProvenanceRowsCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.evidenceId = const Value.absent(),
    this.relationshipId = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.memoryCandidateId = const Value.absent(),
    this.fieldName = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.extractionMethod = const Value.absent(),
    this.confidence = const Value.absent(),
    this.userConfirmed = const Value.absent(),
    this.privacyClassification = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldProvenanceRowsCompanion.insert({
    required String id,
    this.entityId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.evidenceId = const Value.absent(),
    this.relationshipId = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.memoryCandidateId = const Value.absent(),
    required String fieldName,
    required String sourceId,
    required String sourceType,
    required String extractionMethod,
    this.confidence = const Value.absent(),
    required bool userConfirmed,
    required String privacyClassification,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fieldName = Value(fieldName),
       sourceId = Value(sourceId),
       sourceType = Value(sourceType),
       extractionMethod = Value(extractionMethod),
       userConfirmed = Value(userConfirmed),
       privacyClassification = Value(privacyClassification),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FieldProvenanceRow> custom({
    Expression<String>? id,
    Expression<String>? entityId,
    Expression<String>? eventId,
    Expression<String>? evidenceId,
    Expression<String>? relationshipId,
    Expression<String>? attachmentId,
    Expression<String>? memoryCandidateId,
    Expression<String>? fieldName,
    Expression<String>? sourceId,
    Expression<String>? sourceType,
    Expression<String>? extractionMethod,
    Expression<double>? confidence,
    Expression<bool>? userConfirmed,
    Expression<String>? privacyClassification,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (eventId != null) 'event_id': eventId,
      if (evidenceId != null) 'evidence_id': evidenceId,
      if (relationshipId != null) 'relationship_id': relationshipId,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (memoryCandidateId != null) 'memory_candidate_id': memoryCandidateId,
      if (fieldName != null) 'field_name': fieldName,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceType != null) 'source_type': sourceType,
      if (extractionMethod != null) 'extraction_method': extractionMethod,
      if (confidence != null) 'confidence': confidence,
      if (userConfirmed != null) 'user_confirmed': userConfirmed,
      if (privacyClassification != null)
        'privacy_classification': privacyClassification,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldProvenanceRowsCompanion copyWith({
    Value<String>? id,
    Value<String?>? entityId,
    Value<String?>? eventId,
    Value<String?>? evidenceId,
    Value<String?>? relationshipId,
    Value<String?>? attachmentId,
    Value<String?>? memoryCandidateId,
    Value<String>? fieldName,
    Value<String>? sourceId,
    Value<String>? sourceType,
    Value<String>? extractionMethod,
    Value<double?>? confidence,
    Value<bool>? userConfirmed,
    Value<String>? privacyClassification,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FieldProvenanceRowsCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      eventId: eventId ?? this.eventId,
      evidenceId: evidenceId ?? this.evidenceId,
      relationshipId: relationshipId ?? this.relationshipId,
      attachmentId: attachmentId ?? this.attachmentId,
      memoryCandidateId: memoryCandidateId ?? this.memoryCandidateId,
      fieldName: fieldName ?? this.fieldName,
      sourceId: sourceId ?? this.sourceId,
      sourceType: sourceType ?? this.sourceType,
      extractionMethod: extractionMethod ?? this.extractionMethod,
      confidence: confidence ?? this.confidence,
      userConfirmed: userConfirmed ?? this.userConfirmed,
      privacyClassification:
          privacyClassification ?? this.privacyClassification,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (evidenceId.present) {
      map['evidence_id'] = Variable<String>(evidenceId.value);
    }
    if (relationshipId.present) {
      map['relationship_id'] = Variable<String>(relationshipId.value);
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (memoryCandidateId.present) {
      map['memory_candidate_id'] = Variable<String>(memoryCandidateId.value);
    }
    if (fieldName.present) {
      map['field_name'] = Variable<String>(fieldName.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (extractionMethod.present) {
      map['extraction_method'] = Variable<String>(extractionMethod.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (userConfirmed.present) {
      map['user_confirmed'] = Variable<bool>(userConfirmed.value);
    }
    if (privacyClassification.present) {
      map['privacy_classification'] = Variable<String>(
        privacyClassification.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldProvenanceRowsCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('eventId: $eventId, ')
          ..write('evidenceId: $evidenceId, ')
          ..write('relationshipId: $relationshipId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('memoryCandidateId: $memoryCandidateId, ')
          ..write('fieldName: $fieldName, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceType: $sourceType, ')
          ..write('extractionMethod: $extractionMethod, ')
          ..write('confidence: $confidence, ')
          ..write('userConfirmed: $userConfirmed, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CandidateExtractedFieldsTable extends CandidateExtractedFields
    with TableInfo<$CandidateExtractedFieldsTable, CandidateExtractedField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CandidateExtractedFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _candidateIdMeta = const VerificationMeta(
    'candidateId',
  );
  @override
  late final GeneratedColumn<String> candidateId = GeneratedColumn<String>(
    'candidate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_candidates (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueTypeMeta = const VerificationMeta(
    'valueType',
  );
  @override
  late final GeneratedColumn<String> valueType = GeneratedColumn<String>(
    'value_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    check: () =>
        ComparableExpr(confidence).isBiggerOrEqualValue(0) &
        ComparableExpr(confidence).isSmallerOrEqualValue(1),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyClassificationMeta =
      const VerificationMeta('privacyClassification');
  @override
  late final GeneratedColumn<String> privacyClassification =
      GeneratedColumn<String>(
        'privacy_classification',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _extractionMethodMeta = const VerificationMeta(
    'extractionMethod',
  );
  @override
  late final GeneratedColumn<String> extractionMethod = GeneratedColumn<String>(
    'extraction_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceExcerptMeta = const VerificationMeta(
    'sourceExcerpt',
  );
  @override
  late final GeneratedColumn<String> sourceExcerpt = GeneratedColumn<String>(
    'source_excerpt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewRecommendedMeta = const VerificationMeta(
    'reviewRecommended',
  );
  @override
  late final GeneratedColumn<bool> reviewRecommended = GeneratedColumn<bool>(
    'review_recommended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("review_recommended" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    candidateId,
    key,
    value,
    valueType,
    confidence,
    privacyClassification,
    extractionMethod,
    sourceExcerpt,
    reviewRecommended,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'candidate_extracted_fields';
  @override
  VerificationContext validateIntegrity(
    Insertable<CandidateExtractedField> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('candidate_id')) {
      context.handle(
        _candidateIdMeta,
        candidateId.isAcceptableOrUnknown(
          data['candidate_id']!,
          _candidateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_candidateIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('value_type')) {
      context.handle(
        _valueTypeMeta,
        valueType.isAcceptableOrUnknown(data['value_type']!, _valueTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_valueTypeMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('privacy_classification')) {
      context.handle(
        _privacyClassificationMeta,
        privacyClassification.isAcceptableOrUnknown(
          data['privacy_classification']!,
          _privacyClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyClassificationMeta);
    }
    if (data.containsKey('extraction_method')) {
      context.handle(
        _extractionMethodMeta,
        extractionMethod.isAcceptableOrUnknown(
          data['extraction_method']!,
          _extractionMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extractionMethodMeta);
    }
    if (data.containsKey('source_excerpt')) {
      context.handle(
        _sourceExcerptMeta,
        sourceExcerpt.isAcceptableOrUnknown(
          data['source_excerpt']!,
          _sourceExcerptMeta,
        ),
      );
    }
    if (data.containsKey('review_recommended')) {
      context.handle(
        _reviewRecommendedMeta,
        reviewRecommended.isAcceptableOrUnknown(
          data['review_recommended']!,
          _reviewRecommendedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CandidateExtractedField map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CandidateExtractedField(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      candidateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      valueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_type'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      privacyClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_classification'],
      )!,
      extractionMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extraction_method'],
      )!,
      sourceExcerpt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_excerpt'],
      ),
      reviewRecommended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}review_recommended'],
      )!,
    );
  }

  @override
  $CandidateExtractedFieldsTable createAlias(String alias) {
    return $CandidateExtractedFieldsTable(attachedDatabase, alias);
  }
}

class CandidateExtractedField extends DataClass
    implements Insertable<CandidateExtractedField> {
  final String id;
  final String candidateId;
  final String key;
  final String value;
  final String valueType;
  final double confidence;
  final String privacyClassification;
  final String extractionMethod;
  final String? sourceExcerpt;
  final bool reviewRecommended;
  const CandidateExtractedField({
    required this.id,
    required this.candidateId,
    required this.key,
    required this.value,
    required this.valueType,
    required this.confidence,
    required this.privacyClassification,
    required this.extractionMethod,
    this.sourceExcerpt,
    required this.reviewRecommended,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['candidate_id'] = Variable<String>(candidateId);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['value_type'] = Variable<String>(valueType);
    map['confidence'] = Variable<double>(confidence);
    map['privacy_classification'] = Variable<String>(privacyClassification);
    map['extraction_method'] = Variable<String>(extractionMethod);
    if (!nullToAbsent || sourceExcerpt != null) {
      map['source_excerpt'] = Variable<String>(sourceExcerpt);
    }
    map['review_recommended'] = Variable<bool>(reviewRecommended);
    return map;
  }

  CandidateExtractedFieldsCompanion toCompanion(bool nullToAbsent) {
    return CandidateExtractedFieldsCompanion(
      id: Value(id),
      candidateId: Value(candidateId),
      key: Value(key),
      value: Value(value),
      valueType: Value(valueType),
      confidence: Value(confidence),
      privacyClassification: Value(privacyClassification),
      extractionMethod: Value(extractionMethod),
      sourceExcerpt: sourceExcerpt == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceExcerpt),
      reviewRecommended: Value(reviewRecommended),
    );
  }

  factory CandidateExtractedField.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CandidateExtractedField(
      id: serializer.fromJson<String>(json['id']),
      candidateId: serializer.fromJson<String>(json['candidateId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      valueType: serializer.fromJson<String>(json['valueType']),
      confidence: serializer.fromJson<double>(json['confidence']),
      privacyClassification: serializer.fromJson<String>(
        json['privacyClassification'],
      ),
      extractionMethod: serializer.fromJson<String>(json['extractionMethod']),
      sourceExcerpt: serializer.fromJson<String?>(json['sourceExcerpt']),
      reviewRecommended: serializer.fromJson<bool>(json['reviewRecommended']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'candidateId': serializer.toJson<String>(candidateId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'valueType': serializer.toJson<String>(valueType),
      'confidence': serializer.toJson<double>(confidence),
      'privacyClassification': serializer.toJson<String>(privacyClassification),
      'extractionMethod': serializer.toJson<String>(extractionMethod),
      'sourceExcerpt': serializer.toJson<String?>(sourceExcerpt),
      'reviewRecommended': serializer.toJson<bool>(reviewRecommended),
    };
  }

  CandidateExtractedField copyWith({
    String? id,
    String? candidateId,
    String? key,
    String? value,
    String? valueType,
    double? confidence,
    String? privacyClassification,
    String? extractionMethod,
    Value<String?> sourceExcerpt = const Value.absent(),
    bool? reviewRecommended,
  }) => CandidateExtractedField(
    id: id ?? this.id,
    candidateId: candidateId ?? this.candidateId,
    key: key ?? this.key,
    value: value ?? this.value,
    valueType: valueType ?? this.valueType,
    confidence: confidence ?? this.confidence,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    extractionMethod: extractionMethod ?? this.extractionMethod,
    sourceExcerpt: sourceExcerpt.present
        ? sourceExcerpt.value
        : this.sourceExcerpt,
    reviewRecommended: reviewRecommended ?? this.reviewRecommended,
  );
  CandidateExtractedField copyWithCompanion(
    CandidateExtractedFieldsCompanion data,
  ) {
    return CandidateExtractedField(
      id: data.id.present ? data.id.value : this.id,
      candidateId: data.candidateId.present
          ? data.candidateId.value
          : this.candidateId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      valueType: data.valueType.present ? data.valueType.value : this.valueType,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      privacyClassification: data.privacyClassification.present
          ? data.privacyClassification.value
          : this.privacyClassification,
      extractionMethod: data.extractionMethod.present
          ? data.extractionMethod.value
          : this.extractionMethod,
      sourceExcerpt: data.sourceExcerpt.present
          ? data.sourceExcerpt.value
          : this.sourceExcerpt,
      reviewRecommended: data.reviewRecommended.present
          ? data.reviewRecommended.value
          : this.reviewRecommended,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CandidateExtractedField(')
          ..write('id: $id, ')
          ..write('candidateId: $candidateId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('valueType: $valueType, ')
          ..write('confidence: $confidence, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('extractionMethod: $extractionMethod, ')
          ..write('sourceExcerpt: $sourceExcerpt, ')
          ..write('reviewRecommended: $reviewRecommended')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    candidateId,
    key,
    value,
    valueType,
    confidence,
    privacyClassification,
    extractionMethod,
    sourceExcerpt,
    reviewRecommended,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CandidateExtractedField &&
          other.id == this.id &&
          other.candidateId == this.candidateId &&
          other.key == this.key &&
          other.value == this.value &&
          other.valueType == this.valueType &&
          other.confidence == this.confidence &&
          other.privacyClassification == this.privacyClassification &&
          other.extractionMethod == this.extractionMethod &&
          other.sourceExcerpt == this.sourceExcerpt &&
          other.reviewRecommended == this.reviewRecommended);
}

class CandidateExtractedFieldsCompanion
    extends UpdateCompanion<CandidateExtractedField> {
  final Value<String> id;
  final Value<String> candidateId;
  final Value<String> key;
  final Value<String> value;
  final Value<String> valueType;
  final Value<double> confidence;
  final Value<String> privacyClassification;
  final Value<String> extractionMethod;
  final Value<String?> sourceExcerpt;
  final Value<bool> reviewRecommended;
  final Value<int> rowid;
  const CandidateExtractedFieldsCompanion({
    this.id = const Value.absent(),
    this.candidateId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.valueType = const Value.absent(),
    this.confidence = const Value.absent(),
    this.privacyClassification = const Value.absent(),
    this.extractionMethod = const Value.absent(),
    this.sourceExcerpt = const Value.absent(),
    this.reviewRecommended = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CandidateExtractedFieldsCompanion.insert({
    required String id,
    required String candidateId,
    required String key,
    required String value,
    required String valueType,
    required double confidence,
    required String privacyClassification,
    required String extractionMethod,
    this.sourceExcerpt = const Value.absent(),
    this.reviewRecommended = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       candidateId = Value(candidateId),
       key = Value(key),
       value = Value(value),
       valueType = Value(valueType),
       confidence = Value(confidence),
       privacyClassification = Value(privacyClassification),
       extractionMethod = Value(extractionMethod);
  static Insertable<CandidateExtractedField> custom({
    Expression<String>? id,
    Expression<String>? candidateId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? valueType,
    Expression<double>? confidence,
    Expression<String>? privacyClassification,
    Expression<String>? extractionMethod,
    Expression<String>? sourceExcerpt,
    Expression<bool>? reviewRecommended,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (candidateId != null) 'candidate_id': candidateId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (valueType != null) 'value_type': valueType,
      if (confidence != null) 'confidence': confidence,
      if (privacyClassification != null)
        'privacy_classification': privacyClassification,
      if (extractionMethod != null) 'extraction_method': extractionMethod,
      if (sourceExcerpt != null) 'source_excerpt': sourceExcerpt,
      if (reviewRecommended != null) 'review_recommended': reviewRecommended,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CandidateExtractedFieldsCompanion copyWith({
    Value<String>? id,
    Value<String>? candidateId,
    Value<String>? key,
    Value<String>? value,
    Value<String>? valueType,
    Value<double>? confidence,
    Value<String>? privacyClassification,
    Value<String>? extractionMethod,
    Value<String?>? sourceExcerpt,
    Value<bool>? reviewRecommended,
    Value<int>? rowid,
  }) {
    return CandidateExtractedFieldsCompanion(
      id: id ?? this.id,
      candidateId: candidateId ?? this.candidateId,
      key: key ?? this.key,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
      confidence: confidence ?? this.confidence,
      privacyClassification:
          privacyClassification ?? this.privacyClassification,
      extractionMethod: extractionMethod ?? this.extractionMethod,
      sourceExcerpt: sourceExcerpt ?? this.sourceExcerpt,
      reviewRecommended: reviewRecommended ?? this.reviewRecommended,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (candidateId.present) {
      map['candidate_id'] = Variable<String>(candidateId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (valueType.present) {
      map['value_type'] = Variable<String>(valueType.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (privacyClassification.present) {
      map['privacy_classification'] = Variable<String>(
        privacyClassification.value,
      );
    }
    if (extractionMethod.present) {
      map['extraction_method'] = Variable<String>(extractionMethod.value);
    }
    if (sourceExcerpt.present) {
      map['source_excerpt'] = Variable<String>(sourceExcerpt.value);
    }
    if (reviewRecommended.present) {
      map['review_recommended'] = Variable<bool>(reviewRecommended.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CandidateExtractedFieldsCompanion(')
          ..write('id: $id, ')
          ..write('candidateId: $candidateId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('valueType: $valueType, ')
          ..write('confidence: $confidence, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('extractionMethod: $extractionMethod, ')
          ..write('sourceExcerpt: $sourceExcerpt, ')
          ..write('reviewRecommended: $reviewRecommended, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CandidateEntityProposalsTable extends CandidateEntityProposals
    with TableInfo<$CandidateEntityProposalsTable, CandidateEntityProposal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CandidateEntityProposalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _candidateIdMeta = const VerificationMeta(
    'candidateId',
  );
  @override
  late final GeneratedColumn<String> candidateId = GeneratedColumn<String>(
    'candidate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_candidates (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialNumberMeta = const VerificationMeta(
    'serialNumber',
  );
  @override
  late final GeneratedColumn<String> serialNumber = GeneratedColumn<String>(
    'serial_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suggestedEntityIdMeta = const VerificationMeta(
    'suggestedEntityId',
  );
  @override
  late final GeneratedColumn<String> suggestedEntityId =
      GeneratedColumn<String>(
        'suggested_entity_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES entities (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _matchScoreMeta = const VerificationMeta(
    'matchScore',
  );
  @override
  late final GeneratedColumn<double> matchScore = GeneratedColumn<double>(
    'match_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchReasonsMeta = const VerificationMeta(
    'matchReasons',
  );
  @override
  late final GeneratedColumn<String> matchReasons = GeneratedColumn<String>(
    'match_reasons',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    candidateId,
    name,
    entityType,
    confidence,
    brand,
    model,
    serialNumber,
    suggestedEntityId,
    matchScore,
    matchReasons,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'candidate_entity_proposals';
  @override
  VerificationContext validateIntegrity(
    Insertable<CandidateEntityProposal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('candidate_id')) {
      context.handle(
        _candidateIdMeta,
        candidateId.isAcceptableOrUnknown(
          data['candidate_id']!,
          _candidateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_candidateIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('serial_number')) {
      context.handle(
        _serialNumberMeta,
        serialNumber.isAcceptableOrUnknown(
          data['serial_number']!,
          _serialNumberMeta,
        ),
      );
    }
    if (data.containsKey('suggested_entity_id')) {
      context.handle(
        _suggestedEntityIdMeta,
        suggestedEntityId.isAcceptableOrUnknown(
          data['suggested_entity_id']!,
          _suggestedEntityIdMeta,
        ),
      );
    }
    if (data.containsKey('match_score')) {
      context.handle(
        _matchScoreMeta,
        matchScore.isAcceptableOrUnknown(data['match_score']!, _matchScoreMeta),
      );
    }
    if (data.containsKey('match_reasons')) {
      context.handle(
        _matchReasonsMeta,
        matchReasons.isAcceptableOrUnknown(
          data['match_reasons']!,
          _matchReasonsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CandidateEntityProposal map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CandidateEntityProposal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      candidateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      serialNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_number'],
      ),
      suggestedEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_entity_id'],
      ),
      matchScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}match_score'],
      ),
      matchReasons: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_reasons'],
      )!,
    );
  }

  @override
  $CandidateEntityProposalsTable createAlias(String alias) {
    return $CandidateEntityProposalsTable(attachedDatabase, alias);
  }
}

class CandidateEntityProposal extends DataClass
    implements Insertable<CandidateEntityProposal> {
  final String id;
  final String candidateId;
  final String name;
  final String entityType;
  final double confidence;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final String? suggestedEntityId;
  final double? matchScore;
  final String matchReasons;
  const CandidateEntityProposal({
    required this.id,
    required this.candidateId,
    required this.name,
    required this.entityType,
    required this.confidence,
    this.brand,
    this.model,
    this.serialNumber,
    this.suggestedEntityId,
    this.matchScore,
    required this.matchReasons,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['candidate_id'] = Variable<String>(candidateId);
    map['name'] = Variable<String>(name);
    map['entity_type'] = Variable<String>(entityType);
    map['confidence'] = Variable<double>(confidence);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || serialNumber != null) {
      map['serial_number'] = Variable<String>(serialNumber);
    }
    if (!nullToAbsent || suggestedEntityId != null) {
      map['suggested_entity_id'] = Variable<String>(suggestedEntityId);
    }
    if (!nullToAbsent || matchScore != null) {
      map['match_score'] = Variable<double>(matchScore);
    }
    map['match_reasons'] = Variable<String>(matchReasons);
    return map;
  }

  CandidateEntityProposalsCompanion toCompanion(bool nullToAbsent) {
    return CandidateEntityProposalsCompanion(
      id: Value(id),
      candidateId: Value(candidateId),
      name: Value(name),
      entityType: Value(entityType),
      confidence: Value(confidence),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      serialNumber: serialNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(serialNumber),
      suggestedEntityId: suggestedEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedEntityId),
      matchScore: matchScore == null && nullToAbsent
          ? const Value.absent()
          : Value(matchScore),
      matchReasons: Value(matchReasons),
    );
  }

  factory CandidateEntityProposal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CandidateEntityProposal(
      id: serializer.fromJson<String>(json['id']),
      candidateId: serializer.fromJson<String>(json['candidateId']),
      name: serializer.fromJson<String>(json['name']),
      entityType: serializer.fromJson<String>(json['entityType']),
      confidence: serializer.fromJson<double>(json['confidence']),
      brand: serializer.fromJson<String?>(json['brand']),
      model: serializer.fromJson<String?>(json['model']),
      serialNumber: serializer.fromJson<String?>(json['serialNumber']),
      suggestedEntityId: serializer.fromJson<String?>(
        json['suggestedEntityId'],
      ),
      matchScore: serializer.fromJson<double?>(json['matchScore']),
      matchReasons: serializer.fromJson<String>(json['matchReasons']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'candidateId': serializer.toJson<String>(candidateId),
      'name': serializer.toJson<String>(name),
      'entityType': serializer.toJson<String>(entityType),
      'confidence': serializer.toJson<double>(confidence),
      'brand': serializer.toJson<String?>(brand),
      'model': serializer.toJson<String?>(model),
      'serialNumber': serializer.toJson<String?>(serialNumber),
      'suggestedEntityId': serializer.toJson<String?>(suggestedEntityId),
      'matchScore': serializer.toJson<double?>(matchScore),
      'matchReasons': serializer.toJson<String>(matchReasons),
    };
  }

  CandidateEntityProposal copyWith({
    String? id,
    String? candidateId,
    String? name,
    String? entityType,
    double? confidence,
    Value<String?> brand = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<String?> serialNumber = const Value.absent(),
    Value<String?> suggestedEntityId = const Value.absent(),
    Value<double?> matchScore = const Value.absent(),
    String? matchReasons,
  }) => CandidateEntityProposal(
    id: id ?? this.id,
    candidateId: candidateId ?? this.candidateId,
    name: name ?? this.name,
    entityType: entityType ?? this.entityType,
    confidence: confidence ?? this.confidence,
    brand: brand.present ? brand.value : this.brand,
    model: model.present ? model.value : this.model,
    serialNumber: serialNumber.present ? serialNumber.value : this.serialNumber,
    suggestedEntityId: suggestedEntityId.present
        ? suggestedEntityId.value
        : this.suggestedEntityId,
    matchScore: matchScore.present ? matchScore.value : this.matchScore,
    matchReasons: matchReasons ?? this.matchReasons,
  );
  CandidateEntityProposal copyWithCompanion(
    CandidateEntityProposalsCompanion data,
  ) {
    return CandidateEntityProposal(
      id: data.id.present ? data.id.value : this.id,
      candidateId: data.candidateId.present
          ? data.candidateId.value
          : this.candidateId,
      name: data.name.present ? data.name.value : this.name,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      serialNumber: data.serialNumber.present
          ? data.serialNumber.value
          : this.serialNumber,
      suggestedEntityId: data.suggestedEntityId.present
          ? data.suggestedEntityId.value
          : this.suggestedEntityId,
      matchScore: data.matchScore.present
          ? data.matchScore.value
          : this.matchScore,
      matchReasons: data.matchReasons.present
          ? data.matchReasons.value
          : this.matchReasons,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CandidateEntityProposal(')
          ..write('id: $id, ')
          ..write('candidateId: $candidateId, ')
          ..write('name: $name, ')
          ..write('entityType: $entityType, ')
          ..write('confidence: $confidence, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('suggestedEntityId: $suggestedEntityId, ')
          ..write('matchScore: $matchScore, ')
          ..write('matchReasons: $matchReasons')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    candidateId,
    name,
    entityType,
    confidence,
    brand,
    model,
    serialNumber,
    suggestedEntityId,
    matchScore,
    matchReasons,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CandidateEntityProposal &&
          other.id == this.id &&
          other.candidateId == this.candidateId &&
          other.name == this.name &&
          other.entityType == this.entityType &&
          other.confidence == this.confidence &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.serialNumber == this.serialNumber &&
          other.suggestedEntityId == this.suggestedEntityId &&
          other.matchScore == this.matchScore &&
          other.matchReasons == this.matchReasons);
}

class CandidateEntityProposalsCompanion
    extends UpdateCompanion<CandidateEntityProposal> {
  final Value<String> id;
  final Value<String> candidateId;
  final Value<String> name;
  final Value<String> entityType;
  final Value<double> confidence;
  final Value<String?> brand;
  final Value<String?> model;
  final Value<String?> serialNumber;
  final Value<String?> suggestedEntityId;
  final Value<double?> matchScore;
  final Value<String> matchReasons;
  final Value<int> rowid;
  const CandidateEntityProposalsCompanion({
    this.id = const Value.absent(),
    this.candidateId = const Value.absent(),
    this.name = const Value.absent(),
    this.entityType = const Value.absent(),
    this.confidence = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.suggestedEntityId = const Value.absent(),
    this.matchScore = const Value.absent(),
    this.matchReasons = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CandidateEntityProposalsCompanion.insert({
    required String id,
    required String candidateId,
    required String name,
    required String entityType,
    required double confidence,
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.serialNumber = const Value.absent(),
    this.suggestedEntityId = const Value.absent(),
    this.matchScore = const Value.absent(),
    this.matchReasons = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       candidateId = Value(candidateId),
       name = Value(name),
       entityType = Value(entityType),
       confidence = Value(confidence);
  static Insertable<CandidateEntityProposal> custom({
    Expression<String>? id,
    Expression<String>? candidateId,
    Expression<String>? name,
    Expression<String>? entityType,
    Expression<double>? confidence,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? serialNumber,
    Expression<String>? suggestedEntityId,
    Expression<double>? matchScore,
    Expression<String>? matchReasons,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (candidateId != null) 'candidate_id': candidateId,
      if (name != null) 'name': name,
      if (entityType != null) 'entity_type': entityType,
      if (confidence != null) 'confidence': confidence,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (suggestedEntityId != null) 'suggested_entity_id': suggestedEntityId,
      if (matchScore != null) 'match_score': matchScore,
      if (matchReasons != null) 'match_reasons': matchReasons,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CandidateEntityProposalsCompanion copyWith({
    Value<String>? id,
    Value<String>? candidateId,
    Value<String>? name,
    Value<String>? entityType,
    Value<double>? confidence,
    Value<String?>? brand,
    Value<String?>? model,
    Value<String?>? serialNumber,
    Value<String?>? suggestedEntityId,
    Value<double?>? matchScore,
    Value<String>? matchReasons,
    Value<int>? rowid,
  }) {
    return CandidateEntityProposalsCompanion(
      id: id ?? this.id,
      candidateId: candidateId ?? this.candidateId,
      name: name ?? this.name,
      entityType: entityType ?? this.entityType,
      confidence: confidence ?? this.confidence,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      suggestedEntityId: suggestedEntityId ?? this.suggestedEntityId,
      matchScore: matchScore ?? this.matchScore,
      matchReasons: matchReasons ?? this.matchReasons,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (candidateId.present) {
      map['candidate_id'] = Variable<String>(candidateId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (serialNumber.present) {
      map['serial_number'] = Variable<String>(serialNumber.value);
    }
    if (suggestedEntityId.present) {
      map['suggested_entity_id'] = Variable<String>(suggestedEntityId.value);
    }
    if (matchScore.present) {
      map['match_score'] = Variable<double>(matchScore.value);
    }
    if (matchReasons.present) {
      map['match_reasons'] = Variable<String>(matchReasons.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CandidateEntityProposalsCompanion(')
          ..write('id: $id, ')
          ..write('candidateId: $candidateId, ')
          ..write('name: $name, ')
          ..write('entityType: $entityType, ')
          ..write('confidence: $confidence, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('serialNumber: $serialNumber, ')
          ..write('suggestedEntityId: $suggestedEntityId, ')
          ..write('matchScore: $matchScore, ')
          ..write('matchReasons: $matchReasons, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeatureUsageTable extends FeatureUsage
    with TableInfo<$FeatureUsageTable, FeatureUsageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeatureUsageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _featureMeta = const VerificationMeta(
    'feature',
  );
  @override
  late final GeneratedColumn<String> feature = GeneratedColumn<String>(
    'feature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [feature, usageCount, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feature_usage';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeatureUsageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feature')) {
      context.handle(
        _featureMeta,
        feature.isAcceptableOrUnknown(data['feature']!, _featureMeta),
      );
    } else if (isInserting) {
      context.missing(_featureMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feature};
  @override
  FeatureUsageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeatureUsageData(
      feature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feature'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FeatureUsageTable createAlias(String alias) {
    return $FeatureUsageTable(attachedDatabase, alias);
  }
}

class FeatureUsageData extends DataClass
    implements Insertable<FeatureUsageData> {
  final String feature;
  final int usageCount;
  final DateTime updatedAt;
  const FeatureUsageData({
    required this.feature,
    required this.usageCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feature'] = Variable<String>(feature);
    map['usage_count'] = Variable<int>(usageCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FeatureUsageCompanion toCompanion(bool nullToAbsent) {
    return FeatureUsageCompanion(
      feature: Value(feature),
      usageCount: Value(usageCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeatureUsageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeatureUsageData(
      feature: serializer.fromJson<String>(json['feature']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feature': serializer.toJson<String>(feature),
      'usageCount': serializer.toJson<int>(usageCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FeatureUsageData copyWith({
    String? feature,
    int? usageCount,
    DateTime? updatedAt,
  }) => FeatureUsageData(
    feature: feature ?? this.feature,
    usageCount: usageCount ?? this.usageCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FeatureUsageData copyWithCompanion(FeatureUsageCompanion data) {
    return FeatureUsageData(
      feature: data.feature.present ? data.feature.value : this.feature,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeatureUsageData(')
          ..write('feature: $feature, ')
          ..write('usageCount: $usageCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feature, usageCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeatureUsageData &&
          other.feature == this.feature &&
          other.usageCount == this.usageCount &&
          other.updatedAt == this.updatedAt);
}

class FeatureUsageCompanion extends UpdateCompanion<FeatureUsageData> {
  final Value<String> feature;
  final Value<int> usageCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FeatureUsageCompanion({
    this.feature = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeatureUsageCompanion.insert({
    required String feature,
    this.usageCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : feature = Value(feature),
       updatedAt = Value(updatedAt);
  static Insertable<FeatureUsageData> custom({
    Expression<String>? feature,
    Expression<int>? usageCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feature != null) 'feature': feature,
      if (usageCount != null) 'usage_count': usageCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeatureUsageCompanion copyWith({
    Value<String>? feature,
    Value<int>? usageCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FeatureUsageCompanion(
      feature: feature ?? this.feature,
      usageCount: usageCount ?? this.usageCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feature.present) {
      map['feature'] = Variable<String>(feature.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeatureUsageCompanion(')
          ..write('feature: $feature, ')
          ..write('usageCount: $usageCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyClassificationMeta =
      const VerificationMeta('privacyClassification');
  @override
  late final GeneratedColumn<String> privacyClassification =
      GeneratedColumn<String>(
        'privacy_classification',
        aliasedName,
        false,
        check: () => privacyClassification.isIn(SchemaValues.privacy),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lifecycleMeta = const VerificationMeta(
    'lifecycle',
  );
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
    'lifecycle',
    aliasedName,
    false,
    check: () => lifecycle.isIn(SchemaValues.lifecycle),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    normalizedName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('privacy_classification')) {
      context.handle(
        _privacyClassificationMeta,
        privacyClassification.isAcceptableOrUnknown(
          data['privacy_classification']!,
          _privacyClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyClassificationMeta);
    }
    if (data.containsKey('lifecycle')) {
      context.handle(
        _lifecycleMeta,
        lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta),
      );
    } else if (isInserting) {
      context.missing(_lifecycleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      privacyClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_classification'],
      )!,
      lifecycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String privacyClassification;
  final String lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String normalizedName;
  const Tag({
    required this.id,
    required this.privacyClassification,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.normalizedName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['privacy_classification'] = Variable<String>(privacyClassification);
    map['lifecycle'] = Variable<String>(lifecycle);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      privacyClassification: Value(privacyClassification),
      lifecycle: Value(lifecycle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      normalizedName: Value(normalizedName),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      privacyClassification: serializer.fromJson<String>(
        json['privacyClassification'],
      ),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'privacyClassification': serializer.toJson<String>(privacyClassification),
      'lifecycle': serializer.toJson<String>(lifecycle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
    };
  }

  Tag copyWith({
    String? id,
    String? privacyClassification,
    String? lifecycle,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    String? normalizedName,
  }) => Tag(
    id: id ?? this.id,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    lifecycle: lifecycle ?? this.lifecycle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      privacyClassification: data.privacyClassification.present
          ? data.privacyClassification.value
          : this.privacyClassification,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    normalizedName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.privacyClassification == this.privacyClassification &&
          other.lifecycle == this.lifecycle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> privacyClassification;
  final Value<String> lifecycle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.privacyClassification = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String privacyClassification,
    required String lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required String normalizedName,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       privacyClassification = Value(privacyClassification),
       lifecycle = Value(lifecycle),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       normalizedName = Value(normalizedName);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? privacyClassification,
    Expression<String>? lifecycle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (privacyClassification != null)
        'privacy_classification': privacyClassification,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? privacyClassification,
    Value<String>? lifecycle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      privacyClassification:
          privacyClassification ?? this.privacyClassification,
      lifecycle: lifecycle ?? this.lifecycle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (privacyClassification.present) {
      map['privacy_classification'] = Variable<String>(
        privacyClassification.value,
      );
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _privacyClassificationMeta =
      const VerificationMeta('privacyClassification');
  @override
  late final GeneratedColumn<String> privacyClassification =
      GeneratedColumn<String>(
        'privacy_classification',
        aliasedName,
        false,
        check: () => privacyClassification.isIn(SchemaValues.privacy),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lifecycleMeta = const VerificationMeta(
    'lifecycle',
  );
  @override
  late final GeneratedColumn<String> lifecycle = GeneratedColumn<String>(
    'lifecycle',
    aliasedName,
    false,
    check: () => lifecycle.isIn(SchemaValues.lifecycle),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    normalizedName,
    parentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('privacy_classification')) {
      context.handle(
        _privacyClassificationMeta,
        privacyClassification.isAcceptableOrUnknown(
          data['privacy_classification']!,
          _privacyClassificationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_privacyClassificationMeta);
    }
    if (data.containsKey('lifecycle')) {
      context.handle(
        _lifecycleMeta,
        lifecycle.isAcceptableOrUnknown(data['lifecycle']!, _lifecycleMeta),
      );
    } else if (isInserting) {
      context.missing(_lifecycleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      privacyClassification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privacy_classification'],
      )!,
      lifecycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lifecycle'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String privacyClassification;
  final String lifecycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String normalizedName;
  final String? parentId;
  const Category({
    required this.id,
    required this.privacyClassification,
    required this.lifecycle,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.normalizedName,
    this.parentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['privacy_classification'] = Variable<String>(privacyClassification);
    map['lifecycle'] = Variable<String>(lifecycle);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      privacyClassification: Value(privacyClassification),
      lifecycle: Value(lifecycle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      normalizedName: Value(normalizedName),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      privacyClassification: serializer.fromJson<String>(
        json['privacyClassification'],
      ),
      lifecycle: serializer.fromJson<String>(json['lifecycle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      parentId: serializer.fromJson<String?>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'privacyClassification': serializer.toJson<String>(privacyClassification),
      'lifecycle': serializer.toJson<String>(lifecycle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'parentId': serializer.toJson<String?>(parentId),
    };
  }

  Category copyWith({
    String? id,
    String? privacyClassification,
    String? lifecycle,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    String? normalizedName,
    Value<String?> parentId = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    lifecycle: lifecycle ?? this.lifecycle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      privacyClassification: data.privacyClassification.present
          ? data.privacyClassification.value
          : this.privacyClassification,
      lifecycle: data.lifecycle.present ? data.lifecycle.value : this.lifecycle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    privacyClassification,
    lifecycle,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    normalizedName,
    parentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.privacyClassification == this.privacyClassification &&
          other.lifecycle == this.lifecycle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.parentId == this.parentId);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> privacyClassification;
  final Value<String> lifecycle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String?> parentId;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.privacyClassification = const Value.absent(),
    this.lifecycle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String privacyClassification,
    required String lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required String normalizedName,
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       privacyClassification = Value(privacyClassification),
       lifecycle = Value(lifecycle),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       normalizedName = Value(normalizedName);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? privacyClassification,
    Expression<String>? lifecycle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? parentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (privacyClassification != null)
        'privacy_classification': privacyClassification,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (parentId != null) 'parent_id': parentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? privacyClassification,
    Value<String>? lifecycle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String?>? parentId,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      privacyClassification:
          privacyClassification ?? this.privacyClassification,
      lifecycle: lifecycle ?? this.lifecycle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      parentId: parentId ?? this.parentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (privacyClassification.present) {
      map['privacy_classification'] = Variable<String>(
        privacyClassification.value,
      );
    }
    if (lifecycle.present) {
      map['lifecycle'] = Variable<String>(lifecycle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('privacyClassification: $privacyClassification, ')
          ..write('lifecycle: $lifecycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('parentId: $parentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityTagsTable extends EntityTags
    with TableInfo<$EntityTagsTable, EntityTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entities (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [entityId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityId, tagId};
  @override
  EntityTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityTag(
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $EntityTagsTable createAlias(String alias) {
    return $EntityTagsTable(attachedDatabase, alias);
  }
}

class EntityTag extends DataClass implements Insertable<EntityTag> {
  final String entityId;
  final String tagId;
  const EntityTag({required this.entityId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_id'] = Variable<String>(entityId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  EntityTagsCompanion toCompanion(bool nullToAbsent) {
    return EntityTagsCompanion(entityId: Value(entityId), tagId: Value(tagId));
  }

  factory EntityTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityTag(
      entityId: serializer.fromJson<String>(json['entityId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityId': serializer.toJson<String>(entityId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  EntityTag copyWith({String? entityId, String? tagId}) => EntityTag(
    entityId: entityId ?? this.entityId,
    tagId: tagId ?? this.tagId,
  );
  EntityTag copyWithCompanion(EntityTagsCompanion data) {
    return EntityTag(
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityTag(')
          ..write('entityId: $entityId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityTag &&
          other.entityId == this.entityId &&
          other.tagId == this.tagId);
}

class EntityTagsCompanion extends UpdateCompanion<EntityTag> {
  final Value<String> entityId;
  final Value<String> tagId;
  final Value<int> rowid;
  const EntityTagsCompanion({
    this.entityId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntityTagsCompanion.insert({
    required String entityId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : entityId = Value(entityId),
       tagId = Value(tagId);
  static Insertable<EntityTag> custom({
    Expression<String>? entityId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityId != null) 'entity_id': entityId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntityTagsCompanion copyWith({
    Value<String>? entityId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return EntityTagsCompanion(
      entityId: entityId ?? this.entityId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityTagsCompanion(')
          ..write('entityId: $entityId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventTagsTable extends EventTags
    with TableInfo<$EventTagsTable, EventTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [eventId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, tagId};
  @override
  EventTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventTag(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $EventTagsTable createAlias(String alias) {
    return $EventTagsTable(attachedDatabase, alias);
  }
}

class EventTag extends DataClass implements Insertable<EventTag> {
  final String eventId;
  final String tagId;
  const EventTag({required this.eventId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  EventTagsCompanion toCompanion(bool nullToAbsent) {
    return EventTagsCompanion(eventId: Value(eventId), tagId: Value(tagId));
  }

  factory EventTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventTag(
      eventId: serializer.fromJson<String>(json['eventId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  EventTag copyWith({String? eventId, String? tagId}) =>
      EventTag(eventId: eventId ?? this.eventId, tagId: tagId ?? this.tagId);
  EventTag copyWithCompanion(EventTagsCompanion data) {
    return EventTag(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventTag(')
          ..write('eventId: $eventId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventTag &&
          other.eventId == this.eventId &&
          other.tagId == this.tagId);
}

class EventTagsCompanion extends UpdateCompanion<EventTag> {
  final Value<String> eventId;
  final Value<String> tagId;
  final Value<int> rowid;
  const EventTagsCompanion({
    this.eventId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventTagsCompanion.insert({
    required String eventId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       tagId = Value(tagId);
  static Insertable<EventTag> custom({
    Expression<String>? eventId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventTagsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return EventTagsCompanion(
      eventId: eventId ?? this.eventId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventTagsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EvidenceTagsTable extends EvidenceTags
    with TableInfo<$EvidenceTagsTable, EvidenceTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidenceTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _evidenceIdMeta = const VerificationMeta(
    'evidenceId',
  );
  @override
  late final GeneratedColumn<String> evidenceId = GeneratedColumn<String>(
    'evidence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES evidence (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [evidenceId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidence_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvidenceTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('evidence_id')) {
      context.handle(
        _evidenceIdMeta,
        evidenceId.isAcceptableOrUnknown(data['evidence_id']!, _evidenceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_evidenceIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {evidenceId, tagId};
  @override
  EvidenceTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvidenceTag(
      evidenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $EvidenceTagsTable createAlias(String alias) {
    return $EvidenceTagsTable(attachedDatabase, alias);
  }
}

class EvidenceTag extends DataClass implements Insertable<EvidenceTag> {
  final String evidenceId;
  final String tagId;
  const EvidenceTag({required this.evidenceId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['evidence_id'] = Variable<String>(evidenceId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  EvidenceTagsCompanion toCompanion(bool nullToAbsent) {
    return EvidenceTagsCompanion(
      evidenceId: Value(evidenceId),
      tagId: Value(tagId),
    );
  }

  factory EvidenceTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvidenceTag(
      evidenceId: serializer.fromJson<String>(json['evidenceId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'evidenceId': serializer.toJson<String>(evidenceId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  EvidenceTag copyWith({String? evidenceId, String? tagId}) => EvidenceTag(
    evidenceId: evidenceId ?? this.evidenceId,
    tagId: tagId ?? this.tagId,
  );
  EvidenceTag copyWithCompanion(EvidenceTagsCompanion data) {
    return EvidenceTag(
      evidenceId: data.evidenceId.present
          ? data.evidenceId.value
          : this.evidenceId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceTag(')
          ..write('evidenceId: $evidenceId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(evidenceId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvidenceTag &&
          other.evidenceId == this.evidenceId &&
          other.tagId == this.tagId);
}

class EvidenceTagsCompanion extends UpdateCompanion<EvidenceTag> {
  final Value<String> evidenceId;
  final Value<String> tagId;
  final Value<int> rowid;
  const EvidenceTagsCompanion({
    this.evidenceId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvidenceTagsCompanion.insert({
    required String evidenceId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : evidenceId = Value(evidenceId),
       tagId = Value(tagId);
  static Insertable<EvidenceTag> custom({
    Expression<String>? evidenceId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (evidenceId != null) 'evidence_id': evidenceId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvidenceTagsCompanion copyWith({
    Value<String>? evidenceId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return EvidenceTagsCompanion(
      evidenceId: evidenceId ?? this.evidenceId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (evidenceId.present) {
      map['evidence_id'] = Variable<String>(evidenceId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceTagsCompanion(')
          ..write('evidenceId: $evidenceId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityCategoriesTable extends EntityCategories
    with TableInfo<$EntityCategoriesTable, EntityCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entities (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [entityId, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityId, categoryId};
  @override
  EntityCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityCategory(
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $EntityCategoriesTable createAlias(String alias) {
    return $EntityCategoriesTable(attachedDatabase, alias);
  }
}

class EntityCategory extends DataClass implements Insertable<EntityCategory> {
  final String entityId;
  final String categoryId;
  const EntityCategory({required this.entityId, required this.categoryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_id'] = Variable<String>(entityId);
    map['category_id'] = Variable<String>(categoryId);
    return map;
  }

  EntityCategoriesCompanion toCompanion(bool nullToAbsent) {
    return EntityCategoriesCompanion(
      entityId: Value(entityId),
      categoryId: Value(categoryId),
    );
  }

  factory EntityCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityCategory(
      entityId: serializer.fromJson<String>(json['entityId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityId': serializer.toJson<String>(entityId),
      'categoryId': serializer.toJson<String>(categoryId),
    };
  }

  EntityCategory copyWith({String? entityId, String? categoryId}) =>
      EntityCategory(
        entityId: entityId ?? this.entityId,
        categoryId: categoryId ?? this.categoryId,
      );
  EntityCategory copyWithCompanion(EntityCategoriesCompanion data) {
    return EntityCategory(
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityCategory(')
          ..write('entityId: $entityId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityId, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityCategory &&
          other.entityId == this.entityId &&
          other.categoryId == this.categoryId);
}

class EntityCategoriesCompanion extends UpdateCompanion<EntityCategory> {
  final Value<String> entityId;
  final Value<String> categoryId;
  final Value<int> rowid;
  const EntityCategoriesCompanion({
    this.entityId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntityCategoriesCompanion.insert({
    required String entityId,
    required String categoryId,
    this.rowid = const Value.absent(),
  }) : entityId = Value(entityId),
       categoryId = Value(categoryId);
  static Insertable<EntityCategory> custom({
    Expression<String>? entityId,
    Expression<String>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityId != null) 'entity_id': entityId,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntityCategoriesCompanion copyWith({
    Value<String>? entityId,
    Value<String>? categoryId,
    Value<int>? rowid,
  }) {
    return EntityCategoriesCompanion(
      entityId: entityId ?? this.entityId,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityCategoriesCompanion(')
          ..write('entityId: $entityId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventCategoriesTable extends EventCategories
    with TableInfo<$EventCategoriesTable, EventCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [eventId, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, categoryId};
  @override
  EventCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventCategory(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $EventCategoriesTable createAlias(String alias) {
    return $EventCategoriesTable(attachedDatabase, alias);
  }
}

class EventCategory extends DataClass implements Insertable<EventCategory> {
  final String eventId;
  final String categoryId;
  const EventCategory({required this.eventId, required this.categoryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['category_id'] = Variable<String>(categoryId);
    return map;
  }

  EventCategoriesCompanion toCompanion(bool nullToAbsent) {
    return EventCategoriesCompanion(
      eventId: Value(eventId),
      categoryId: Value(categoryId),
    );
  }

  factory EventCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventCategory(
      eventId: serializer.fromJson<String>(json['eventId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'categoryId': serializer.toJson<String>(categoryId),
    };
  }

  EventCategory copyWith({String? eventId, String? categoryId}) =>
      EventCategory(
        eventId: eventId ?? this.eventId,
        categoryId: categoryId ?? this.categoryId,
      );
  EventCategory copyWithCompanion(EventCategoriesCompanion data) {
    return EventCategory(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventCategory(')
          ..write('eventId: $eventId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventCategory &&
          other.eventId == this.eventId &&
          other.categoryId == this.categoryId);
}

class EventCategoriesCompanion extends UpdateCompanion<EventCategory> {
  final Value<String> eventId;
  final Value<String> categoryId;
  final Value<int> rowid;
  const EventCategoriesCompanion({
    this.eventId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventCategoriesCompanion.insert({
    required String eventId,
    required String categoryId,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       categoryId = Value(categoryId);
  static Insertable<EventCategory> custom({
    Expression<String>? eventId,
    Expression<String>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventCategoriesCompanion copyWith({
    Value<String>? eventId,
    Value<String>? categoryId,
    Value<int>? rowid,
  }) {
    return EventCategoriesCompanion(
      eventId: eventId ?? this.eventId,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventCategoriesCompanion(')
          ..write('eventId: $eventId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EvidenceCategoriesTable extends EvidenceCategories
    with TableInfo<$EvidenceCategoriesTable, EvidenceCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidenceCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _evidenceIdMeta = const VerificationMeta(
    'evidenceId',
  );
  @override
  late final GeneratedColumn<String> evidenceId = GeneratedColumn<String>(
    'evidence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES evidence (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [evidenceId, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidence_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvidenceCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('evidence_id')) {
      context.handle(
        _evidenceIdMeta,
        evidenceId.isAcceptableOrUnknown(data['evidence_id']!, _evidenceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_evidenceIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {evidenceId, categoryId};
  @override
  EvidenceCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvidenceCategory(
      evidenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $EvidenceCategoriesTable createAlias(String alias) {
    return $EvidenceCategoriesTable(attachedDatabase, alias);
  }
}

class EvidenceCategory extends DataClass
    implements Insertable<EvidenceCategory> {
  final String evidenceId;
  final String categoryId;
  const EvidenceCategory({required this.evidenceId, required this.categoryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['evidence_id'] = Variable<String>(evidenceId);
    map['category_id'] = Variable<String>(categoryId);
    return map;
  }

  EvidenceCategoriesCompanion toCompanion(bool nullToAbsent) {
    return EvidenceCategoriesCompanion(
      evidenceId: Value(evidenceId),
      categoryId: Value(categoryId),
    );
  }

  factory EvidenceCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvidenceCategory(
      evidenceId: serializer.fromJson<String>(json['evidenceId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'evidenceId': serializer.toJson<String>(evidenceId),
      'categoryId': serializer.toJson<String>(categoryId),
    };
  }

  EvidenceCategory copyWith({String? evidenceId, String? categoryId}) =>
      EvidenceCategory(
        evidenceId: evidenceId ?? this.evidenceId,
        categoryId: categoryId ?? this.categoryId,
      );
  EvidenceCategory copyWithCompanion(EvidenceCategoriesCompanion data) {
    return EvidenceCategory(
      evidenceId: data.evidenceId.present
          ? data.evidenceId.value
          : this.evidenceId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceCategory(')
          ..write('evidenceId: $evidenceId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(evidenceId, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvidenceCategory &&
          other.evidenceId == this.evidenceId &&
          other.categoryId == this.categoryId);
}

class EvidenceCategoriesCompanion extends UpdateCompanion<EvidenceCategory> {
  final Value<String> evidenceId;
  final Value<String> categoryId;
  final Value<int> rowid;
  const EvidenceCategoriesCompanion({
    this.evidenceId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvidenceCategoriesCompanion.insert({
    required String evidenceId,
    required String categoryId,
    this.rowid = const Value.absent(),
  }) : evidenceId = Value(evidenceId),
       categoryId = Value(categoryId);
  static Insertable<EvidenceCategory> custom({
    Expression<String>? evidenceId,
    Expression<String>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (evidenceId != null) 'evidence_id': evidenceId,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvidenceCategoriesCompanion copyWith({
    Value<String>? evidenceId,
    Value<String>? categoryId,
    Value<int>? rowid,
  }) {
    return EvidenceCategoriesCompanion(
      evidenceId: evidenceId ?? this.evidenceId,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (evidenceId.present) {
      map['evidence_id'] = Variable<String>(evidenceId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceCategoriesCompanion(')
          ..write('evidenceId: $evidenceId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EntitiesTable entities = $EntitiesTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $EvidenceRecordsTable evidenceRecords = $EvidenceRecordsTable(
    this,
  );
  late final $RelationshipsTable relationships = $RelationshipsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $MemoryCandidatesTable memoryCandidates = $MemoryCandidatesTable(
    this,
  );
  late final $FieldProvenanceRowsTable fieldProvenanceRows =
      $FieldProvenanceRowsTable(this);
  late final $CandidateExtractedFieldsTable candidateExtractedFields =
      $CandidateExtractedFieldsTable(this);
  late final $CandidateEntityProposalsTable candidateEntityProposals =
      $CandidateEntityProposalsTable(this);
  late final $FeatureUsageTable featureUsage = $FeatureUsageTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $EntityTagsTable entityTags = $EntityTagsTable(this);
  late final $EventTagsTable eventTags = $EventTagsTable(this);
  late final $EvidenceTagsTable evidenceTags = $EvidenceTagsTable(this);
  late final $EntityCategoriesTable entityCategories = $EntityCategoriesTable(
    this,
  );
  late final $EventCategoriesTable eventCategories = $EventCategoriesTable(
    this,
  );
  late final $EvidenceCategoriesTable evidenceCategories =
      $EvidenceCategoriesTable(this);
  late final Index entitiesLifecycleIdx = Index(
    'entities_lifecycle_idx',
    'CREATE INDEX entities_lifecycle_idx ON entities (lifecycle)',
  );
  late final Index entitiesNormalizedNameIdx = Index(
    'entities_normalized_name_idx',
    'CREATE INDEX entities_normalized_name_idx ON entities (normalized_name)',
  );
  late final Index eventsLifecycleIdx = Index(
    'events_lifecycle_idx',
    'CREATE INDEX events_lifecycle_idx ON events (lifecycle)',
  );
  late final Index eventsTemporalStartIdx = Index(
    'events_temporal_start_idx',
    'CREATE INDEX events_temporal_start_idx ON events (start_year, start_month, start_day)',
  );
  late final Index evidenceLifecycleIdx = Index(
    'evidence_lifecycle_idx',
    'CREATE INDEX evidence_lifecycle_idx ON evidence (lifecycle)',
  );
  late final Index evidenceTypeIdx = Index(
    'evidence_type_idx',
    'CREATE INDEX evidence_type_idx ON evidence (evidence_type)',
  );
  late final Index relationshipsSourceEntityIdx = Index(
    'relationships_source_entity_idx',
    'CREATE INDEX relationships_source_entity_idx ON relationships (source_entity_id)',
  );
  late final Index relationshipsSourceEventIdx = Index(
    'relationships_source_event_idx',
    'CREATE INDEX relationships_source_event_idx ON relationships (source_event_id)',
  );
  late final Index relationshipsSourceEvidenceIdx = Index(
    'relationships_source_evidence_idx',
    'CREATE INDEX relationships_source_evidence_idx ON relationships (source_evidence_id)',
  );
  late final Index relationshipsTargetEntityIdx = Index(
    'relationships_target_entity_idx',
    'CREATE INDEX relationships_target_entity_idx ON relationships (target_entity_id)',
  );
  late final Index relationshipsTargetEventIdx = Index(
    'relationships_target_event_idx',
    'CREATE INDEX relationships_target_event_idx ON relationships (target_event_id)',
  );
  late final Index relationshipsTargetEvidenceIdx = Index(
    'relationships_target_evidence_idx',
    'CREATE INDEX relationships_target_evidence_idx ON relationships (target_evidence_id)',
  );
  late final Index attachmentsEvidenceIdx = Index(
    'attachments_evidence_idx',
    'CREATE INDEX attachments_evidence_idx ON attachments (evidence_id)',
  );
  late final Index attachmentsStorageStateIdx = Index(
    'attachments_storage_state_idx',
    'CREATE INDEX attachments_storage_state_idx ON attachments (storage_state)',
  );
  late final Index attachmentsChecksumIdx = Index(
    'attachments_checksum_idx',
    'CREATE INDEX attachments_checksum_idx ON attachments (checksum)',
  );
  late final Index provenanceEntityIdx = Index(
    'provenance_entity_idx',
    'CREATE INDEX provenance_entity_idx ON field_provenance (entity_id)',
  );
  late final Index provenanceEventIdx = Index(
    'provenance_event_idx',
    'CREATE INDEX provenance_event_idx ON field_provenance (event_id)',
  );
  late final Index provenanceEvidenceIdx = Index(
    'provenance_evidence_idx',
    'CREATE INDEX provenance_evidence_idx ON field_provenance (evidence_id)',
  );
  late final Index provenanceRelationshipIdx = Index(
    'provenance_relationship_idx',
    'CREATE INDEX provenance_relationship_idx ON field_provenance (relationship_id)',
  );
  late final Index provenanceAttachmentIdx = Index(
    'provenance_attachment_idx',
    'CREATE INDEX provenance_attachment_idx ON field_provenance (attachment_id)',
  );
  late final Index provenanceCandidateIdx = Index(
    'provenance_candidate_idx',
    'CREATE INDEX provenance_candidate_idx ON field_provenance (memory_candidate_id)',
  );
  late final Index memoryCandidatesLifecycleIdx = Index(
    'memory_candidates_lifecycle_idx',
    'CREATE INDEX memory_candidates_lifecycle_idx ON memory_candidates (lifecycle)',
  );
  late final Index memoryCandidatesSourceEvidenceIdx = Index(
    'memory_candidates_source_evidence_idx',
    'CREATE INDEX memory_candidates_source_evidence_idx ON memory_candidates (source_evidence_id)',
  );
  late final Index memoryCandidatesTemporalStartIdx = Index(
    'memory_candidates_temporal_start_idx',
    'CREATE INDEX memory_candidates_temporal_start_idx ON memory_candidates (start_year, start_month, start_day)',
  );
  late final Index candidateFieldsCandidateIdx = Index(
    'candidate_fields_candidate_idx',
    'CREATE INDEX candidate_fields_candidate_idx ON candidate_extracted_fields (candidate_id)',
  );
  late final Index candidateFieldsKeyIdx = Index(
    'candidate_fields_key_idx',
    'CREATE INDEX candidate_fields_key_idx ON candidate_extracted_fields ("key")',
  );
  late final Index candidateEntitiesCandidateIdx = Index(
    'candidate_entities_candidate_idx',
    'CREATE INDEX candidate_entities_candidate_idx ON candidate_entity_proposals (candidate_id)',
  );
  late final Index candidateEntitiesSuggestedIdx = Index(
    'candidate_entities_suggested_idx',
    'CREATE INDEX candidate_entities_suggested_idx ON candidate_entity_proposals (suggested_entity_id)',
  );
  late final Index candidateEntitiesSerialIdx = Index(
    'candidate_entities_serial_idx',
    'CREATE INDEX candidate_entities_serial_idx ON candidate_entity_proposals (serial_number)',
  );
  late final Index tagsLifecycleIdx = Index(
    'tags_lifecycle_idx',
    'CREATE INDEX tags_lifecycle_idx ON tags (lifecycle)',
  );
  late final Index categoriesLifecycleIdx = Index(
    'categories_lifecycle_idx',
    'CREATE INDEX categories_lifecycle_idx ON categories (lifecycle)',
  );
  late final Index categoriesParentIdx = Index(
    'categories_parent_idx',
    'CREATE INDEX categories_parent_idx ON categories (parent_id)',
  );
  late final Index entityTagsTagIdx = Index(
    'entity_tags_tag_idx',
    'CREATE INDEX entity_tags_tag_idx ON entity_tags (tag_id)',
  );
  late final Index eventTagsTagIdx = Index(
    'event_tags_tag_idx',
    'CREATE INDEX event_tags_tag_idx ON event_tags (tag_id)',
  );
  late final Index evidenceTagsTagIdx = Index(
    'evidence_tags_tag_idx',
    'CREATE INDEX evidence_tags_tag_idx ON evidence_tags (tag_id)',
  );
  late final Index entityCategoriesCategoryIdx = Index(
    'entity_categories_category_idx',
    'CREATE INDEX entity_categories_category_idx ON entity_categories (category_id)',
  );
  late final Index eventCategoriesCategoryIdx = Index(
    'event_categories_category_idx',
    'CREATE INDEX event_categories_category_idx ON event_categories (category_id)',
  );
  late final Index evidenceCategoriesCategoryIdx = Index(
    'evidence_categories_category_idx',
    'CREATE INDEX evidence_categories_category_idx ON evidence_categories (category_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    entities,
    events,
    evidenceRecords,
    relationships,
    attachments,
    memoryCandidates,
    fieldProvenanceRows,
    candidateExtractedFields,
    candidateEntityProposals,
    featureUsage,
    tags,
    categories,
    entityTags,
    eventTags,
    evidenceTags,
    entityCategories,
    eventCategories,
    evidenceCategories,
    entitiesLifecycleIdx,
    entitiesNormalizedNameIdx,
    eventsLifecycleIdx,
    eventsTemporalStartIdx,
    evidenceLifecycleIdx,
    evidenceTypeIdx,
    relationshipsSourceEntityIdx,
    relationshipsSourceEventIdx,
    relationshipsSourceEvidenceIdx,
    relationshipsTargetEntityIdx,
    relationshipsTargetEventIdx,
    relationshipsTargetEvidenceIdx,
    attachmentsEvidenceIdx,
    attachmentsStorageStateIdx,
    attachmentsChecksumIdx,
    provenanceEntityIdx,
    provenanceEventIdx,
    provenanceEvidenceIdx,
    provenanceRelationshipIdx,
    provenanceAttachmentIdx,
    provenanceCandidateIdx,
    memoryCandidatesLifecycleIdx,
    memoryCandidatesSourceEvidenceIdx,
    memoryCandidatesTemporalStartIdx,
    candidateFieldsCandidateIdx,
    candidateFieldsKeyIdx,
    candidateEntitiesCandidateIdx,
    candidateEntitiesSuggestedIdx,
    candidateEntitiesSerialIdx,
    tagsLifecycleIdx,
    categoriesLifecycleIdx,
    categoriesParentIdx,
    entityTagsTagIdx,
    eventTagsTagIdx,
    evidenceTagsTagIdx,
    entityCategoriesCategoryIdx,
    eventCategoriesCategoryIdx,
    evidenceCategoriesCategoryIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_candidates', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('field_provenance', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('field_provenance', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'evidence',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('field_provenance', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'relationships',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('field_provenance', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'attachments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('field_provenance', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_candidates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('field_provenance', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_candidates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('candidate_extracted_fields', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_candidates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('candidate_entity_proposals', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('candidate_entity_proposals', kind: UpdateKind.update),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entity_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entity_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('event_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('event_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'evidence',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entity_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entity_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'events',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('event_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('event_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'evidence',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_categories', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$EntitiesTableCreateCompanionBuilder =
    EntitiesCompanion Function({
      required String id,
      required String privacyClassification,
      required String lifecycle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      required String normalizedName,
      required String entityType,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$EntitiesTableUpdateCompanionBuilder =
    EntitiesCompanion Function({
      Value<String> id,
      Value<String> privacyClassification,
      Value<String> lifecycle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> entityType,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$EntitiesTableReferences
    extends BaseReferences<_$AppDatabase, $EntitiesTable, Entity> {
  $$EntitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RelationshipsTable, List<Relationship>>
  _sourceEntityRelationshipsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.relationships,
        aliasName: 'entities__id__relationships__source_entity_id',
      );

  $$RelationshipsTableProcessedTableManager get sourceEntityRelationships {
    final manager = $$RelationshipsTableTableManager(
      $_db,
      $_db.relationships,
    ).filter((f) => f.sourceEntityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sourceEntityRelationshipsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RelationshipsTable, List<Relationship>>
  _targetEntityRelationshipsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.relationships,
        aliasName: 'entities__id__relationships__target_entity_id',
      );

  $$RelationshipsTableProcessedTableManager get targetEntityRelationships {
    final manager = $$RelationshipsTableTableManager(
      $_db,
      $_db.relationships,
    ).filter((f) => f.targetEntityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _targetEntityRelationshipsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $FieldProvenanceRowsTable,
    List<FieldProvenanceRow>
  >
  _fieldProvenanceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fieldProvenanceRows,
        aliasName: 'entities__id__field_provenance__entity_id',
      );

  $$FieldProvenanceRowsTableProcessedTableManager get fieldProvenanceRowsRefs {
    final manager = $$FieldProvenanceRowsTableTableManager(
      $_db,
      $_db.fieldProvenanceRows,
    ).filter((f) => f.entityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _fieldProvenanceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CandidateEntityProposalsTable,
    List<CandidateEntityProposal>
  >
  _candidateEntityProposalsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.candidateEntityProposals,
        aliasName:
            'entities__id__candidate_entity_proposals__suggested_entity_id',
      );

  $$CandidateEntityProposalsTableProcessedTableManager
  get candidateEntityProposalsRefs {
    final manager =
        $$CandidateEntityProposalsTableTableManager(
          $_db,
          $_db.candidateEntityProposals,
        ).filter(
          (f) => f.suggestedEntityId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _candidateEntityProposalsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntityTagsTable, List<EntityTag>>
  _entityTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entityTags,
    aliasName: 'entities__id__entity_tags__entity_id',
  );

  $$EntityTagsTableProcessedTableManager get entityTagsRefs {
    final manager = $$EntityTagsTableTableManager(
      $_db,
      $_db.entityTags,
    ).filter((f) => f.entityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entityTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntityCategoriesTable, List<EntityCategory>>
  _entityCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entityCategories,
    aliasName: 'entities__id__entity_categories__entity_id',
  );

  $$EntityCategoriesTableProcessedTableManager get entityCategoriesRefs {
    final manager = $$EntityCategoriesTableTableManager(
      $_db,
      $_db.entityCategories,
    ).filter((f) => f.entityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _entityCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EntitiesTableFilterComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sourceEntityRelationships(
    Expression<bool> Function($$RelationshipsTableFilterComposer f) f,
  ) {
    final $$RelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.sourceEntityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> targetEntityRelationships(
    Expression<bool> Function($$RelationshipsTableFilterComposer f) f,
  ) {
    final $$RelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.targetEntityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fieldProvenanceRowsRefs(
    Expression<bool> Function($$FieldProvenanceRowsTableFilterComposer f) f,
  ) {
    final $$FieldProvenanceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fieldProvenanceRows,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldProvenanceRowsTableFilterComposer(
            $db: $db,
            $table: $db.fieldProvenanceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> candidateEntityProposalsRefs(
    Expression<bool> Function($$CandidateEntityProposalsTableFilterComposer f)
    f,
  ) {
    final $$CandidateEntityProposalsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.candidateEntityProposals,
          getReferencedColumn: (t) => t.suggestedEntityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CandidateEntityProposalsTableFilterComposer(
                $db: $db,
                $table: $db.candidateEntityProposals,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> entityTagsRefs(
    Expression<bool> Function($$EntityTagsTableFilterComposer f) f,
  ) {
    final $$EntityTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityTags,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityTagsTableFilterComposer(
            $db: $db,
            $table: $db.entityTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entityCategoriesRefs(
    Expression<bool> Function($$EntityCategoriesTableFilterComposer f) f,
  ) {
    final $$EntityCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityCategories,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.entityCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> sourceEntityRelationships<T extends Object>(
    Expression<T> Function($$RelationshipsTableAnnotationComposer a) f,
  ) {
    final $$RelationshipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.sourceEntityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableAnnotationComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> targetEntityRelationships<T extends Object>(
    Expression<T> Function($$RelationshipsTableAnnotationComposer a) f,
  ) {
    final $$RelationshipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.targetEntityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableAnnotationComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fieldProvenanceRowsRefs<T extends Object>(
    Expression<T> Function($$FieldProvenanceRowsTableAnnotationComposer a) f,
  ) {
    final $$FieldProvenanceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fieldProvenanceRows,
          getReferencedColumn: (t) => t.entityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FieldProvenanceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.fieldProvenanceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> candidateEntityProposalsRefs<T extends Object>(
    Expression<T> Function($$CandidateEntityProposalsTableAnnotationComposer a)
    f,
  ) {
    final $$CandidateEntityProposalsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.candidateEntityProposals,
          getReferencedColumn: (t) => t.suggestedEntityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CandidateEntityProposalsTableAnnotationComposer(
                $db: $db,
                $table: $db.candidateEntityProposals,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> entityTagsRefs<T extends Object>(
    Expression<T> Function($$EntityTagsTableAnnotationComposer a) f,
  ) {
    final $$EntityTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityTags,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.entityTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entityCategoriesRefs<T extends Object>(
    Expression<T> Function($$EntityCategoriesTableAnnotationComposer a) f,
  ) {
    final $$EntityCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityCategories,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entityCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntitiesTable,
          Entity,
          $$EntitiesTableFilterComposer,
          $$EntitiesTableOrderingComposer,
          $$EntitiesTableAnnotationComposer,
          $$EntitiesTableCreateCompanionBuilder,
          $$EntitiesTableUpdateCompanionBuilder,
          (Entity, $$EntitiesTableReferences),
          Entity,
          PrefetchHooks Function({
            bool sourceEntityRelationships,
            bool targetEntityRelationships,
            bool fieldProvenanceRowsRefs,
            bool candidateEntityProposalsRefs,
            bool entityTagsRefs,
            bool entityCategoriesRefs,
          })
        > {
  $$EntitiesTableTableManager(_$AppDatabase db, $EntitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> privacyClassification = const Value.absent(),
                Value<String> lifecycle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitiesCompanion(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                normalizedName: normalizedName,
                entityType: entityType,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String privacyClassification,
                required String lifecycle,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                required String normalizedName,
                required String entityType,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitiesCompanion.insert(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                normalizedName: normalizedName,
                entityType: entityType,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceEntityRelationships = false,
                targetEntityRelationships = false,
                fieldProvenanceRowsRefs = false,
                candidateEntityProposalsRefs = false,
                entityTagsRefs = false,
                entityCategoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sourceEntityRelationships) db.relationships,
                    if (targetEntityRelationships) db.relationships,
                    if (fieldProvenanceRowsRefs) db.fieldProvenanceRows,
                    if (candidateEntityProposalsRefs)
                      db.candidateEntityProposals,
                    if (entityTagsRefs) db.entityTags,
                    if (entityCategoriesRefs) db.entityCategories,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sourceEntityRelationships)
                        await $_getPrefetchedData<
                          Entity,
                          $EntitiesTable,
                          Relationship
                        >(
                          currentTable: table,
                          referencedTable: $$EntitiesTableReferences
                              ._sourceEntityRelationshipsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).sourceEntityRelationships,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceEntityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (targetEntityRelationships)
                        await $_getPrefetchedData<
                          Entity,
                          $EntitiesTable,
                          Relationship
                        >(
                          currentTable: table,
                          referencedTable: $$EntitiesTableReferences
                              ._targetEntityRelationshipsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).targetEntityRelationships,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.targetEntityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (fieldProvenanceRowsRefs)
                        await $_getPrefetchedData<
                          Entity,
                          $EntitiesTable,
                          FieldProvenanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$EntitiesTableReferences
                              ._fieldProvenanceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).fieldProvenanceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (candidateEntityProposalsRefs)
                        await $_getPrefetchedData<
                          Entity,
                          $EntitiesTable,
                          CandidateEntityProposal
                        >(
                          currentTable: table,
                          referencedTable: $$EntitiesTableReferences
                              ._candidateEntityProposalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).candidateEntityProposalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.suggestedEntityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entityTagsRefs)
                        await $_getPrefetchedData<
                          Entity,
                          $EntitiesTable,
                          EntityTag
                        >(
                          currentTable: table,
                          referencedTable: $$EntitiesTableReferences
                              ._entityTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).entityTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entityCategoriesRefs)
                        await $_getPrefetchedData<
                          Entity,
                          $EntitiesTable,
                          EntityCategory
                        >(
                          currentTable: table,
                          referencedTable: $$EntitiesTableReferences
                              ._entityCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).entityCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entityId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntitiesTable,
      Entity,
      $$EntitiesTableFilterComposer,
      $$EntitiesTableOrderingComposer,
      $$EntitiesTableAnnotationComposer,
      $$EntitiesTableCreateCompanionBuilder,
      $$EntitiesTableUpdateCompanionBuilder,
      (Entity, $$EntitiesTableReferences),
      Entity,
      PrefetchHooks Function({
        bool sourceEntityRelationships,
        bool targetEntityRelationships,
        bool fieldProvenanceRowsRefs,
        bool candidateEntityProposalsRefs,
        bool entityTagsRefs,
        bool entityCategoriesRefs,
      })
    >;
typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      required String id,
      required String privacyClassification,
      required String lifecycle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String temporalPrecision,
      Value<int?> startYear,
      Value<int?> startMonth,
      Value<int?> startDay,
      Value<int?> endYear,
      Value<int?> endMonth,
      Value<int?> endDay,
      required String title,
      required String normalizedTitle,
      Value<String?> description,
      Value<String?> eventType,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<String> id,
      Value<String> privacyClassification,
      Value<String> lifecycle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> temporalPrecision,
      Value<int?> startYear,
      Value<int?> startMonth,
      Value<int?> startDay,
      Value<int?> endYear,
      Value<int?> endMonth,
      Value<int?> endDay,
      Value<String> title,
      Value<String> normalizedTitle,
      Value<String?> description,
      Value<String?> eventType,
      Value<int> rowid,
    });

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, Event> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RelationshipsTable, List<Relationship>>
  _sourceEventRelationshipsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.relationships,
        aliasName: 'events__id__relationships__source_event_id',
      );

  $$RelationshipsTableProcessedTableManager get sourceEventRelationships {
    final manager = $$RelationshipsTableTableManager(
      $_db,
      $_db.relationships,
    ).filter((f) => f.sourceEventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sourceEventRelationshipsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RelationshipsTable, List<Relationship>>
  _targetEventRelationshipsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.relationships,
        aliasName: 'events__id__relationships__target_event_id',
      );

  $$RelationshipsTableProcessedTableManager get targetEventRelationships {
    final manager = $$RelationshipsTableTableManager(
      $_db,
      $_db.relationships,
    ).filter((f) => f.targetEventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _targetEventRelationshipsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryCandidatesTable, List<MemoryCandidate>>
  _confirmedCandidatesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryCandidates,
    aliasName: 'events__id__memory_candidates__confirmed_event_id',
  );

  $$MemoryCandidatesTableProcessedTableManager get confirmedCandidates {
    final manager =
        $$MemoryCandidatesTableTableManager($_db, $_db.memoryCandidates).filter(
          (f) => f.confirmedEventId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _confirmedCandidatesTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryCandidatesTable, List<MemoryCandidate>>
  _possibleDuplicateCandidatesTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.memoryCandidates,
        aliasName: 'events__id__memory_candidates__possible_duplicate_event_id',
      );

  $$MemoryCandidatesTableProcessedTableManager get possibleDuplicateCandidates {
    final manager =
        $$MemoryCandidatesTableTableManager($_db, $_db.memoryCandidates).filter(
          (f) => f.possibleDuplicateEventId.id.sqlEquals(
            $_itemColumn<String>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _possibleDuplicateCandidatesTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $FieldProvenanceRowsTable,
    List<FieldProvenanceRow>
  >
  _fieldProvenanceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fieldProvenanceRows,
        aliasName: 'events__id__field_provenance__event_id',
      );

  $$FieldProvenanceRowsTableProcessedTableManager get fieldProvenanceRowsRefs {
    final manager = $$FieldProvenanceRowsTableTableManager(
      $_db,
      $_db.fieldProvenanceRows,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _fieldProvenanceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventTagsTable, List<EventTag>>
  _eventTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventTags,
    aliasName: 'events__id__event_tags__event_id',
  );

  $$EventTagsTableProcessedTableManager get eventTagsRefs {
    final manager = $$EventTagsTableTableManager(
      $_db,
      $_db.eventTags,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventCategoriesTable, List<EventCategory>>
  _eventCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventCategories,
    aliasName: 'events__id__event_categories__event_id',
  );

  $$EventCategoriesTableProcessedTableManager get eventCategoriesRefs {
    final manager = $$EventCategoriesTableTableManager(
      $_db,
      $_db.eventCategories,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _eventCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get temporalPrecision => $composableBuilder(
    column: $table.temporalPrecision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startYear => $composableBuilder(
    column: $table.startYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endYear => $composableBuilder(
    column: $table.endYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMonth => $composableBuilder(
    column: $table.endMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedTitle => $composableBuilder(
    column: $table.normalizedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sourceEventRelationships(
    Expression<bool> Function($$RelationshipsTableFilterComposer f) f,
  ) {
    final $$RelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.sourceEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> targetEventRelationships(
    Expression<bool> Function($$RelationshipsTableFilterComposer f) f,
  ) {
    final $$RelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.targetEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> confirmedCandidates(
    Expression<bool> Function($$MemoryCandidatesTableFilterComposer f) f,
  ) {
    final $$MemoryCandidatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.confirmedEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableFilterComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> possibleDuplicateCandidates(
    Expression<bool> Function($$MemoryCandidatesTableFilterComposer f) f,
  ) {
    final $$MemoryCandidatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.possibleDuplicateEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableFilterComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fieldProvenanceRowsRefs(
    Expression<bool> Function($$FieldProvenanceRowsTableFilterComposer f) f,
  ) {
    final $$FieldProvenanceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fieldProvenanceRows,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldProvenanceRowsTableFilterComposer(
            $db: $db,
            $table: $db.fieldProvenanceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventTagsRefs(
    Expression<bool> Function($$EventTagsTableFilterComposer f) f,
  ) {
    final $$EventTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventTags,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventTagsTableFilterComposer(
            $db: $db,
            $table: $db.eventTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventCategoriesRefs(
    Expression<bool> Function($$EventCategoriesTableFilterComposer f) f,
  ) {
    final $$EventCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventCategories,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.eventCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get temporalPrecision => $composableBuilder(
    column: $table.temporalPrecision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startYear => $composableBuilder(
    column: $table.startYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endYear => $composableBuilder(
    column: $table.endYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMonth => $composableBuilder(
    column: $table.endMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedTitle => $composableBuilder(
    column: $table.normalizedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get temporalPrecision => $composableBuilder(
    column: $table.temporalPrecision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startYear =>
      $composableBuilder(column: $table.startYear, builder: (column) => column);

  GeneratedColumn<int> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => column);

  GeneratedColumn<int> get endYear =>
      $composableBuilder(column: $table.endYear, builder: (column) => column);

  GeneratedColumn<int> get endMonth =>
      $composableBuilder(column: $table.endMonth, builder: (column) => column);

  GeneratedColumn<int> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get normalizedTitle => $composableBuilder(
    column: $table.normalizedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  Expression<T> sourceEventRelationships<T extends Object>(
    Expression<T> Function($$RelationshipsTableAnnotationComposer a) f,
  ) {
    final $$RelationshipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.sourceEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableAnnotationComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> targetEventRelationships<T extends Object>(
    Expression<T> Function($$RelationshipsTableAnnotationComposer a) f,
  ) {
    final $$RelationshipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.targetEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableAnnotationComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> confirmedCandidates<T extends Object>(
    Expression<T> Function($$MemoryCandidatesTableAnnotationComposer a) f,
  ) {
    final $$MemoryCandidatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.confirmedEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> possibleDuplicateCandidates<T extends Object>(
    Expression<T> Function($$MemoryCandidatesTableAnnotationComposer a) f,
  ) {
    final $$MemoryCandidatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.possibleDuplicateEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fieldProvenanceRowsRefs<T extends Object>(
    Expression<T> Function($$FieldProvenanceRowsTableAnnotationComposer a) f,
  ) {
    final $$FieldProvenanceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fieldProvenanceRows,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FieldProvenanceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.fieldProvenanceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> eventTagsRefs<T extends Object>(
    Expression<T> Function($$EventTagsTableAnnotationComposer a) f,
  ) {
    final $$EventTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventTags,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.eventTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventCategoriesRefs<T extends Object>(
    Expression<T> Function($$EventCategoriesTableAnnotationComposer a) f,
  ) {
    final $$EventCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventCategories,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.eventCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, $$EventsTableReferences),
          Event,
          PrefetchHooks Function({
            bool sourceEventRelationships,
            bool targetEventRelationships,
            bool confirmedCandidates,
            bool possibleDuplicateCandidates,
            bool fieldProvenanceRowsRefs,
            bool eventTagsRefs,
            bool eventCategoriesRefs,
          })
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> privacyClassification = const Value.absent(),
                Value<String> lifecycle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> temporalPrecision = const Value.absent(),
                Value<int?> startYear = const Value.absent(),
                Value<int?> startMonth = const Value.absent(),
                Value<int?> startDay = const Value.absent(),
                Value<int?> endYear = const Value.absent(),
                Value<int?> endMonth = const Value.absent(),
                Value<int?> endDay = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> normalizedTitle = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> eventType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                temporalPrecision: temporalPrecision,
                startYear: startYear,
                startMonth: startMonth,
                startDay: startDay,
                endYear: endYear,
                endMonth: endMonth,
                endDay: endDay,
                title: title,
                normalizedTitle: normalizedTitle,
                description: description,
                eventType: eventType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String privacyClassification,
                required String lifecycle,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String temporalPrecision,
                Value<int?> startYear = const Value.absent(),
                Value<int?> startMonth = const Value.absent(),
                Value<int?> startDay = const Value.absent(),
                Value<int?> endYear = const Value.absent(),
                Value<int?> endMonth = const Value.absent(),
                Value<int?> endDay = const Value.absent(),
                required String title,
                required String normalizedTitle,
                Value<String?> description = const Value.absent(),
                Value<String?> eventType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                temporalPrecision: temporalPrecision,
                startYear: startYear,
                startMonth: startMonth,
                startDay: startDay,
                endYear: endYear,
                endMonth: endMonth,
                endDay: endDay,
                title: title,
                normalizedTitle: normalizedTitle,
                description: description,
                eventType: eventType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$EventsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceEventRelationships = false,
                targetEventRelationships = false,
                confirmedCandidates = false,
                possibleDuplicateCandidates = false,
                fieldProvenanceRowsRefs = false,
                eventTagsRefs = false,
                eventCategoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sourceEventRelationships) db.relationships,
                    if (targetEventRelationships) db.relationships,
                    if (confirmedCandidates) db.memoryCandidates,
                    if (possibleDuplicateCandidates) db.memoryCandidates,
                    if (fieldProvenanceRowsRefs) db.fieldProvenanceRows,
                    if (eventTagsRefs) db.eventTags,
                    if (eventCategoriesRefs) db.eventCategories,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sourceEventRelationships)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          Relationship
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._sourceEventRelationshipsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).sourceEventRelationships,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceEventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (targetEventRelationships)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          Relationship
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._targetEventRelationshipsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).targetEventRelationships,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.targetEventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (confirmedCandidates)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          MemoryCandidate
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._confirmedCandidatesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).confirmedCandidates,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.confirmedEventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (possibleDuplicateCandidates)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          MemoryCandidate
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._possibleDuplicateCandidatesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).possibleDuplicateCandidates,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.possibleDuplicateEventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (fieldProvenanceRowsRefs)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          FieldProvenanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._fieldProvenanceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).fieldProvenanceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventTagsRefs)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          EventTag
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._eventTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).eventTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventCategoriesRefs)
                        await $_getPrefetchedData<
                          Event,
                          $EventsTable,
                          EventCategory
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._eventCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).eventCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, $$EventsTableReferences),
      Event,
      PrefetchHooks Function({
        bool sourceEventRelationships,
        bool targetEventRelationships,
        bool confirmedCandidates,
        bool possibleDuplicateCandidates,
        bool fieldProvenanceRowsRefs,
        bool eventTagsRefs,
        bool eventCategoriesRefs,
      })
    >;
typedef $$EvidenceRecordsTableCreateCompanionBuilder =
    EvidenceRecordsCompanion Function({
      required String id,
      required String privacyClassification,
      required String lifecycle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String title,
      required String normalizedTitle,
      required String evidenceType,
      Value<String?> summary,
      Value<int> rowid,
    });
typedef $$EvidenceRecordsTableUpdateCompanionBuilder =
    EvidenceRecordsCompanion Function({
      Value<String> id,
      Value<String> privacyClassification,
      Value<String> lifecycle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> title,
      Value<String> normalizedTitle,
      Value<String> evidenceType,
      Value<String?> summary,
      Value<int> rowid,
    });

final class $$EvidenceRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $EvidenceRecordsTable, EvidenceRecord> {
  $$EvidenceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RelationshipsTable, List<Relationship>>
  _sourceEvidenceRelationshipsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.relationships,
        aliasName: 'evidence__id__relationships__source_evidence_id',
      );

  $$RelationshipsTableProcessedTableManager get sourceEvidenceRelationships {
    final manager = $$RelationshipsTableTableManager($_db, $_db.relationships)
        .filter(
          (f) => f.sourceEvidenceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _sourceEvidenceRelationshipsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RelationshipsTable, List<Relationship>>
  _targetEvidenceRelationshipsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.relationships,
        aliasName: 'evidence__id__relationships__target_evidence_id',
      );

  $$RelationshipsTableProcessedTableManager get targetEvidenceRelationships {
    final manager = $$RelationshipsTableTableManager($_db, $_db.relationships)
        .filter(
          (f) => f.targetEvidenceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _targetEvidenceRelationshipsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<Attachment>>
  _attachmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'evidence__id__attachments__evidence_id',
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.evidenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryCandidatesTable, List<MemoryCandidate>>
  _memoryCandidatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryCandidates,
    aliasName: 'evidence__id__memory_candidates__source_evidence_id',
  );

  $$MemoryCandidatesTableProcessedTableManager get memoryCandidatesRefs {
    final manager =
        $$MemoryCandidatesTableTableManager($_db, $_db.memoryCandidates).filter(
          (f) => f.sourceEvidenceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _memoryCandidatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $FieldProvenanceRowsTable,
    List<FieldProvenanceRow>
  >
  _fieldProvenanceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fieldProvenanceRows,
        aliasName: 'evidence__id__field_provenance__evidence_id',
      );

  $$FieldProvenanceRowsTableProcessedTableManager get fieldProvenanceRowsRefs {
    final manager = $$FieldProvenanceRowsTableTableManager(
      $_db,
      $_db.fieldProvenanceRows,
    ).filter((f) => f.evidenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _fieldProvenanceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EvidenceTagsTable, List<EvidenceTag>>
  _evidenceTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.evidenceTags,
    aliasName: 'evidence__id__evidence_tags__evidence_id',
  );

  $$EvidenceTagsTableProcessedTableManager get evidenceTagsRefs {
    final manager = $$EvidenceTagsTableTableManager(
      $_db,
      $_db.evidenceTags,
    ).filter((f) => f.evidenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_evidenceTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EvidenceCategoriesTable, List<EvidenceCategory>>
  _evidenceCategoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.evidenceCategories,
        aliasName: 'evidence__id__evidence_categories__evidence_id',
      );

  $$EvidenceCategoriesTableProcessedTableManager get evidenceCategoriesRefs {
    final manager = $$EvidenceCategoriesTableTableManager(
      $_db,
      $_db.evidenceCategories,
    ).filter((f) => f.evidenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _evidenceCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EvidenceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $EvidenceRecordsTable> {
  $$EvidenceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedTitle => $composableBuilder(
    column: $table.normalizedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sourceEvidenceRelationships(
    Expression<bool> Function($$RelationshipsTableFilterComposer f) f,
  ) {
    final $$RelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.sourceEvidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> targetEvidenceRelationships(
    Expression<bool> Function($$RelationshipsTableFilterComposer f) f,
  ) {
    final $$RelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.targetEvidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.evidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> memoryCandidatesRefs(
    Expression<bool> Function($$MemoryCandidatesTableFilterComposer f) f,
  ) {
    final $$MemoryCandidatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.sourceEvidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableFilterComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fieldProvenanceRowsRefs(
    Expression<bool> Function($$FieldProvenanceRowsTableFilterComposer f) f,
  ) {
    final $$FieldProvenanceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fieldProvenanceRows,
      getReferencedColumn: (t) => t.evidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldProvenanceRowsTableFilterComposer(
            $db: $db,
            $table: $db.fieldProvenanceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> evidenceTagsRefs(
    Expression<bool> Function($$EvidenceTagsTableFilterComposer f) f,
  ) {
    final $$EvidenceTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceTags,
      getReferencedColumn: (t) => t.evidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceTagsTableFilterComposer(
            $db: $db,
            $table: $db.evidenceTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> evidenceCategoriesRefs(
    Expression<bool> Function($$EvidenceCategoriesTableFilterComposer f) f,
  ) {
    final $$EvidenceCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceCategories,
      getReferencedColumn: (t) => t.evidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.evidenceCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EvidenceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidenceRecordsTable> {
  $$EvidenceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedTitle => $composableBuilder(
    column: $table.normalizedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EvidenceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidenceRecordsTable> {
  $$EvidenceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get normalizedTitle => $composableBuilder(
    column: $table.normalizedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceType => $composableBuilder(
    column: $table.evidenceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  Expression<T> sourceEvidenceRelationships<T extends Object>(
    Expression<T> Function($$RelationshipsTableAnnotationComposer a) f,
  ) {
    final $$RelationshipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.sourceEvidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableAnnotationComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> targetEvidenceRelationships<T extends Object>(
    Expression<T> Function($$RelationshipsTableAnnotationComposer a) f,
  ) {
    final $$RelationshipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.targetEvidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableAnnotationComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.evidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> memoryCandidatesRefs<T extends Object>(
    Expression<T> Function($$MemoryCandidatesTableAnnotationComposer a) f,
  ) {
    final $$MemoryCandidatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.sourceEvidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fieldProvenanceRowsRefs<T extends Object>(
    Expression<T> Function($$FieldProvenanceRowsTableAnnotationComposer a) f,
  ) {
    final $$FieldProvenanceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fieldProvenanceRows,
          getReferencedColumn: (t) => t.evidenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FieldProvenanceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.fieldProvenanceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> evidenceTagsRefs<T extends Object>(
    Expression<T> Function($$EvidenceTagsTableAnnotationComposer a) f,
  ) {
    final $$EvidenceTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceTags,
      getReferencedColumn: (t) => t.evidenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> evidenceCategoriesRefs<T extends Object>(
    Expression<T> Function($$EvidenceCategoriesTableAnnotationComposer a) f,
  ) {
    final $$EvidenceCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.evidenceCategories,
          getReferencedColumn: (t) => t.evidenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EvidenceCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.evidenceCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EvidenceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvidenceRecordsTable,
          EvidenceRecord,
          $$EvidenceRecordsTableFilterComposer,
          $$EvidenceRecordsTableOrderingComposer,
          $$EvidenceRecordsTableAnnotationComposer,
          $$EvidenceRecordsTableCreateCompanionBuilder,
          $$EvidenceRecordsTableUpdateCompanionBuilder,
          (EvidenceRecord, $$EvidenceRecordsTableReferences),
          EvidenceRecord,
          PrefetchHooks Function({
            bool sourceEvidenceRelationships,
            bool targetEvidenceRelationships,
            bool attachmentsRefs,
            bool memoryCandidatesRefs,
            bool fieldProvenanceRowsRefs,
            bool evidenceTagsRefs,
            bool evidenceCategoriesRefs,
          })
        > {
  $$EvidenceRecordsTableTableManager(
    _$AppDatabase db,
    $EvidenceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidenceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidenceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidenceRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> privacyClassification = const Value.absent(),
                Value<String> lifecycle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> normalizedTitle = const Value.absent(),
                Value<String> evidenceType = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvidenceRecordsCompanion(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                title: title,
                normalizedTitle: normalizedTitle,
                evidenceType: evidenceType,
                summary: summary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String privacyClassification,
                required String lifecycle,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String title,
                required String normalizedTitle,
                required String evidenceType,
                Value<String?> summary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvidenceRecordsCompanion.insert(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                title: title,
                normalizedTitle: normalizedTitle,
                evidenceType: evidenceType,
                summary: summary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EvidenceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceEvidenceRelationships = false,
                targetEvidenceRelationships = false,
                attachmentsRefs = false,
                memoryCandidatesRefs = false,
                fieldProvenanceRowsRefs = false,
                evidenceTagsRefs = false,
                evidenceCategoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sourceEvidenceRelationships) db.relationships,
                    if (targetEvidenceRelationships) db.relationships,
                    if (attachmentsRefs) db.attachments,
                    if (memoryCandidatesRefs) db.memoryCandidates,
                    if (fieldProvenanceRowsRefs) db.fieldProvenanceRows,
                    if (evidenceTagsRefs) db.evidenceTags,
                    if (evidenceCategoriesRefs) db.evidenceCategories,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sourceEvidenceRelationships)
                        await $_getPrefetchedData<
                          EvidenceRecord,
                          $EvidenceRecordsTable,
                          Relationship
                        >(
                          currentTable: table,
                          referencedTable: $$EvidenceRecordsTableReferences
                              ._sourceEvidenceRelationshipsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EvidenceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).sourceEvidenceRelationships,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceEvidenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (targetEvidenceRelationships)
                        await $_getPrefetchedData<
                          EvidenceRecord,
                          $EvidenceRecordsTable,
                          Relationship
                        >(
                          currentTable: table,
                          referencedTable: $$EvidenceRecordsTableReferences
                              ._targetEvidenceRelationshipsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EvidenceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).targetEvidenceRelationships,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.targetEvidenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attachmentsRefs)
                        await $_getPrefetchedData<
                          EvidenceRecord,
                          $EvidenceRecordsTable,
                          Attachment
                        >(
                          currentTable: table,
                          referencedTable: $$EvidenceRecordsTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EvidenceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.evidenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (memoryCandidatesRefs)
                        await $_getPrefetchedData<
                          EvidenceRecord,
                          $EvidenceRecordsTable,
                          MemoryCandidate
                        >(
                          currentTable: table,
                          referencedTable: $$EvidenceRecordsTableReferences
                              ._memoryCandidatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EvidenceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryCandidatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceEvidenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (fieldProvenanceRowsRefs)
                        await $_getPrefetchedData<
                          EvidenceRecord,
                          $EvidenceRecordsTable,
                          FieldProvenanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$EvidenceRecordsTableReferences
                              ._fieldProvenanceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EvidenceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).fieldProvenanceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.evidenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (evidenceTagsRefs)
                        await $_getPrefetchedData<
                          EvidenceRecord,
                          $EvidenceRecordsTable,
                          EvidenceTag
                        >(
                          currentTable: table,
                          referencedTable: $$EvidenceRecordsTableReferences
                              ._evidenceTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EvidenceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).evidenceTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.evidenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (evidenceCategoriesRefs)
                        await $_getPrefetchedData<
                          EvidenceRecord,
                          $EvidenceRecordsTable,
                          EvidenceCategory
                        >(
                          currentTable: table,
                          referencedTable: $$EvidenceRecordsTableReferences
                              ._evidenceCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EvidenceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).evidenceCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.evidenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EvidenceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvidenceRecordsTable,
      EvidenceRecord,
      $$EvidenceRecordsTableFilterComposer,
      $$EvidenceRecordsTableOrderingComposer,
      $$EvidenceRecordsTableAnnotationComposer,
      $$EvidenceRecordsTableCreateCompanionBuilder,
      $$EvidenceRecordsTableUpdateCompanionBuilder,
      (EvidenceRecord, $$EvidenceRecordsTableReferences),
      EvidenceRecord,
      PrefetchHooks Function({
        bool sourceEvidenceRelationships,
        bool targetEvidenceRelationships,
        bool attachmentsRefs,
        bool memoryCandidatesRefs,
        bool fieldProvenanceRowsRefs,
        bool evidenceTagsRefs,
        bool evidenceCategoriesRefs,
      })
    >;
typedef $$RelationshipsTableCreateCompanionBuilder =
    RelationshipsCompanion Function({
      required String id,
      required String privacyClassification,
      required String lifecycle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> sourceEntityId,
      Value<String?> sourceEventId,
      Value<String?> sourceEvidenceId,
      Value<String?> targetEntityId,
      Value<String?> targetEventId,
      Value<String?> targetEvidenceId,
      required String relationshipType,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$RelationshipsTableUpdateCompanionBuilder =
    RelationshipsCompanion Function({
      Value<String> id,
      Value<String> privacyClassification,
      Value<String> lifecycle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> sourceEntityId,
      Value<String?> sourceEventId,
      Value<String?> sourceEvidenceId,
      Value<String?> targetEntityId,
      Value<String?> targetEventId,
      Value<String?> targetEvidenceId,
      Value<String> relationshipType,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$RelationshipsTableReferences
    extends BaseReferences<_$AppDatabase, $RelationshipsTable, Relationship> {
  $$RelationshipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EntitiesTable _sourceEntityIdTable(_$AppDatabase db) =>
      db.entities.createAlias('relationships__source_entity_id__entities__id');

  $$EntitiesTableProcessedTableManager? get sourceEntityId {
    final $_column = $_itemColumn<String>('source_entity_id');
    if ($_column == null) return null;
    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceEntityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EventsTable _sourceEventIdTable(_$AppDatabase db) =>
      db.events.createAlias('relationships__source_event_id__events__id');

  $$EventsTableProcessedTableManager? get sourceEventId {
    final $_column = $_itemColumn<String>('source_event_id');
    if ($_column == null) return null;
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EvidenceRecordsTable _sourceEvidenceIdTable(_$AppDatabase db) => db
      .evidenceRecords
      .createAlias('relationships__source_evidence_id__evidence__id');

  $$EvidenceRecordsTableProcessedTableManager? get sourceEvidenceId {
    final $_column = $_itemColumn<String>('source_evidence_id');
    if ($_column == null) return null;
    final manager = $$EvidenceRecordsTableTableManager(
      $_db,
      $_db.evidenceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceEvidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EntitiesTable _targetEntityIdTable(_$AppDatabase db) =>
      db.entities.createAlias('relationships__target_entity_id__entities__id');

  $$EntitiesTableProcessedTableManager? get targetEntityId {
    final $_column = $_itemColumn<String>('target_entity_id');
    if ($_column == null) return null;
    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetEntityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EventsTable _targetEventIdTable(_$AppDatabase db) =>
      db.events.createAlias('relationships__target_event_id__events__id');

  $$EventsTableProcessedTableManager? get targetEventId {
    final $_column = $_itemColumn<String>('target_event_id');
    if ($_column == null) return null;
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EvidenceRecordsTable _targetEvidenceIdTable(_$AppDatabase db) => db
      .evidenceRecords
      .createAlias('relationships__target_evidence_id__evidence__id');

  $$EvidenceRecordsTableProcessedTableManager? get targetEvidenceId {
    final $_column = $_itemColumn<String>('target_evidence_id');
    if ($_column == null) return null;
    final manager = $$EvidenceRecordsTableTableManager(
      $_db,
      $_db.evidenceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetEvidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $FieldProvenanceRowsTable,
    List<FieldProvenanceRow>
  >
  _fieldProvenanceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fieldProvenanceRows,
        aliasName: 'relationships__id__field_provenance__relationship_id',
      );

  $$FieldProvenanceRowsTableProcessedTableManager get fieldProvenanceRowsRefs {
    final manager = $$FieldProvenanceRowsTableTableManager(
      $_db,
      $_db.fieldProvenanceRows,
    ).filter((f) => f.relationshipId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _fieldProvenanceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RelationshipsTableFilterComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$EntitiesTableFilterComposer get sourceEntityId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEntityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableFilterComposer get sourceEventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EvidenceRecordsTableFilterComposer get sourceEvidenceId {
    final $$EvidenceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEvidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableFilterComposer get targetEntityId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetEntityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableFilterComposer get targetEventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EvidenceRecordsTableFilterComposer get targetEvidenceId {
    final $$EvidenceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetEvidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> fieldProvenanceRowsRefs(
    Expression<bool> Function($$FieldProvenanceRowsTableFilterComposer f) f,
  ) {
    final $$FieldProvenanceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fieldProvenanceRows,
      getReferencedColumn: (t) => t.relationshipId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldProvenanceRowsTableFilterComposer(
            $db: $db,
            $table: $db.fieldProvenanceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RelationshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntitiesTableOrderingComposer get sourceEntityId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEntityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableOrderingComposer get sourceEventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EvidenceRecordsTableOrderingComposer get sourceEvidenceId {
    final $$EvidenceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEvidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableOrderingComposer get targetEntityId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetEntityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableOrderingComposer get targetEventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EvidenceRecordsTableOrderingComposer get targetEvidenceId {
    final $$EvidenceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetEvidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$EntitiesTableAnnotationComposer get sourceEntityId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEntityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableAnnotationComposer get sourceEventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EvidenceRecordsTableAnnotationComposer get sourceEvidenceId {
    final $$EvidenceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEvidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableAnnotationComposer get targetEntityId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetEntityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableAnnotationComposer get targetEventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EvidenceRecordsTableAnnotationComposer get targetEvidenceId {
    final $$EvidenceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetEvidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> fieldProvenanceRowsRefs<T extends Object>(
    Expression<T> Function($$FieldProvenanceRowsTableAnnotationComposer a) f,
  ) {
    final $$FieldProvenanceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fieldProvenanceRows,
          getReferencedColumn: (t) => t.relationshipId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FieldProvenanceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.fieldProvenanceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RelationshipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RelationshipsTable,
          Relationship,
          $$RelationshipsTableFilterComposer,
          $$RelationshipsTableOrderingComposer,
          $$RelationshipsTableAnnotationComposer,
          $$RelationshipsTableCreateCompanionBuilder,
          $$RelationshipsTableUpdateCompanionBuilder,
          (Relationship, $$RelationshipsTableReferences),
          Relationship,
          PrefetchHooks Function({
            bool sourceEntityId,
            bool sourceEventId,
            bool sourceEvidenceId,
            bool targetEntityId,
            bool targetEventId,
            bool targetEvidenceId,
            bool fieldProvenanceRowsRefs,
          })
        > {
  $$RelationshipsTableTableManager(_$AppDatabase db, $RelationshipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelationshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelationshipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> privacyClassification = const Value.absent(),
                Value<String> lifecycle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> sourceEntityId = const Value.absent(),
                Value<String?> sourceEventId = const Value.absent(),
                Value<String?> sourceEvidenceId = const Value.absent(),
                Value<String?> targetEntityId = const Value.absent(),
                Value<String?> targetEventId = const Value.absent(),
                Value<String?> targetEvidenceId = const Value.absent(),
                Value<String> relationshipType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationshipsCompanion(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                sourceEntityId: sourceEntityId,
                sourceEventId: sourceEventId,
                sourceEvidenceId: sourceEvidenceId,
                targetEntityId: targetEntityId,
                targetEventId: targetEventId,
                targetEvidenceId: targetEvidenceId,
                relationshipType: relationshipType,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String privacyClassification,
                required String lifecycle,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> sourceEntityId = const Value.absent(),
                Value<String?> sourceEventId = const Value.absent(),
                Value<String?> sourceEvidenceId = const Value.absent(),
                Value<String?> targetEntityId = const Value.absent(),
                Value<String?> targetEventId = const Value.absent(),
                Value<String?> targetEvidenceId = const Value.absent(),
                required String relationshipType,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationshipsCompanion.insert(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                sourceEntityId: sourceEntityId,
                sourceEventId: sourceEventId,
                sourceEvidenceId: sourceEvidenceId,
                targetEntityId: targetEntityId,
                targetEventId: targetEventId,
                targetEvidenceId: targetEvidenceId,
                relationshipType: relationshipType,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RelationshipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceEntityId = false,
                sourceEventId = false,
                sourceEvidenceId = false,
                targetEntityId = false,
                targetEventId = false,
                targetEvidenceId = false,
                fieldProvenanceRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fieldProvenanceRowsRefs) db.fieldProvenanceRows,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceEntityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceEntityId,
                                    referencedTable:
                                        $$RelationshipsTableReferences
                                            ._sourceEntityIdTable(db),
                                    referencedColumn:
                                        $$RelationshipsTableReferences
                                            ._sourceEntityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceEventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceEventId,
                                    referencedTable:
                                        $$RelationshipsTableReferences
                                            ._sourceEventIdTable(db),
                                    referencedColumn:
                                        $$RelationshipsTableReferences
                                            ._sourceEventIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceEvidenceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceEvidenceId,
                                    referencedTable:
                                        $$RelationshipsTableReferences
                                            ._sourceEvidenceIdTable(db),
                                    referencedColumn:
                                        $$RelationshipsTableReferences
                                            ._sourceEvidenceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (targetEntityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetEntityId,
                                    referencedTable:
                                        $$RelationshipsTableReferences
                                            ._targetEntityIdTable(db),
                                    referencedColumn:
                                        $$RelationshipsTableReferences
                                            ._targetEntityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (targetEventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetEventId,
                                    referencedTable:
                                        $$RelationshipsTableReferences
                                            ._targetEventIdTable(db),
                                    referencedColumn:
                                        $$RelationshipsTableReferences
                                            ._targetEventIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (targetEvidenceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetEvidenceId,
                                    referencedTable:
                                        $$RelationshipsTableReferences
                                            ._targetEvidenceIdTable(db),
                                    referencedColumn:
                                        $$RelationshipsTableReferences
                                            ._targetEvidenceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (fieldProvenanceRowsRefs)
                        await $_getPrefetchedData<
                          Relationship,
                          $RelationshipsTable,
                          FieldProvenanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$RelationshipsTableReferences
                              ._fieldProvenanceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RelationshipsTableReferences(
                                db,
                                table,
                                p0,
                              ).fieldProvenanceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.relationshipId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RelationshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RelationshipsTable,
      Relationship,
      $$RelationshipsTableFilterComposer,
      $$RelationshipsTableOrderingComposer,
      $$RelationshipsTableAnnotationComposer,
      $$RelationshipsTableCreateCompanionBuilder,
      $$RelationshipsTableUpdateCompanionBuilder,
      (Relationship, $$RelationshipsTableReferences),
      Relationship,
      PrefetchHooks Function({
        bool sourceEntityId,
        bool sourceEventId,
        bool sourceEvidenceId,
        bool targetEntityId,
        bool targetEventId,
        bool targetEvidenceId,
        bool fieldProvenanceRowsRefs,
      })
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String privacyClassification,
      required String lifecycle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String evidenceId,
      Value<String?> displayName,
      Value<String?> relativePath,
      Value<String?> thumbnailRelativePath,
      required String mimeType,
      required int byteSize,
      Value<String?> checksum,
      required String storageState,
      required String importMode,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> privacyClassification,
      Value<String> lifecycle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> evidenceId,
      Value<String?> displayName,
      Value<String?> relativePath,
      Value<String?> thumbnailRelativePath,
      Value<String> mimeType,
      Value<int> byteSize,
      Value<String?> checksum,
      Value<String> storageState,
      Value<String> importMode,
      Value<int> rowid,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EvidenceRecordsTable _evidenceIdTable(_$AppDatabase db) =>
      db.evidenceRecords.createAlias('attachments__evidence_id__evidence__id');

  $$EvidenceRecordsTableProcessedTableManager get evidenceId {
    final $_column = $_itemColumn<String>('evidence_id')!;

    final manager = $$EvidenceRecordsTableTableManager(
      $_db,
      $_db.evidenceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_evidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $FieldProvenanceRowsTable,
    List<FieldProvenanceRow>
  >
  _fieldProvenanceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fieldProvenanceRows,
        aliasName: 'attachments__id__field_provenance__attachment_id',
      );

  $$FieldProvenanceRowsTableProcessedTableManager get fieldProvenanceRowsRefs {
    final manager = $$FieldProvenanceRowsTableTableManager(
      $_db,
      $_db.fieldProvenanceRows,
    ).filter((f) => f.attachmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _fieldProvenanceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailRelativePath => $composableBuilder(
    column: $table.thumbnailRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageState => $composableBuilder(
    column: $table.storageState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importMode => $composableBuilder(
    column: $table.importMode,
    builder: (column) => ColumnFilters(column),
  );

  $$EvidenceRecordsTableFilterComposer get evidenceId {
    final $$EvidenceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> fieldProvenanceRowsRefs(
    Expression<bool> Function($$FieldProvenanceRowsTableFilterComposer f) f,
  ) {
    final $$FieldProvenanceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fieldProvenanceRows,
      getReferencedColumn: (t) => t.attachmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldProvenanceRowsTableFilterComposer(
            $db: $db,
            $table: $db.fieldProvenanceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailRelativePath => $composableBuilder(
    column: $table.thumbnailRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageState => $composableBuilder(
    column: $table.storageState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importMode => $composableBuilder(
    column: $table.importMode,
    builder: (column) => ColumnOrderings(column),
  );

  $$EvidenceRecordsTableOrderingComposer get evidenceId {
    final $$EvidenceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailRelativePath => $composableBuilder(
    column: $table.thumbnailRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get storageState => $composableBuilder(
    column: $table.storageState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get importMode => $composableBuilder(
    column: $table.importMode,
    builder: (column) => column,
  );

  $$EvidenceRecordsTableAnnotationComposer get evidenceId {
    final $$EvidenceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> fieldProvenanceRowsRefs<T extends Object>(
    Expression<T> Function($$FieldProvenanceRowsTableAnnotationComposer a) f,
  ) {
    final $$FieldProvenanceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fieldProvenanceRows,
          getReferencedColumn: (t) => t.attachmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FieldProvenanceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.fieldProvenanceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (Attachment, $$AttachmentsTableReferences),
          Attachment,
          PrefetchHooks Function({
            bool evidenceId,
            bool fieldProvenanceRowsRefs,
          })
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> privacyClassification = const Value.absent(),
                Value<String> lifecycle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> evidenceId = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> relativePath = const Value.absent(),
                Value<String?> thumbnailRelativePath = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<String> storageState = const Value.absent(),
                Value<String> importMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                evidenceId: evidenceId,
                displayName: displayName,
                relativePath: relativePath,
                thumbnailRelativePath: thumbnailRelativePath,
                mimeType: mimeType,
                byteSize: byteSize,
                checksum: checksum,
                storageState: storageState,
                importMode: importMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String privacyClassification,
                required String lifecycle,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String evidenceId,
                Value<String?> displayName = const Value.absent(),
                Value<String?> relativePath = const Value.absent(),
                Value<String?> thumbnailRelativePath = const Value.absent(),
                required String mimeType,
                required int byteSize,
                Value<String?> checksum = const Value.absent(),
                required String storageState,
                required String importMode,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                evidenceId: evidenceId,
                displayName: displayName,
                relativePath: relativePath,
                thumbnailRelativePath: thumbnailRelativePath,
                mimeType: mimeType,
                byteSize: byteSize,
                checksum: checksum,
                storageState: storageState,
                importMode: importMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({evidenceId = false, fieldProvenanceRowsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fieldProvenanceRowsRefs) db.fieldProvenanceRows,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (evidenceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.evidenceId,
                                    referencedTable:
                                        $$AttachmentsTableReferences
                                            ._evidenceIdTable(db),
                                    referencedColumn:
                                        $$AttachmentsTableReferences
                                            ._evidenceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (fieldProvenanceRowsRefs)
                        await $_getPrefetchedData<
                          Attachment,
                          $AttachmentsTable,
                          FieldProvenanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$AttachmentsTableReferences
                              ._fieldProvenanceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AttachmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).fieldProvenanceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.attachmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (Attachment, $$AttachmentsTableReferences),
      Attachment,
      PrefetchHooks Function({bool evidenceId, bool fieldProvenanceRowsRefs})
    >;
typedef $$MemoryCandidatesTableCreateCompanionBuilder =
    MemoryCandidatesCompanion Function({
      required String id,
      required String privacyClassification,
      required String lifecycle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String temporalPrecision,
      Value<int?> startYear,
      Value<int?> startMonth,
      Value<int?> startDay,
      Value<int?> endYear,
      Value<int?> endMonth,
      Value<int?> endDay,
      required String title,
      Value<String?> description,
      Value<String?> sourceEvidenceId,
      Value<String?> confirmedEventId,
      Value<String> documentType,
      Value<String> reviewStatus,
      Value<double?> overallConfidence,
      Value<String?> possibleDuplicateEventId,
      Value<int> rowid,
    });
typedef $$MemoryCandidatesTableUpdateCompanionBuilder =
    MemoryCandidatesCompanion Function({
      Value<String> id,
      Value<String> privacyClassification,
      Value<String> lifecycle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> temporalPrecision,
      Value<int?> startYear,
      Value<int?> startMonth,
      Value<int?> startDay,
      Value<int?> endYear,
      Value<int?> endMonth,
      Value<int?> endDay,
      Value<String> title,
      Value<String?> description,
      Value<String?> sourceEvidenceId,
      Value<String?> confirmedEventId,
      Value<String> documentType,
      Value<String> reviewStatus,
      Value<double?> overallConfidence,
      Value<String?> possibleDuplicateEventId,
      Value<int> rowid,
    });

final class $$MemoryCandidatesTableReferences
    extends
        BaseReferences<_$AppDatabase, $MemoryCandidatesTable, MemoryCandidate> {
  $$MemoryCandidatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EvidenceRecordsTable _sourceEvidenceIdTable(_$AppDatabase db) => db
      .evidenceRecords
      .createAlias('memory_candidates__source_evidence_id__evidence__id');

  $$EvidenceRecordsTableProcessedTableManager? get sourceEvidenceId {
    final $_column = $_itemColumn<String>('source_evidence_id');
    if ($_column == null) return null;
    final manager = $$EvidenceRecordsTableTableManager(
      $_db,
      $_db.evidenceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceEvidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EventsTable _confirmedEventIdTable(_$AppDatabase db) => db.events
      .createAlias('memory_candidates__confirmed_event_id__events__id');

  $$EventsTableProcessedTableManager? get confirmedEventId {
    final $_column = $_itemColumn<String>('confirmed_event_id');
    if ($_column == null) return null;
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_confirmedEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EventsTable _possibleDuplicateEventIdTable(_$AppDatabase db) =>
      db.events.createAlias(
        'memory_candidates__possible_duplicate_event_id__events__id',
      );

  $$EventsTableProcessedTableManager? get possibleDuplicateEventId {
    final $_column = $_itemColumn<String>('possible_duplicate_event_id');
    if ($_column == null) return null;
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _possibleDuplicateEventIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $FieldProvenanceRowsTable,
    List<FieldProvenanceRow>
  >
  _fieldProvenanceRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fieldProvenanceRows,
        aliasName:
            'memory_candidates__id__field_provenance__memory_candidate_id',
      );

  $$FieldProvenanceRowsTableProcessedTableManager get fieldProvenanceRowsRefs {
    final manager =
        $$FieldProvenanceRowsTableTableManager(
          $_db,
          $_db.fieldProvenanceRows,
        ).filter(
          (f) => f.memoryCandidateId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _fieldProvenanceRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CandidateExtractedFieldsTable,
    List<CandidateExtractedField>
  >
  _candidateExtractedFieldsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.candidateExtractedFields,
        aliasName:
            'memory_candidates__id__candidate_extracted_fields__candidate_id',
      );

  $$CandidateExtractedFieldsTableProcessedTableManager
  get candidateExtractedFieldsRefs {
    final manager = $$CandidateExtractedFieldsTableTableManager(
      $_db,
      $_db.candidateExtractedFields,
    ).filter((f) => f.candidateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _candidateExtractedFieldsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CandidateEntityProposalsTable,
    List<CandidateEntityProposal>
  >
  _candidateEntityProposalsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.candidateEntityProposals,
        aliasName:
            'memory_candidates__id__candidate_entity_proposals__candidate_id',
      );

  $$CandidateEntityProposalsTableProcessedTableManager
  get candidateEntityProposalsRefs {
    final manager = $$CandidateEntityProposalsTableTableManager(
      $_db,
      $_db.candidateEntityProposals,
    ).filter((f) => f.candidateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _candidateEntityProposalsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemoryCandidatesTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryCandidatesTable> {
  $$MemoryCandidatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get temporalPrecision => $composableBuilder(
    column: $table.temporalPrecision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startYear => $composableBuilder(
    column: $table.startYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endYear => $composableBuilder(
    column: $table.endYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMonth => $composableBuilder(
    column: $table.endMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallConfidence => $composableBuilder(
    column: $table.overallConfidence,
    builder: (column) => ColumnFilters(column),
  );

  $$EvidenceRecordsTableFilterComposer get sourceEvidenceId {
    final $$EvidenceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEvidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableFilterComposer get confirmedEventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.confirmedEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableFilterComposer get possibleDuplicateEventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.possibleDuplicateEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> fieldProvenanceRowsRefs(
    Expression<bool> Function($$FieldProvenanceRowsTableFilterComposer f) f,
  ) {
    final $$FieldProvenanceRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fieldProvenanceRows,
      getReferencedColumn: (t) => t.memoryCandidateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldProvenanceRowsTableFilterComposer(
            $db: $db,
            $table: $db.fieldProvenanceRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> candidateExtractedFieldsRefs(
    Expression<bool> Function($$CandidateExtractedFieldsTableFilterComposer f)
    f,
  ) {
    final $$CandidateExtractedFieldsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.candidateExtractedFields,
          getReferencedColumn: (t) => t.candidateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CandidateExtractedFieldsTableFilterComposer(
                $db: $db,
                $table: $db.candidateExtractedFields,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> candidateEntityProposalsRefs(
    Expression<bool> Function($$CandidateEntityProposalsTableFilterComposer f)
    f,
  ) {
    final $$CandidateEntityProposalsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.candidateEntityProposals,
          getReferencedColumn: (t) => t.candidateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CandidateEntityProposalsTableFilterComposer(
                $db: $db,
                $table: $db.candidateEntityProposals,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MemoryCandidatesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryCandidatesTable> {
  $$MemoryCandidatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get temporalPrecision => $composableBuilder(
    column: $table.temporalPrecision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startYear => $composableBuilder(
    column: $table.startYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endYear => $composableBuilder(
    column: $table.endYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMonth => $composableBuilder(
    column: $table.endMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallConfidence => $composableBuilder(
    column: $table.overallConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$EvidenceRecordsTableOrderingComposer get sourceEvidenceId {
    final $$EvidenceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEvidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableOrderingComposer get confirmedEventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.confirmedEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableOrderingComposer get possibleDuplicateEventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.possibleDuplicateEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryCandidatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryCandidatesTable> {
  $$MemoryCandidatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get temporalPrecision => $composableBuilder(
    column: $table.temporalPrecision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startYear =>
      $composableBuilder(column: $table.startYear, builder: (column) => column);

  GeneratedColumn<int> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => column);

  GeneratedColumn<int> get endYear =>
      $composableBuilder(column: $table.endYear, builder: (column) => column);

  GeneratedColumn<int> get endMonth =>
      $composableBuilder(column: $table.endMonth, builder: (column) => column);

  GeneratedColumn<int> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overallConfidence => $composableBuilder(
    column: $table.overallConfidence,
    builder: (column) => column,
  );

  $$EvidenceRecordsTableAnnotationComposer get sourceEvidenceId {
    final $$EvidenceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEvidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableAnnotationComposer get confirmedEventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.confirmedEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableAnnotationComposer get possibleDuplicateEventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.possibleDuplicateEventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> fieldProvenanceRowsRefs<T extends Object>(
    Expression<T> Function($$FieldProvenanceRowsTableAnnotationComposer a) f,
  ) {
    final $$FieldProvenanceRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fieldProvenanceRows,
          getReferencedColumn: (t) => t.memoryCandidateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FieldProvenanceRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.fieldProvenanceRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> candidateExtractedFieldsRefs<T extends Object>(
    Expression<T> Function($$CandidateExtractedFieldsTableAnnotationComposer a)
    f,
  ) {
    final $$CandidateExtractedFieldsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.candidateExtractedFields,
          getReferencedColumn: (t) => t.candidateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CandidateExtractedFieldsTableAnnotationComposer(
                $db: $db,
                $table: $db.candidateExtractedFields,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> candidateEntityProposalsRefs<T extends Object>(
    Expression<T> Function($$CandidateEntityProposalsTableAnnotationComposer a)
    f,
  ) {
    final $$CandidateEntityProposalsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.candidateEntityProposals,
          getReferencedColumn: (t) => t.candidateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CandidateEntityProposalsTableAnnotationComposer(
                $db: $db,
                $table: $db.candidateEntityProposals,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MemoryCandidatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryCandidatesTable,
          MemoryCandidate,
          $$MemoryCandidatesTableFilterComposer,
          $$MemoryCandidatesTableOrderingComposer,
          $$MemoryCandidatesTableAnnotationComposer,
          $$MemoryCandidatesTableCreateCompanionBuilder,
          $$MemoryCandidatesTableUpdateCompanionBuilder,
          (MemoryCandidate, $$MemoryCandidatesTableReferences),
          MemoryCandidate,
          PrefetchHooks Function({
            bool sourceEvidenceId,
            bool confirmedEventId,
            bool possibleDuplicateEventId,
            bool fieldProvenanceRowsRefs,
            bool candidateExtractedFieldsRefs,
            bool candidateEntityProposalsRefs,
          })
        > {
  $$MemoryCandidatesTableTableManager(
    _$AppDatabase db,
    $MemoryCandidatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryCandidatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryCandidatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryCandidatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> privacyClassification = const Value.absent(),
                Value<String> lifecycle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> temporalPrecision = const Value.absent(),
                Value<int?> startYear = const Value.absent(),
                Value<int?> startMonth = const Value.absent(),
                Value<int?> startDay = const Value.absent(),
                Value<int?> endYear = const Value.absent(),
                Value<int?> endMonth = const Value.absent(),
                Value<int?> endDay = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> sourceEvidenceId = const Value.absent(),
                Value<String?> confirmedEventId = const Value.absent(),
                Value<String> documentType = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<double?> overallConfidence = const Value.absent(),
                Value<String?> possibleDuplicateEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryCandidatesCompanion(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                temporalPrecision: temporalPrecision,
                startYear: startYear,
                startMonth: startMonth,
                startDay: startDay,
                endYear: endYear,
                endMonth: endMonth,
                endDay: endDay,
                title: title,
                description: description,
                sourceEvidenceId: sourceEvidenceId,
                confirmedEventId: confirmedEventId,
                documentType: documentType,
                reviewStatus: reviewStatus,
                overallConfidence: overallConfidence,
                possibleDuplicateEventId: possibleDuplicateEventId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String privacyClassification,
                required String lifecycle,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String temporalPrecision,
                Value<int?> startYear = const Value.absent(),
                Value<int?> startMonth = const Value.absent(),
                Value<int?> startDay = const Value.absent(),
                Value<int?> endYear = const Value.absent(),
                Value<int?> endMonth = const Value.absent(),
                Value<int?> endDay = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> sourceEvidenceId = const Value.absent(),
                Value<String?> confirmedEventId = const Value.absent(),
                Value<String> documentType = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<double?> overallConfidence = const Value.absent(),
                Value<String?> possibleDuplicateEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryCandidatesCompanion.insert(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                temporalPrecision: temporalPrecision,
                startYear: startYear,
                startMonth: startMonth,
                startDay: startDay,
                endYear: endYear,
                endMonth: endMonth,
                endDay: endDay,
                title: title,
                description: description,
                sourceEvidenceId: sourceEvidenceId,
                confirmedEventId: confirmedEventId,
                documentType: documentType,
                reviewStatus: reviewStatus,
                overallConfidence: overallConfidence,
                possibleDuplicateEventId: possibleDuplicateEventId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryCandidatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceEvidenceId = false,
                confirmedEventId = false,
                possibleDuplicateEventId = false,
                fieldProvenanceRowsRefs = false,
                candidateExtractedFieldsRefs = false,
                candidateEntityProposalsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fieldProvenanceRowsRefs) db.fieldProvenanceRows,
                    if (candidateExtractedFieldsRefs)
                      db.candidateExtractedFields,
                    if (candidateEntityProposalsRefs)
                      db.candidateEntityProposals,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceEvidenceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceEvidenceId,
                                    referencedTable:
                                        $$MemoryCandidatesTableReferences
                                            ._sourceEvidenceIdTable(db),
                                    referencedColumn:
                                        $$MemoryCandidatesTableReferences
                                            ._sourceEvidenceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (confirmedEventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.confirmedEventId,
                                    referencedTable:
                                        $$MemoryCandidatesTableReferences
                                            ._confirmedEventIdTable(db),
                                    referencedColumn:
                                        $$MemoryCandidatesTableReferences
                                            ._confirmedEventIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (possibleDuplicateEventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.possibleDuplicateEventId,
                                    referencedTable:
                                        $$MemoryCandidatesTableReferences
                                            ._possibleDuplicateEventIdTable(db),
                                    referencedColumn:
                                        $$MemoryCandidatesTableReferences
                                            ._possibleDuplicateEventIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (fieldProvenanceRowsRefs)
                        await $_getPrefetchedData<
                          MemoryCandidate,
                          $MemoryCandidatesTable,
                          FieldProvenanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryCandidatesTableReferences
                              ._fieldProvenanceRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryCandidatesTableReferences(
                                db,
                                table,
                                p0,
                              ).fieldProvenanceRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.memoryCandidateId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (candidateExtractedFieldsRefs)
                        await $_getPrefetchedData<
                          MemoryCandidate,
                          $MemoryCandidatesTable,
                          CandidateExtractedField
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryCandidatesTableReferences
                              ._candidateExtractedFieldsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryCandidatesTableReferences(
                                db,
                                table,
                                p0,
                              ).candidateExtractedFieldsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.candidateId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (candidateEntityProposalsRefs)
                        await $_getPrefetchedData<
                          MemoryCandidate,
                          $MemoryCandidatesTable,
                          CandidateEntityProposal
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryCandidatesTableReferences
                              ._candidateEntityProposalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryCandidatesTableReferences(
                                db,
                                table,
                                p0,
                              ).candidateEntityProposalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.candidateId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MemoryCandidatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryCandidatesTable,
      MemoryCandidate,
      $$MemoryCandidatesTableFilterComposer,
      $$MemoryCandidatesTableOrderingComposer,
      $$MemoryCandidatesTableAnnotationComposer,
      $$MemoryCandidatesTableCreateCompanionBuilder,
      $$MemoryCandidatesTableUpdateCompanionBuilder,
      (MemoryCandidate, $$MemoryCandidatesTableReferences),
      MemoryCandidate,
      PrefetchHooks Function({
        bool sourceEvidenceId,
        bool confirmedEventId,
        bool possibleDuplicateEventId,
        bool fieldProvenanceRowsRefs,
        bool candidateExtractedFieldsRefs,
        bool candidateEntityProposalsRefs,
      })
    >;
typedef $$FieldProvenanceRowsTableCreateCompanionBuilder =
    FieldProvenanceRowsCompanion Function({
      required String id,
      Value<String?> entityId,
      Value<String?> eventId,
      Value<String?> evidenceId,
      Value<String?> relationshipId,
      Value<String?> attachmentId,
      Value<String?> memoryCandidateId,
      required String fieldName,
      required String sourceId,
      required String sourceType,
      required String extractionMethod,
      Value<double?> confidence,
      required bool userConfirmed,
      required String privacyClassification,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FieldProvenanceRowsTableUpdateCompanionBuilder =
    FieldProvenanceRowsCompanion Function({
      Value<String> id,
      Value<String?> entityId,
      Value<String?> eventId,
      Value<String?> evidenceId,
      Value<String?> relationshipId,
      Value<String?> attachmentId,
      Value<String?> memoryCandidateId,
      Value<String> fieldName,
      Value<String> sourceId,
      Value<String> sourceType,
      Value<String> extractionMethod,
      Value<double?> confidence,
      Value<bool> userConfirmed,
      Value<String> privacyClassification,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$FieldProvenanceRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FieldProvenanceRowsTable,
          FieldProvenanceRow
        > {
  $$FieldProvenanceRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EntitiesTable _entityIdTable(_$AppDatabase db) =>
      db.entities.createAlias('field_provenance__entity_id__entities__id');

  $$EntitiesTableProcessedTableManager? get entityId {
    final $_column = $_itemColumn<String>('entity_id');
    if ($_column == null) return null;
    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EventsTable _eventIdTable(_$AppDatabase db) =>
      db.events.createAlias('field_provenance__event_id__events__id');

  $$EventsTableProcessedTableManager? get eventId {
    final $_column = $_itemColumn<String>('event_id');
    if ($_column == null) return null;
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EvidenceRecordsTable _evidenceIdTable(_$AppDatabase db) => db
      .evidenceRecords
      .createAlias('field_provenance__evidence_id__evidence__id');

  $$EvidenceRecordsTableProcessedTableManager? get evidenceId {
    final $_column = $_itemColumn<String>('evidence_id');
    if ($_column == null) return null;
    final manager = $$EvidenceRecordsTableTableManager(
      $_db,
      $_db.evidenceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_evidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RelationshipsTable _relationshipIdTable(_$AppDatabase db) => db
      .relationships
      .createAlias('field_provenance__relationship_id__relationships__id');

  $$RelationshipsTableProcessedTableManager? get relationshipId {
    final $_column = $_itemColumn<String>('relationship_id');
    if ($_column == null) return null;
    final manager = $$RelationshipsTableTableManager(
      $_db,
      $_db.relationships,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_relationshipIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AttachmentsTable _attachmentIdTable(_$AppDatabase db) => db
      .attachments
      .createAlias('field_provenance__attachment_id__attachments__id');

  $$AttachmentsTableProcessedTableManager? get attachmentId {
    final $_column = $_itemColumn<String>('attachment_id');
    if ($_column == null) return null;
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attachmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MemoryCandidatesTable _memoryCandidateIdTable(_$AppDatabase db) =>
      db.memoryCandidates.createAlias(
        'field_provenance__memory_candidate_id__memory_candidates__id',
      );

  $$MemoryCandidatesTableProcessedTableManager? get memoryCandidateId {
    final $_column = $_itemColumn<String>('memory_candidate_id');
    if ($_column == null) return null;
    final manager = $$MemoryCandidatesTableTableManager(
      $_db,
      $_db.memoryCandidates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryCandidateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FieldProvenanceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $FieldProvenanceRowsTable> {
  $$FieldProvenanceRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractionMethod => $composableBuilder(
    column: $table.extractionMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EntitiesTableFilterComposer get entityId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EvidenceRecordsTableFilterComposer get evidenceId {
    final $$EvidenceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RelationshipsTableFilterComposer get relationshipId {
    final $$RelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relationshipId,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AttachmentsTableFilterComposer get attachmentId {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryCandidatesTableFilterComposer get memoryCandidateId {
    final $$MemoryCandidatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryCandidateId,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableFilterComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FieldProvenanceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $FieldProvenanceRowsTable> {
  $$FieldProvenanceRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractionMethod => $composableBuilder(
    column: $table.extractionMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EntitiesTableOrderingComposer get entityId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EvidenceRecordsTableOrderingComposer get evidenceId {
    final $$EvidenceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RelationshipsTableOrderingComposer get relationshipId {
    final $$RelationshipsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relationshipId,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableOrderingComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AttachmentsTableOrderingComposer get attachmentId {
    final $$AttachmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableOrderingComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryCandidatesTableOrderingComposer get memoryCandidateId {
    final $$MemoryCandidatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryCandidateId,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableOrderingComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FieldProvenanceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FieldProvenanceRowsTable> {
  $$FieldProvenanceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fieldName =>
      $composableBuilder(column: $table.fieldName, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extractionMethod => $composableBuilder(
    column: $table.extractionMethod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$EntitiesTableAnnotationComposer get entityId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EvidenceRecordsTableAnnotationComposer get evidenceId {
    final $$EvidenceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RelationshipsTableAnnotationComposer get relationshipId {
    final $$RelationshipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relationshipId,
      referencedTable: $db.relationships,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipsTableAnnotationComposer(
            $db: $db,
            $table: $db.relationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AttachmentsTableAnnotationComposer get attachmentId {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryCandidatesTableAnnotationComposer get memoryCandidateId {
    final $$MemoryCandidatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryCandidateId,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FieldProvenanceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FieldProvenanceRowsTable,
          FieldProvenanceRow,
          $$FieldProvenanceRowsTableFilterComposer,
          $$FieldProvenanceRowsTableOrderingComposer,
          $$FieldProvenanceRowsTableAnnotationComposer,
          $$FieldProvenanceRowsTableCreateCompanionBuilder,
          $$FieldProvenanceRowsTableUpdateCompanionBuilder,
          (FieldProvenanceRow, $$FieldProvenanceRowsTableReferences),
          FieldProvenanceRow,
          PrefetchHooks Function({
            bool entityId,
            bool eventId,
            bool evidenceId,
            bool relationshipId,
            bool attachmentId,
            bool memoryCandidateId,
          })
        > {
  $$FieldProvenanceRowsTableTableManager(
    _$AppDatabase db,
    $FieldProvenanceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldProvenanceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldProvenanceRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FieldProvenanceRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String?> eventId = const Value.absent(),
                Value<String?> evidenceId = const Value.absent(),
                Value<String?> relationshipId = const Value.absent(),
                Value<String?> attachmentId = const Value.absent(),
                Value<String?> memoryCandidateId = const Value.absent(),
                Value<String> fieldName = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> extractionMethod = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<bool> userConfirmed = const Value.absent(),
                Value<String> privacyClassification = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldProvenanceRowsCompanion(
                id: id,
                entityId: entityId,
                eventId: eventId,
                evidenceId: evidenceId,
                relationshipId: relationshipId,
                attachmentId: attachmentId,
                memoryCandidateId: memoryCandidateId,
                fieldName: fieldName,
                sourceId: sourceId,
                sourceType: sourceType,
                extractionMethod: extractionMethod,
                confidence: confidence,
                userConfirmed: userConfirmed,
                privacyClassification: privacyClassification,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> entityId = const Value.absent(),
                Value<String?> eventId = const Value.absent(),
                Value<String?> evidenceId = const Value.absent(),
                Value<String?> relationshipId = const Value.absent(),
                Value<String?> attachmentId = const Value.absent(),
                Value<String?> memoryCandidateId = const Value.absent(),
                required String fieldName,
                required String sourceId,
                required String sourceType,
                required String extractionMethod,
                Value<double?> confidence = const Value.absent(),
                required bool userConfirmed,
                required String privacyClassification,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FieldProvenanceRowsCompanion.insert(
                id: id,
                entityId: entityId,
                eventId: eventId,
                evidenceId: evidenceId,
                relationshipId: relationshipId,
                attachmentId: attachmentId,
                memoryCandidateId: memoryCandidateId,
                fieldName: fieldName,
                sourceId: sourceId,
                sourceType: sourceType,
                extractionMethod: extractionMethod,
                confidence: confidence,
                userConfirmed: userConfirmed,
                privacyClassification: privacyClassification,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FieldProvenanceRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                entityId = false,
                eventId = false,
                evidenceId = false,
                relationshipId = false,
                attachmentId = false,
                memoryCandidateId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (entityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.entityId,
                                    referencedTable:
                                        $$FieldProvenanceRowsTableReferences
                                            ._entityIdTable(db),
                                    referencedColumn:
                                        $$FieldProvenanceRowsTableReferences
                                            ._entityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (eventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.eventId,
                                    referencedTable:
                                        $$FieldProvenanceRowsTableReferences
                                            ._eventIdTable(db),
                                    referencedColumn:
                                        $$FieldProvenanceRowsTableReferences
                                            ._eventIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (evidenceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.evidenceId,
                                    referencedTable:
                                        $$FieldProvenanceRowsTableReferences
                                            ._evidenceIdTable(db),
                                    referencedColumn:
                                        $$FieldProvenanceRowsTableReferences
                                            ._evidenceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (relationshipId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.relationshipId,
                                    referencedTable:
                                        $$FieldProvenanceRowsTableReferences
                                            ._relationshipIdTable(db),
                                    referencedColumn:
                                        $$FieldProvenanceRowsTableReferences
                                            ._relationshipIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (attachmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.attachmentId,
                                    referencedTable:
                                        $$FieldProvenanceRowsTableReferences
                                            ._attachmentIdTable(db),
                                    referencedColumn:
                                        $$FieldProvenanceRowsTableReferences
                                            ._attachmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (memoryCandidateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.memoryCandidateId,
                                    referencedTable:
                                        $$FieldProvenanceRowsTableReferences
                                            ._memoryCandidateIdTable(db),
                                    referencedColumn:
                                        $$FieldProvenanceRowsTableReferences
                                            ._memoryCandidateIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$FieldProvenanceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FieldProvenanceRowsTable,
      FieldProvenanceRow,
      $$FieldProvenanceRowsTableFilterComposer,
      $$FieldProvenanceRowsTableOrderingComposer,
      $$FieldProvenanceRowsTableAnnotationComposer,
      $$FieldProvenanceRowsTableCreateCompanionBuilder,
      $$FieldProvenanceRowsTableUpdateCompanionBuilder,
      (FieldProvenanceRow, $$FieldProvenanceRowsTableReferences),
      FieldProvenanceRow,
      PrefetchHooks Function({
        bool entityId,
        bool eventId,
        bool evidenceId,
        bool relationshipId,
        bool attachmentId,
        bool memoryCandidateId,
      })
    >;
typedef $$CandidateExtractedFieldsTableCreateCompanionBuilder =
    CandidateExtractedFieldsCompanion Function({
      required String id,
      required String candidateId,
      required String key,
      required String value,
      required String valueType,
      required double confidence,
      required String privacyClassification,
      required String extractionMethod,
      Value<String?> sourceExcerpt,
      Value<bool> reviewRecommended,
      Value<int> rowid,
    });
typedef $$CandidateExtractedFieldsTableUpdateCompanionBuilder =
    CandidateExtractedFieldsCompanion Function({
      Value<String> id,
      Value<String> candidateId,
      Value<String> key,
      Value<String> value,
      Value<String> valueType,
      Value<double> confidence,
      Value<String> privacyClassification,
      Value<String> extractionMethod,
      Value<String?> sourceExcerpt,
      Value<bool> reviewRecommended,
      Value<int> rowid,
    });

final class $$CandidateExtractedFieldsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CandidateExtractedFieldsTable,
          CandidateExtractedField
        > {
  $$CandidateExtractedFieldsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MemoryCandidatesTable _candidateIdTable(_$AppDatabase db) =>
      db.memoryCandidates.createAlias(
        'candidate_extracted_fields__candidate_id__memory_candidates__id',
      );

  $$MemoryCandidatesTableProcessedTableManager get candidateId {
    final $_column = $_itemColumn<String>('candidate_id')!;

    final manager = $$MemoryCandidatesTableTableManager(
      $_db,
      $_db.memoryCandidates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_candidateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CandidateExtractedFieldsTableFilterComposer
    extends Composer<_$AppDatabase, $CandidateExtractedFieldsTable> {
  $$CandidateExtractedFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractionMethod => $composableBuilder(
    column: $table.extractionMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceExcerpt => $composableBuilder(
    column: $table.sourceExcerpt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reviewRecommended => $composableBuilder(
    column: $table.reviewRecommended,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryCandidatesTableFilterComposer get candidateId {
    final $$MemoryCandidatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.candidateId,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableFilterComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CandidateExtractedFieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $CandidateExtractedFieldsTable> {
  $$CandidateExtractedFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueType => $composableBuilder(
    column: $table.valueType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractionMethod => $composableBuilder(
    column: $table.extractionMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceExcerpt => $composableBuilder(
    column: $table.sourceExcerpt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reviewRecommended => $composableBuilder(
    column: $table.reviewRecommended,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryCandidatesTableOrderingComposer get candidateId {
    final $$MemoryCandidatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.candidateId,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableOrderingComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CandidateExtractedFieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CandidateExtractedFieldsTable> {
  $$CandidateExtractedFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get valueType =>
      $composableBuilder(column: $table.valueType, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extractionMethod => $composableBuilder(
    column: $table.extractionMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceExcerpt => $composableBuilder(
    column: $table.sourceExcerpt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reviewRecommended => $composableBuilder(
    column: $table.reviewRecommended,
    builder: (column) => column,
  );

  $$MemoryCandidatesTableAnnotationComposer get candidateId {
    final $$MemoryCandidatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.candidateId,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CandidateExtractedFieldsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CandidateExtractedFieldsTable,
          CandidateExtractedField,
          $$CandidateExtractedFieldsTableFilterComposer,
          $$CandidateExtractedFieldsTableOrderingComposer,
          $$CandidateExtractedFieldsTableAnnotationComposer,
          $$CandidateExtractedFieldsTableCreateCompanionBuilder,
          $$CandidateExtractedFieldsTableUpdateCompanionBuilder,
          (CandidateExtractedField, $$CandidateExtractedFieldsTableReferences),
          CandidateExtractedField,
          PrefetchHooks Function({bool candidateId})
        > {
  $$CandidateExtractedFieldsTableTableManager(
    _$AppDatabase db,
    $CandidateExtractedFieldsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CandidateExtractedFieldsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CandidateExtractedFieldsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CandidateExtractedFieldsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> candidateId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> valueType = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> privacyClassification = const Value.absent(),
                Value<String> extractionMethod = const Value.absent(),
                Value<String?> sourceExcerpt = const Value.absent(),
                Value<bool> reviewRecommended = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CandidateExtractedFieldsCompanion(
                id: id,
                candidateId: candidateId,
                key: key,
                value: value,
                valueType: valueType,
                confidence: confidence,
                privacyClassification: privacyClassification,
                extractionMethod: extractionMethod,
                sourceExcerpt: sourceExcerpt,
                reviewRecommended: reviewRecommended,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String candidateId,
                required String key,
                required String value,
                required String valueType,
                required double confidence,
                required String privacyClassification,
                required String extractionMethod,
                Value<String?> sourceExcerpt = const Value.absent(),
                Value<bool> reviewRecommended = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CandidateExtractedFieldsCompanion.insert(
                id: id,
                candidateId: candidateId,
                key: key,
                value: value,
                valueType: valueType,
                confidence: confidence,
                privacyClassification: privacyClassification,
                extractionMethod: extractionMethod,
                sourceExcerpt: sourceExcerpt,
                reviewRecommended: reviewRecommended,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CandidateExtractedFieldsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({candidateId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (candidateId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.candidateId,
                                referencedTable:
                                    $$CandidateExtractedFieldsTableReferences
                                        ._candidateIdTable(db),
                                referencedColumn:
                                    $$CandidateExtractedFieldsTableReferences
                                        ._candidateIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CandidateExtractedFieldsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CandidateExtractedFieldsTable,
      CandidateExtractedField,
      $$CandidateExtractedFieldsTableFilterComposer,
      $$CandidateExtractedFieldsTableOrderingComposer,
      $$CandidateExtractedFieldsTableAnnotationComposer,
      $$CandidateExtractedFieldsTableCreateCompanionBuilder,
      $$CandidateExtractedFieldsTableUpdateCompanionBuilder,
      (CandidateExtractedField, $$CandidateExtractedFieldsTableReferences),
      CandidateExtractedField,
      PrefetchHooks Function({bool candidateId})
    >;
typedef $$CandidateEntityProposalsTableCreateCompanionBuilder =
    CandidateEntityProposalsCompanion Function({
      required String id,
      required String candidateId,
      required String name,
      required String entityType,
      required double confidence,
      Value<String?> brand,
      Value<String?> model,
      Value<String?> serialNumber,
      Value<String?> suggestedEntityId,
      Value<double?> matchScore,
      Value<String> matchReasons,
      Value<int> rowid,
    });
typedef $$CandidateEntityProposalsTableUpdateCompanionBuilder =
    CandidateEntityProposalsCompanion Function({
      Value<String> id,
      Value<String> candidateId,
      Value<String> name,
      Value<String> entityType,
      Value<double> confidence,
      Value<String?> brand,
      Value<String?> model,
      Value<String?> serialNumber,
      Value<String?> suggestedEntityId,
      Value<double?> matchScore,
      Value<String> matchReasons,
      Value<int> rowid,
    });

final class $$CandidateEntityProposalsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CandidateEntityProposalsTable,
          CandidateEntityProposal
        > {
  $$CandidateEntityProposalsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MemoryCandidatesTable _candidateIdTable(_$AppDatabase db) =>
      db.memoryCandidates.createAlias(
        'candidate_entity_proposals__candidate_id__memory_candidates__id',
      );

  $$MemoryCandidatesTableProcessedTableManager get candidateId {
    final $_column = $_itemColumn<String>('candidate_id')!;

    final manager = $$MemoryCandidatesTableTableManager(
      $_db,
      $_db.memoryCandidates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_candidateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EntitiesTable _suggestedEntityIdTable(_$AppDatabase db) =>
      db.entities.createAlias(
        'candidate_entity_proposals__suggested_entity_id__entities__id',
      );

  $$EntitiesTableProcessedTableManager? get suggestedEntityId {
    final $_column = $_itemColumn<String>('suggested_entity_id');
    if ($_column == null) return null;
    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_suggestedEntityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CandidateEntityProposalsTableFilterComposer
    extends Composer<_$AppDatabase, $CandidateEntityProposalsTable> {
  $$CandidateEntityProposalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get matchScore => $composableBuilder(
    column: $table.matchScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchReasons => $composableBuilder(
    column: $table.matchReasons,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryCandidatesTableFilterComposer get candidateId {
    final $$MemoryCandidatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.candidateId,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableFilterComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableFilterComposer get suggestedEntityId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.suggestedEntityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CandidateEntityProposalsTableOrderingComposer
    extends Composer<_$AppDatabase, $CandidateEntityProposalsTable> {
  $$CandidateEntityProposalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get matchScore => $composableBuilder(
    column: $table.matchScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchReasons => $composableBuilder(
    column: $table.matchReasons,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryCandidatesTableOrderingComposer get candidateId {
    final $$MemoryCandidatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.candidateId,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableOrderingComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableOrderingComposer get suggestedEntityId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.suggestedEntityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CandidateEntityProposalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CandidateEntityProposalsTable> {
  $$CandidateEntityProposalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get serialNumber => $composableBuilder(
    column: $table.serialNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get matchScore => $composableBuilder(
    column: $table.matchScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get matchReasons => $composableBuilder(
    column: $table.matchReasons,
    builder: (column) => column,
  );

  $$MemoryCandidatesTableAnnotationComposer get candidateId {
    final $$MemoryCandidatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.candidateId,
      referencedTable: $db.memoryCandidates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryCandidatesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryCandidates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntitiesTableAnnotationComposer get suggestedEntityId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.suggestedEntityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CandidateEntityProposalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CandidateEntityProposalsTable,
          CandidateEntityProposal,
          $$CandidateEntityProposalsTableFilterComposer,
          $$CandidateEntityProposalsTableOrderingComposer,
          $$CandidateEntityProposalsTableAnnotationComposer,
          $$CandidateEntityProposalsTableCreateCompanionBuilder,
          $$CandidateEntityProposalsTableUpdateCompanionBuilder,
          (CandidateEntityProposal, $$CandidateEntityProposalsTableReferences),
          CandidateEntityProposal,
          PrefetchHooks Function({bool candidateId, bool suggestedEntityId})
        > {
  $$CandidateEntityProposalsTableTableManager(
    _$AppDatabase db,
    $CandidateEntityProposalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CandidateEntityProposalsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CandidateEntityProposalsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CandidateEntityProposalsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> candidateId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> serialNumber = const Value.absent(),
                Value<String?> suggestedEntityId = const Value.absent(),
                Value<double?> matchScore = const Value.absent(),
                Value<String> matchReasons = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CandidateEntityProposalsCompanion(
                id: id,
                candidateId: candidateId,
                name: name,
                entityType: entityType,
                confidence: confidence,
                brand: brand,
                model: model,
                serialNumber: serialNumber,
                suggestedEntityId: suggestedEntityId,
                matchScore: matchScore,
                matchReasons: matchReasons,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String candidateId,
                required String name,
                required String entityType,
                required double confidence,
                Value<String?> brand = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> serialNumber = const Value.absent(),
                Value<String?> suggestedEntityId = const Value.absent(),
                Value<double?> matchScore = const Value.absent(),
                Value<String> matchReasons = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CandidateEntityProposalsCompanion.insert(
                id: id,
                candidateId: candidateId,
                name: name,
                entityType: entityType,
                confidence: confidence,
                brand: brand,
                model: model,
                serialNumber: serialNumber,
                suggestedEntityId: suggestedEntityId,
                matchScore: matchScore,
                matchReasons: matchReasons,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CandidateEntityProposalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({candidateId = false, suggestedEntityId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (candidateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.candidateId,
                                    referencedTable:
                                        $$CandidateEntityProposalsTableReferences
                                            ._candidateIdTable(db),
                                    referencedColumn:
                                        $$CandidateEntityProposalsTableReferences
                                            ._candidateIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (suggestedEntityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.suggestedEntityId,
                                    referencedTable:
                                        $$CandidateEntityProposalsTableReferences
                                            ._suggestedEntityIdTable(db),
                                    referencedColumn:
                                        $$CandidateEntityProposalsTableReferences
                                            ._suggestedEntityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$CandidateEntityProposalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CandidateEntityProposalsTable,
      CandidateEntityProposal,
      $$CandidateEntityProposalsTableFilterComposer,
      $$CandidateEntityProposalsTableOrderingComposer,
      $$CandidateEntityProposalsTableAnnotationComposer,
      $$CandidateEntityProposalsTableCreateCompanionBuilder,
      $$CandidateEntityProposalsTableUpdateCompanionBuilder,
      (CandidateEntityProposal, $$CandidateEntityProposalsTableReferences),
      CandidateEntityProposal,
      PrefetchHooks Function({bool candidateId, bool suggestedEntityId})
    >;
typedef $$FeatureUsageTableCreateCompanionBuilder =
    FeatureUsageCompanion Function({
      required String feature,
      Value<int> usageCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FeatureUsageTableUpdateCompanionBuilder =
    FeatureUsageCompanion Function({
      Value<String> feature,
      Value<int> usageCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FeatureUsageTableFilterComposer
    extends Composer<_$AppDatabase, $FeatureUsageTable> {
  $$FeatureUsageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feature => $composableBuilder(
    column: $table.feature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeatureUsageTableOrderingComposer
    extends Composer<_$AppDatabase, $FeatureUsageTable> {
  $$FeatureUsageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feature => $composableBuilder(
    column: $table.feature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeatureUsageTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeatureUsageTable> {
  $$FeatureUsageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feature =>
      $composableBuilder(column: $table.feature, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeatureUsageTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeatureUsageTable,
          FeatureUsageData,
          $$FeatureUsageTableFilterComposer,
          $$FeatureUsageTableOrderingComposer,
          $$FeatureUsageTableAnnotationComposer,
          $$FeatureUsageTableCreateCompanionBuilder,
          $$FeatureUsageTableUpdateCompanionBuilder,
          (
            FeatureUsageData,
            BaseReferences<_$AppDatabase, $FeatureUsageTable, FeatureUsageData>,
          ),
          FeatureUsageData,
          PrefetchHooks Function()
        > {
  $$FeatureUsageTableTableManager(_$AppDatabase db, $FeatureUsageTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeatureUsageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeatureUsageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeatureUsageTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feature = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeatureUsageCompanion(
                feature: feature,
                usageCount: usageCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feature,
                Value<int> usageCount = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FeatureUsageCompanion.insert(
                feature: feature,
                usageCount: usageCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeatureUsageTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeatureUsageTable,
      FeatureUsageData,
      $$FeatureUsageTableFilterComposer,
      $$FeatureUsageTableOrderingComposer,
      $$FeatureUsageTableAnnotationComposer,
      $$FeatureUsageTableCreateCompanionBuilder,
      $$FeatureUsageTableUpdateCompanionBuilder,
      (
        FeatureUsageData,
        BaseReferences<_$AppDatabase, $FeatureUsageTable, FeatureUsageData>,
      ),
      FeatureUsageData,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String privacyClassification,
      required String lifecycle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      required String normalizedName,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> privacyClassification,
      Value<String> lifecycle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String> normalizedName,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EntityTagsTable, List<EntityTag>>
  _entityTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entityTags,
    aliasName: 'tags__id__entity_tags__tag_id',
  );

  $$EntityTagsTableProcessedTableManager get entityTagsRefs {
    final manager = $$EntityTagsTableTableManager(
      $_db,
      $_db.entityTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entityTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventTagsTable, List<EventTag>>
  _eventTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventTags,
    aliasName: 'tags__id__event_tags__tag_id',
  );

  $$EventTagsTableProcessedTableManager get eventTagsRefs {
    final manager = $$EventTagsTableTableManager(
      $_db,
      $_db.eventTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EvidenceTagsTable, List<EvidenceTag>>
  _evidenceTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.evidenceTags,
    aliasName: 'tags__id__evidence_tags__tag_id',
  );

  $$EvidenceTagsTableProcessedTableManager get evidenceTagsRefs {
    final manager = $$EvidenceTagsTableTableManager(
      $_db,
      $_db.evidenceTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_evidenceTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entityTagsRefs(
    Expression<bool> Function($$EntityTagsTableFilterComposer f) f,
  ) {
    final $$EntityTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityTagsTableFilterComposer(
            $db: $db,
            $table: $db.entityTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventTagsRefs(
    Expression<bool> Function($$EventTagsTableFilterComposer f) f,
  ) {
    final $$EventTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventTagsTableFilterComposer(
            $db: $db,
            $table: $db.eventTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> evidenceTagsRefs(
    Expression<bool> Function($$EvidenceTagsTableFilterComposer f) f,
  ) {
    final $$EvidenceTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceTagsTableFilterComposer(
            $db: $db,
            $table: $db.evidenceTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  Expression<T> entityTagsRefs<T extends Object>(
    Expression<T> Function($$EntityTagsTableAnnotationComposer a) f,
  ) {
    final $$EntityTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.entityTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventTagsRefs<T extends Object>(
    Expression<T> Function($$EventTagsTableAnnotationComposer a) f,
  ) {
    final $$EventTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.eventTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> evidenceTagsRefs<T extends Object>(
    Expression<T> Function($$EvidenceTagsTableAnnotationComposer a) f,
  ) {
    final $$EvidenceTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({
            bool entityTagsRefs,
            bool eventTagsRefs,
            bool evidenceTagsRefs,
          })
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> privacyClassification = const Value.absent(),
                Value<String> lifecycle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                normalizedName: normalizedName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String privacyClassification,
                required String lifecycle,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                required String normalizedName,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                normalizedName: normalizedName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                entityTagsRefs = false,
                eventTagsRefs = false,
                evidenceTagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entityTagsRefs) db.entityTags,
                    if (eventTagsRefs) db.eventTags,
                    if (evidenceTagsRefs) db.evidenceTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entityTagsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, EntityTag>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._entityTagsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).entityTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventTagsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, EventTag>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._eventTagsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).eventTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (evidenceTagsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, EvidenceTag>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._evidenceTagsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).evidenceTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({
        bool entityTagsRefs,
        bool eventTagsRefs,
        bool evidenceTagsRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String privacyClassification,
      required String lifecycle,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      required String normalizedName,
      Value<String?> parentId,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> privacyClassification,
      Value<String> lifecycle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String> normalizedName,
      Value<String?> parentId,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _parentIdTable(_$AppDatabase db) =>
      db.categories.createAlias('categories__parent_id__categories__id');

  $$CategoriesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntityCategoriesTable, List<EntityCategory>>
  _entityCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entityCategories,
    aliasName: 'categories__id__entity_categories__category_id',
  );

  $$EntityCategoriesTableProcessedTableManager get entityCategoriesRefs {
    final manager = $$EntityCategoriesTableTableManager(
      $_db,
      $_db.entityCategories,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _entityCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventCategoriesTable, List<EventCategory>>
  _eventCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventCategories,
    aliasName: 'categories__id__event_categories__category_id',
  );

  $$EventCategoriesTableProcessedTableManager get eventCategoriesRefs {
    final manager = $$EventCategoriesTableTableManager(
      $_db,
      $_db.eventCategories,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _eventCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EvidenceCategoriesTable, List<EvidenceCategory>>
  _evidenceCategoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.evidenceCategories,
        aliasName: 'categories__id__evidence_categories__category_id',
      );

  $$EvidenceCategoriesTableProcessedTableManager get evidenceCategoriesRefs {
    final manager = $$EvidenceCategoriesTableTableManager(
      $_db,
      $_db.evidenceCategories,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _evidenceCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get parentId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entityCategoriesRefs(
    Expression<bool> Function($$EntityCategoriesTableFilterComposer f) f,
  ) {
    final $$EntityCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.entityCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventCategoriesRefs(
    Expression<bool> Function($$EventCategoriesTableFilterComposer f) f,
  ) {
    final $$EventCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.eventCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> evidenceCategoriesRefs(
    Expression<bool> Function($$EvidenceCategoriesTableFilterComposer f) f,
  ) {
    final $$EvidenceCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.evidenceCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifecycle => $composableBuilder(
    column: $table.lifecycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get parentId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get privacyClassification => $composableBuilder(
    column: $table.privacyClassification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lifecycle =>
      $composableBuilder(column: $table.lifecycle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get parentId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entityCategoriesRefs<T extends Object>(
    Expression<T> Function($$EntityCategoriesTableAnnotationComposer a) f,
  ) {
    final $$EntityCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entityCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entityCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventCategoriesRefs<T extends Object>(
    Expression<T> Function($$EventCategoriesTableAnnotationComposer a) f,
  ) {
    final $$EventCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.eventCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> evidenceCategoriesRefs<T extends Object>(
    Expression<T> Function($$EvidenceCategoriesTableAnnotationComposer a) f,
  ) {
    final $$EvidenceCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.evidenceCategories,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EvidenceCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.evidenceCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool parentId,
            bool entityCategoriesRefs,
            bool eventCategoriesRefs,
            bool evidenceCategoriesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> privacyClassification = const Value.absent(),
                Value<String> lifecycle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                normalizedName: normalizedName,
                parentId: parentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String privacyClassification,
                required String lifecycle,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                required String normalizedName,
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                privacyClassification: privacyClassification,
                lifecycle: lifecycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                normalizedName: normalizedName,
                parentId: parentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                entityCategoriesRefs = false,
                eventCategoriesRefs = false,
                evidenceCategoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entityCategoriesRefs) db.entityCategories,
                    if (eventCategoriesRefs) db.eventCategories,
                    if (evidenceCategoriesRefs) db.evidenceCategories,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable: $$CategoriesTableReferences
                                        ._parentIdTable(db),
                                    referencedColumn:
                                        $$CategoriesTableReferences
                                            ._parentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entityCategoriesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          EntityCategory
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._entityCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).entityCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventCategoriesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          EventCategory
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._eventCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).eventCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (evidenceCategoriesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          EvidenceCategory
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._evidenceCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).evidenceCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool parentId,
        bool entityCategoriesRefs,
        bool eventCategoriesRefs,
        bool evidenceCategoriesRefs,
      })
    >;
typedef $$EntityTagsTableCreateCompanionBuilder =
    EntityTagsCompanion Function({
      required String entityId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$EntityTagsTableUpdateCompanionBuilder =
    EntityTagsCompanion Function({
      Value<String> entityId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$EntityTagsTableReferences
    extends BaseReferences<_$AppDatabase, $EntityTagsTable, EntityTag> {
  $$EntityTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntitiesTable _entityIdTable(_$AppDatabase db) =>
      db.entities.createAlias('entity_tags__entity_id__entities__id');

  $$EntitiesTableProcessedTableManager get entityId {
    final $_column = $_itemColumn<String>('entity_id')!;

    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('entity_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntityTagsTableFilterComposer
    extends Composer<_$AppDatabase, $EntityTagsTable> {
  $$EntityTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntitiesTableFilterComposer get entityId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntityTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntityTagsTable> {
  $$EntityTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntitiesTableOrderingComposer get entityId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntityTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntityTagsTable> {
  $$EntityTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntitiesTableAnnotationComposer get entityId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntityTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntityTagsTable,
          EntityTag,
          $$EntityTagsTableFilterComposer,
          $$EntityTagsTableOrderingComposer,
          $$EntityTagsTableAnnotationComposer,
          $$EntityTagsTableCreateCompanionBuilder,
          $$EntityTagsTableUpdateCompanionBuilder,
          (EntityTag, $$EntityTagsTableReferences),
          EntityTag,
          PrefetchHooks Function({bool entityId, bool tagId})
        > {
  $$EntityTagsTableTableManager(_$AppDatabase db, $EntityTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityTagsCompanion(
                entityId: entityId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => EntityTagsCompanion.insert(
                entityId: entityId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntityTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entityId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entityId,
                                referencedTable: $$EntityTagsTableReferences
                                    ._entityIdTable(db),
                                referencedColumn: $$EntityTagsTableReferences
                                    ._entityIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$EntityTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$EntityTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntityTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntityTagsTable,
      EntityTag,
      $$EntityTagsTableFilterComposer,
      $$EntityTagsTableOrderingComposer,
      $$EntityTagsTableAnnotationComposer,
      $$EntityTagsTableCreateCompanionBuilder,
      $$EntityTagsTableUpdateCompanionBuilder,
      (EntityTag, $$EntityTagsTableReferences),
      EntityTag,
      PrefetchHooks Function({bool entityId, bool tagId})
    >;
typedef $$EventTagsTableCreateCompanionBuilder =
    EventTagsCompanion Function({
      required String eventId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$EventTagsTableUpdateCompanionBuilder =
    EventTagsCompanion Function({
      Value<String> eventId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$EventTagsTableReferences
    extends BaseReferences<_$AppDatabase, $EventTagsTable, EventTag> {
  $$EventTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AppDatabase db) =>
      db.events.createAlias('event_tags__event_id__events__id');

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('event_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventTagsTableFilterComposer
    extends Composer<_$AppDatabase, $EventTagsTable> {
  $$EventTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventTagsTable> {
  $$EventTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventTagsTable> {
  $$EventTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventTagsTable,
          EventTag,
          $$EventTagsTableFilterComposer,
          $$EventTagsTableOrderingComposer,
          $$EventTagsTableAnnotationComposer,
          $$EventTagsTableCreateCompanionBuilder,
          $$EventTagsTableUpdateCompanionBuilder,
          (EventTag, $$EventTagsTableReferences),
          EventTag,
          PrefetchHooks Function({bool eventId, bool tagId})
        > {
  $$EventTagsTableTableManager(_$AppDatabase db, $EventTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventTagsCompanion(
                eventId: eventId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => EventTagsCompanion.insert(
                eventId: eventId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EventTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable: $$EventTagsTableReferences
                                    ._eventIdTable(db),
                                referencedColumn: $$EventTagsTableReferences
                                    ._eventIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$EventTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$EventTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventTagsTable,
      EventTag,
      $$EventTagsTableFilterComposer,
      $$EventTagsTableOrderingComposer,
      $$EventTagsTableAnnotationComposer,
      $$EventTagsTableCreateCompanionBuilder,
      $$EventTagsTableUpdateCompanionBuilder,
      (EventTag, $$EventTagsTableReferences),
      EventTag,
      PrefetchHooks Function({bool eventId, bool tagId})
    >;
typedef $$EvidenceTagsTableCreateCompanionBuilder =
    EvidenceTagsCompanion Function({
      required String evidenceId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$EvidenceTagsTableUpdateCompanionBuilder =
    EvidenceTagsCompanion Function({
      Value<String> evidenceId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$EvidenceTagsTableReferences
    extends BaseReferences<_$AppDatabase, $EvidenceTagsTable, EvidenceTag> {
  $$EvidenceTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EvidenceRecordsTable _evidenceIdTable(_$AppDatabase db) => db
      .evidenceRecords
      .createAlias('evidence_tags__evidence_id__evidence__id');

  $$EvidenceRecordsTableProcessedTableManager get evidenceId {
    final $_column = $_itemColumn<String>('evidence_id')!;

    final manager = $$EvidenceRecordsTableTableManager(
      $_db,
      $_db.evidenceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_evidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('evidence_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EvidenceTagsTableFilterComposer
    extends Composer<_$AppDatabase, $EvidenceTagsTable> {
  $$EvidenceTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EvidenceRecordsTableFilterComposer get evidenceId {
    final $$EvidenceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidenceTagsTable> {
  $$EvidenceTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EvidenceRecordsTableOrderingComposer get evidenceId {
    final $$EvidenceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidenceTagsTable> {
  $$EvidenceTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EvidenceRecordsTableAnnotationComposer get evidenceId {
    final $$EvidenceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvidenceTagsTable,
          EvidenceTag,
          $$EvidenceTagsTableFilterComposer,
          $$EvidenceTagsTableOrderingComposer,
          $$EvidenceTagsTableAnnotationComposer,
          $$EvidenceTagsTableCreateCompanionBuilder,
          $$EvidenceTagsTableUpdateCompanionBuilder,
          (EvidenceTag, $$EvidenceTagsTableReferences),
          EvidenceTag,
          PrefetchHooks Function({bool evidenceId, bool tagId})
        > {
  $$EvidenceTagsTableTableManager(_$AppDatabase db, $EvidenceTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidenceTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidenceTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidenceTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> evidenceId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvidenceTagsCompanion(
                evidenceId: evidenceId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String evidenceId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => EvidenceTagsCompanion.insert(
                evidenceId: evidenceId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EvidenceTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({evidenceId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (evidenceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.evidenceId,
                                referencedTable: $$EvidenceTagsTableReferences
                                    ._evidenceIdTable(db),
                                referencedColumn: $$EvidenceTagsTableReferences
                                    ._evidenceIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$EvidenceTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$EvidenceTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EvidenceTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvidenceTagsTable,
      EvidenceTag,
      $$EvidenceTagsTableFilterComposer,
      $$EvidenceTagsTableOrderingComposer,
      $$EvidenceTagsTableAnnotationComposer,
      $$EvidenceTagsTableCreateCompanionBuilder,
      $$EvidenceTagsTableUpdateCompanionBuilder,
      (EvidenceTag, $$EvidenceTagsTableReferences),
      EvidenceTag,
      PrefetchHooks Function({bool evidenceId, bool tagId})
    >;
typedef $$EntityCategoriesTableCreateCompanionBuilder =
    EntityCategoriesCompanion Function({
      required String entityId,
      required String categoryId,
      Value<int> rowid,
    });
typedef $$EntityCategoriesTableUpdateCompanionBuilder =
    EntityCategoriesCompanion Function({
      Value<String> entityId,
      Value<String> categoryId,
      Value<int> rowid,
    });

final class $$EntityCategoriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $EntityCategoriesTable, EntityCategory> {
  $$EntityCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EntitiesTable _entityIdTable(_$AppDatabase db) =>
      db.entities.createAlias('entity_categories__entity_id__entities__id');

  $$EntitiesTableProcessedTableManager get entityId {
    final $_column = $_itemColumn<String>('entity_id')!;

    final manager = $$EntitiesTableTableManager(
      $_db,
      $_db.entities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('entity_categories__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntityCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntityCategoriesTable> {
  $$EntityCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntitiesTableFilterComposer get entityId {
    final $$EntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableFilterComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntityCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntityCategoriesTable> {
  $$EntityCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntitiesTableOrderingComposer get entityId {
    final $$EntitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableOrderingComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntityCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntityCategoriesTable> {
  $$EntityCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntitiesTableAnnotationComposer get entityId {
    final $$EntitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.entities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntityCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntityCategoriesTable,
          EntityCategory,
          $$EntityCategoriesTableFilterComposer,
          $$EntityCategoriesTableOrderingComposer,
          $$EntityCategoriesTableAnnotationComposer,
          $$EntityCategoriesTableCreateCompanionBuilder,
          $$EntityCategoriesTableUpdateCompanionBuilder,
          (EntityCategory, $$EntityCategoriesTableReferences),
          EntityCategory,
          PrefetchHooks Function({bool entityId, bool categoryId})
        > {
  $$EntityCategoriesTableTableManager(
    _$AppDatabase db,
    $EntityCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityCategoriesCompanion(
                entityId: entityId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityId,
                required String categoryId,
                Value<int> rowid = const Value.absent(),
              }) => EntityCategoriesCompanion.insert(
                entityId: entityId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntityCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entityId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entityId,
                                referencedTable:
                                    $$EntityCategoriesTableReferences
                                        ._entityIdTable(db),
                                referencedColumn:
                                    $$EntityCategoriesTableReferences
                                        ._entityIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$EntityCategoriesTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$EntityCategoriesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntityCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntityCategoriesTable,
      EntityCategory,
      $$EntityCategoriesTableFilterComposer,
      $$EntityCategoriesTableOrderingComposer,
      $$EntityCategoriesTableAnnotationComposer,
      $$EntityCategoriesTableCreateCompanionBuilder,
      $$EntityCategoriesTableUpdateCompanionBuilder,
      (EntityCategory, $$EntityCategoriesTableReferences),
      EntityCategory,
      PrefetchHooks Function({bool entityId, bool categoryId})
    >;
typedef $$EventCategoriesTableCreateCompanionBuilder =
    EventCategoriesCompanion Function({
      required String eventId,
      required String categoryId,
      Value<int> rowid,
    });
typedef $$EventCategoriesTableUpdateCompanionBuilder =
    EventCategoriesCompanion Function({
      Value<String> eventId,
      Value<String> categoryId,
      Value<int> rowid,
    });

final class $$EventCategoriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $EventCategoriesTable, EventCategory> {
  $$EventCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EventsTable _eventIdTable(_$AppDatabase db) =>
      db.events.createAlias('event_categories__event_id__events__id');

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('event_categories__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $EventCategoriesTable> {
  $$EventCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EventCategoriesTable> {
  $$EventCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventCategoriesTable> {
  $$EventCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventCategoriesTable,
          EventCategory,
          $$EventCategoriesTableFilterComposer,
          $$EventCategoriesTableOrderingComposer,
          $$EventCategoriesTableAnnotationComposer,
          $$EventCategoriesTableCreateCompanionBuilder,
          $$EventCategoriesTableUpdateCompanionBuilder,
          (EventCategory, $$EventCategoriesTableReferences),
          EventCategory,
          PrefetchHooks Function({bool eventId, bool categoryId})
        > {
  $$EventCategoriesTableTableManager(
    _$AppDatabase db,
    $EventCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventCategoriesCompanion(
                eventId: eventId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String categoryId,
                Value<int> rowid = const Value.absent(),
              }) => EventCategoriesCompanion.insert(
                eventId: eventId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EventCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable:
                                    $$EventCategoriesTableReferences
                                        ._eventIdTable(db),
                                referencedColumn:
                                    $$EventCategoriesTableReferences
                                        ._eventIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$EventCategoriesTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$EventCategoriesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventCategoriesTable,
      EventCategory,
      $$EventCategoriesTableFilterComposer,
      $$EventCategoriesTableOrderingComposer,
      $$EventCategoriesTableAnnotationComposer,
      $$EventCategoriesTableCreateCompanionBuilder,
      $$EventCategoriesTableUpdateCompanionBuilder,
      (EventCategory, $$EventCategoriesTableReferences),
      EventCategory,
      PrefetchHooks Function({bool eventId, bool categoryId})
    >;
typedef $$EvidenceCategoriesTableCreateCompanionBuilder =
    EvidenceCategoriesCompanion Function({
      required String evidenceId,
      required String categoryId,
      Value<int> rowid,
    });
typedef $$EvidenceCategoriesTableUpdateCompanionBuilder =
    EvidenceCategoriesCompanion Function({
      Value<String> evidenceId,
      Value<String> categoryId,
      Value<int> rowid,
    });

final class $$EvidenceCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EvidenceCategoriesTable,
          EvidenceCategory
        > {
  $$EvidenceCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EvidenceRecordsTable _evidenceIdTable(_$AppDatabase db) => db
      .evidenceRecords
      .createAlias('evidence_categories__evidence_id__evidence__id');

  $$EvidenceRecordsTableProcessedTableManager get evidenceId {
    final $_column = $_itemColumn<String>('evidence_id')!;

    final manager = $$EvidenceRecordsTableTableManager(
      $_db,
      $_db.evidenceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_evidenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('evidence_categories__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EvidenceCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $EvidenceCategoriesTable> {
  $$EvidenceCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EvidenceRecordsTableFilterComposer get evidenceId {
    final $$EvidenceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidenceCategoriesTable> {
  $$EvidenceCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EvidenceRecordsTableOrderingComposer get evidenceId {
    final $$EvidenceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidenceCategoriesTable> {
  $$EvidenceCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EvidenceRecordsTableAnnotationComposer get evidenceId {
    final $$EvidenceRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidenceId,
      referencedTable: $db.evidenceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvidenceCategoriesTable,
          EvidenceCategory,
          $$EvidenceCategoriesTableFilterComposer,
          $$EvidenceCategoriesTableOrderingComposer,
          $$EvidenceCategoriesTableAnnotationComposer,
          $$EvidenceCategoriesTableCreateCompanionBuilder,
          $$EvidenceCategoriesTableUpdateCompanionBuilder,
          (EvidenceCategory, $$EvidenceCategoriesTableReferences),
          EvidenceCategory,
          PrefetchHooks Function({bool evidenceId, bool categoryId})
        > {
  $$EvidenceCategoriesTableTableManager(
    _$AppDatabase db,
    $EvidenceCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidenceCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidenceCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidenceCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> evidenceId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvidenceCategoriesCompanion(
                evidenceId: evidenceId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String evidenceId,
                required String categoryId,
                Value<int> rowid = const Value.absent(),
              }) => EvidenceCategoriesCompanion.insert(
                evidenceId: evidenceId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EvidenceCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({evidenceId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (evidenceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.evidenceId,
                                referencedTable:
                                    $$EvidenceCategoriesTableReferences
                                        ._evidenceIdTable(db),
                                referencedColumn:
                                    $$EvidenceCategoriesTableReferences
                                        ._evidenceIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$EvidenceCategoriesTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$EvidenceCategoriesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EvidenceCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvidenceCategoriesTable,
      EvidenceCategory,
      $$EvidenceCategoriesTableFilterComposer,
      $$EvidenceCategoriesTableOrderingComposer,
      $$EvidenceCategoriesTableAnnotationComposer,
      $$EvidenceCategoriesTableCreateCompanionBuilder,
      $$EvidenceCategoriesTableUpdateCompanionBuilder,
      (EvidenceCategory, $$EvidenceCategoriesTableReferences),
      EvidenceCategory,
      PrefetchHooks Function({bool evidenceId, bool categoryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EntitiesTableTableManager get entities =>
      $$EntitiesTableTableManager(_db, _db.entities);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$EvidenceRecordsTableTableManager get evidenceRecords =>
      $$EvidenceRecordsTableTableManager(_db, _db.evidenceRecords);
  $$RelationshipsTableTableManager get relationships =>
      $$RelationshipsTableTableManager(_db, _db.relationships);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$MemoryCandidatesTableTableManager get memoryCandidates =>
      $$MemoryCandidatesTableTableManager(_db, _db.memoryCandidates);
  $$FieldProvenanceRowsTableTableManager get fieldProvenanceRows =>
      $$FieldProvenanceRowsTableTableManager(_db, _db.fieldProvenanceRows);
  $$CandidateExtractedFieldsTableTableManager get candidateExtractedFields =>
      $$CandidateExtractedFieldsTableTableManager(
        _db,
        _db.candidateExtractedFields,
      );
  $$CandidateEntityProposalsTableTableManager get candidateEntityProposals =>
      $$CandidateEntityProposalsTableTableManager(
        _db,
        _db.candidateEntityProposals,
      );
  $$FeatureUsageTableTableManager get featureUsage =>
      $$FeatureUsageTableTableManager(_db, _db.featureUsage);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$EntityTagsTableTableManager get entityTags =>
      $$EntityTagsTableTableManager(_db, _db.entityTags);
  $$EventTagsTableTableManager get eventTags =>
      $$EventTagsTableTableManager(_db, _db.eventTags);
  $$EvidenceTagsTableTableManager get evidenceTags =>
      $$EvidenceTagsTableTableManager(_db, _db.evidenceTags);
  $$EntityCategoriesTableTableManager get entityCategories =>
      $$EntityCategoriesTableTableManager(_db, _db.entityCategories);
  $$EventCategoriesTableTableManager get eventCategories =>
      $$EventCategoriesTableTableManager(_db, _db.eventCategories);
  $$EvidenceCategoriesTableTableManager get evidenceCategories =>
      $$EvidenceCategoriesTableTableManager(_db, _db.evidenceCategories);
}
