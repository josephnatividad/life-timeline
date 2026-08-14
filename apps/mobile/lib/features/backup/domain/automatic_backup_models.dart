enum AutomaticBackupFrequency { daily, weekly }

enum AutomaticBackupNetworkPolicy { wifiOnly, anyNetwork }

final class AutomaticBackupSettings {
  const AutomaticBackupSettings({
    this.enabled = false,
    this.frequency = AutomaticBackupFrequency.weekly,
    this.networkPolicy = AutomaticBackupNetworkPolicy.wifiOnly,
    this.preferCharging = true,
    this.retentionCount = 3,
  });

  factory AutomaticBackupSettings.fromJson(Map<String, Object?> json) =>
      AutomaticBackupSettings(
        enabled: json['enabled'] as bool? ?? false,
        frequency: AutomaticBackupFrequency.values.byName(
          json['frequency'] as String? ?? AutomaticBackupFrequency.weekly.name,
        ),
        networkPolicy: AutomaticBackupNetworkPolicy.values.byName(
          json['networkPolicy'] as String? ??
              AutomaticBackupNetworkPolicy.wifiOnly.name,
        ),
        preferCharging: json['preferCharging'] as bool? ?? true,
        retentionCount: (json['retentionCount'] as int? ?? 3).clamp(1, 10),
      );

  final bool enabled;
  final AutomaticBackupFrequency frequency;
  final AutomaticBackupNetworkPolicy networkPolicy;
  final bool preferCharging;
  final int retentionCount;

  Duration get interval => switch (frequency) {
    AutomaticBackupFrequency.daily => const Duration(days: 1),
    AutomaticBackupFrequency.weekly => const Duration(days: 7),
  };

  AutomaticBackupSettings copyWith({
    bool? enabled,
    AutomaticBackupFrequency? frequency,
    AutomaticBackupNetworkPolicy? networkPolicy,
    bool? preferCharging,
    int? retentionCount,
  }) => AutomaticBackupSettings(
    enabled: enabled ?? this.enabled,
    frequency: frequency ?? this.frequency,
    networkPolicy: networkPolicy ?? this.networkPolicy,
    preferCharging: preferCharging ?? this.preferCharging,
    retentionCount: retentionCount ?? this.retentionCount,
  );

  Map<String, Object> toJson() => {
    'enabled': enabled,
    'frequency': frequency.name,
    'networkPolicy': networkPolicy.name,
    'preferCharging': preferCharging,
    'retentionCount': retentionCount,
  };
}

enum AutomaticBackupStage {
  idle,
  checking,
  preparing,
  encrypting,
  uploading,
  verifying,
  applyingRetention,
  complete,
}

enum AutomaticBackupRunResult {
  completed,
  disabled,
  noChanges,
  notDue,
  networkDeferred,
  authorizationRequired,
  credentialUnavailable,
  failed,
}

final class AutomaticBackupRunState {
  const AutomaticBackupRunState({
    this.running = false,
    this.stage = AutomaticBackupStage.idle,
    this.lastAttemptAt,
    this.lastSuccessAt,
    this.lastResult,
    this.lastErrorCode,
  });

  factory AutomaticBackupRunState.fromJson(Map<String, Object?> json) =>
      AutomaticBackupRunState(
        lastAttemptAt: _date(json['lastAttemptAt']),
        lastSuccessAt: _date(json['lastSuccessAt']),
        lastResult: switch (json['lastResult']) {
          final String value => AutomaticBackupRunResult.values.byName(value),
          _ => null,
        },
        lastErrorCode: json['lastErrorCode'] as String?,
      );

  final String? lastErrorCode;
  final DateTime? lastAttemptAt;
  final AutomaticBackupRunResult? lastResult;
  final DateTime? lastSuccessAt;
  final bool running;
  final AutomaticBackupStage stage;

  AutomaticBackupRunState copyWith({
    bool? running,
    AutomaticBackupStage? stage,
    DateTime? lastAttemptAt,
    DateTime? lastSuccessAt,
    AutomaticBackupRunResult? lastResult,
    String? lastErrorCode,
    bool clearError = false,
  }) => AutomaticBackupRunState(
    running: running ?? this.running,
    stage: stage ?? this.stage,
    lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
    lastResult: lastResult ?? this.lastResult,
    lastErrorCode: clearError ? null : lastErrorCode ?? this.lastErrorCode,
  );

  Map<String, Object?> toJson() => {
    'lastAttemptAt': lastAttemptAt?.toIso8601String(),
    'lastSuccessAt': lastSuccessAt?.toIso8601String(),
    'lastResult': lastResult?.name,
    'lastErrorCode': lastErrorCode,
  };
}

DateTime? _date(Object? value) => switch (value) {
  final String text => DateTime.tryParse(text)?.toUtc(),
  _ => null,
};
