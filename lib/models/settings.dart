enum UIMode { warrior, clarity, dark, light }

enum BackupFrequency { manual, daily, weekly }

class AppSettings {
  final String id;
  final String userId;
  final UIMode uiMode;
  final bool ttsEnabled;
  final double ttsSpeed; // 0.5 to 2.0
  final bool notificationsEnabled;
  final bool habitRemindersEnabled;
  final bool motivationalQuotesEnabled;
  final bool motivationEngineEnabled;
  final bool appLockEnabled;
  final String? appLockPin;
  final bool biometricLockEnabled;
  final bool firebaseBackupEnabled;
  final bool autoSyncEnabled;
  final BackupFrequency backupFrequency;
  final bool offlineFirstEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppSettings({
    required this.id,
    required this.userId,
    required this.uiMode,
    required this.ttsEnabled,
    required this.ttsSpeed,
    required this.notificationsEnabled,
    required this.habitRemindersEnabled,
    required this.motivationalQuotesEnabled,
    required this.motivationEngineEnabled,
    required this.appLockEnabled,
    this.appLockPin,
    required this.biometricLockEnabled,
    required this.firebaseBackupEnabled,
    required this.autoSyncEnabled,
    required this.backupFrequency,
    required this.offlineFirstEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'uiMode': uiMode.name,
      'ttsEnabled': ttsEnabled,
      'ttsSpeed': ttsSpeed,
      'notificationsEnabled': notificationsEnabled,
      'habitRemindersEnabled': habitRemindersEnabled,
      'motivationalQuotesEnabled': motivationalQuotesEnabled,
      'motivationEngineEnabled': motivationEngineEnabled,
      'appLockEnabled': appLockEnabled,
      'appLockPin': appLockPin,
      'biometricLockEnabled': biometricLockEnabled,
      'firebaseBackupEnabled': firebaseBackupEnabled,
      'autoSyncEnabled': autoSyncEnabled,
      'backupFrequency': backupFrequency.name,
      'offlineFirstEnabled': offlineFirstEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'],
      userId: json['userId'],
      uiMode: UIMode.values.firstWhere((e) => e.name == json['uiMode']),
      ttsEnabled: json['ttsEnabled'],
      ttsSpeed: json['ttsSpeed'].toDouble(),
      notificationsEnabled: json['notificationsEnabled'],
      habitRemindersEnabled: json['habitRemindersEnabled'] ?? true,
      motivationalQuotesEnabled: json['motivationalQuotesEnabled'] ?? true,
      motivationEngineEnabled: json['motivationEngineEnabled'],
      appLockEnabled: json['appLockEnabled'],
      appLockPin: json['appLockPin'],
      biometricLockEnabled: json['biometricLockEnabled'],
      firebaseBackupEnabled: json['firebaseBackupEnabled'],
      autoSyncEnabled: json['autoSyncEnabled'] ?? true,
      backupFrequency: BackupFrequency.values.firstWhere((e) => e.name == json['backupFrequency']),
      offlineFirstEnabled: json['offlineFirstEnabled'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  AppSettings copyWith({
    String? id,
    String? userId,
    UIMode? uiMode,
    bool? ttsEnabled,
    double? ttsSpeed,
    bool? notificationsEnabled,
    bool? habitRemindersEnabled,
    bool? motivationalQuotesEnabled,
    bool? motivationEngineEnabled,
    bool? appLockEnabled,
    String? appLockPin,
    bool? biometricLockEnabled,
    bool? firebaseBackupEnabled,
    bool? autoSyncEnabled,
    BackupFrequency? backupFrequency,
    bool? offlineFirstEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      uiMode: uiMode ?? this.uiMode,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      habitRemindersEnabled: habitRemindersEnabled ?? this.habitRemindersEnabled,
      motivationalQuotesEnabled: motivationalQuotesEnabled ?? this.motivationalQuotesEnabled,
      motivationEngineEnabled: motivationEngineEnabled ?? this.motivationEngineEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      appLockPin: appLockPin ?? this.appLockPin,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      firebaseBackupEnabled: firebaseBackupEnabled ?? this.firebaseBackupEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      offlineFirstEnabled: offlineFirstEnabled ?? this.offlineFirstEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppSettings.defaultSettings(String userId) {
    final now = DateTime.now();
    return AppSettings(
      id: 'settings_$userId',
      userId: userId,
      uiMode: UIMode.dark,
      ttsEnabled: true,
      ttsSpeed: 1.0,
      notificationsEnabled: true,
      habitRemindersEnabled: true,
      motivationalQuotesEnabled: true,
      motivationEngineEnabled: true,
      appLockEnabled: false,
      appLockPin: null,
      biometricLockEnabled: false,
      firebaseBackupEnabled: false,
      autoSyncEnabled: true,
      backupFrequency: BackupFrequency.manual,
      offlineFirstEnabled: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}

