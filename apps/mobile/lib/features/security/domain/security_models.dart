enum AutoLockPreference {
  immediately,
  oneMinute,
  fiveMinutes,
  fifteenMinutes,
  appRestart;

  Duration? get backgroundDelay => switch (this) {
    immediately => Duration.zero,
    oneMinute => const Duration(minutes: 1),
    fiveMinutes => const Duration(minutes: 5),
    fifteenMinutes => const Duration(minutes: 15),
    appRestart => null,
  };
}

final class SecuritySettings {
  const SecuritySettings({
    this.appLockEnabled = false,
    this.biometricsEnabled = false,
    this.autoLock = AutoLockPreference.appRestart,
    this.recoveryConfigured = false,
  });

  factory SecuritySettings.fromJson(Map<String, Object?> json) =>
      SecuritySettings(
        appLockEnabled: json['appLockEnabled'] as bool? ?? false,
        biometricsEnabled: json['biometricsEnabled'] as bool? ?? false,
        autoLock: AutoLockPreference.values.firstWhere(
          (value) => value.name == json['autoLock'],
          orElse: () => AutoLockPreference.appRestart,
        ),
        recoveryConfigured: json['recoveryConfigured'] as bool? ?? false,
      );

  final bool appLockEnabled;
  final AutoLockPreference autoLock;
  final bool biometricsEnabled;
  final bool recoveryConfigured;

  SecuritySettings copyWith({
    bool? appLockEnabled,
    AutoLockPreference? autoLock,
    bool? biometricsEnabled,
    bool? recoveryConfigured,
  }) => SecuritySettings(
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    autoLock: autoLock ?? this.autoLock,
    biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    recoveryConfigured: recoveryConfigured ?? this.recoveryConfigured,
  );

  Map<String, Object> toJson() => {
    'appLockEnabled': appLockEnabled,
    'biometricsEnabled': biometricsEnabled,
    'autoLock': autoLock.name,
    'recoveryConfigured': recoveryConfigured,
  };
}

enum PinAttemptStatus { success, invalid, throttled, notConfigured }

final class PinAttemptResult {
  const PinAttemptResult(this.status, {this.retryAfter = Duration.zero});

  final Duration retryAfter;
  final PinAttemptStatus status;
}

enum BiometricResult {
  success,
  unavailable,
  canceled,
  temporarilyLocked,
  failed,
}

final class SecuritySessionState {
  const SecuritySessionState({
    required this.settings,
    required this.locked,
    required this.biometricAvailable,
    this.backgroundedAt,
  });

  final bool biometricAvailable;
  final DateTime? backgroundedAt;
  final bool locked;
  final SecuritySettings settings;

  SecuritySessionState copyWith({
    bool? biometricAvailable,
    DateTime? backgroundedAt,
    bool clearBackgroundedAt = false,
    bool? locked,
    SecuritySettings? settings,
  }) => SecuritySessionState(
    settings: settings ?? this.settings,
    locked: locked ?? this.locked,
    biometricAvailable: biometricAvailable ?? this.biometricAvailable,
    backgroundedAt: clearBackgroundedAt
        ? null
        : backgroundedAt ?? this.backgroundedAt,
  );
}

final class SecurityFailure implements Exception {
  const SecurityFailure(this.code);

  final String code;

  @override
  String toString() => 'SecurityFailure($code)';
}
