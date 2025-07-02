import 'package:flutter/foundation.dart';
import '../models/settings.dart';
import '../services/settings_repository.dart';
import '../services/user_repository.dart';
import '../services/sync_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository = SettingsRepository();
  final UserRepository _userRepository = UserRepository();
  final SyncService _syncService = SyncService();

  AppSettings? _settings;
  bool _isLoading = false;
  bool _isBackingUp = false;

  // Getters
  AppSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isBackingUp => _isBackingUp;
  
  UIMode get currentUIMode => _settings?.uiMode ?? UIMode.dark;
  bool get ttsEnabled => _settings?.ttsEnabled ?? true;
  double get ttsSpeed => _settings?.ttsSpeed ?? 1.0;
  bool get notificationsEnabled => _settings?.notificationsEnabled ?? true;
  bool get motivationEngineEnabled => _settings?.motivationEngineEnabled ?? true;
  bool get appLockEnabled => _settings?.appLockEnabled ?? false;
  bool get biometricLockEnabled => _settings?.biometricLockEnabled ?? false;
  bool get firebaseBackupEnabled => _settings?.firebaseBackupEnabled ?? false;
  BackupFrequency get backupFrequency => _settings?.backupFrequency ?? BackupFrequency.manual;
  bool get offlineFirstEnabled => _settings?.offlineFirstEnabled ?? true;

  // Initialize settings
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        _settings = await _settingsRepository.getSettingsForUser(user.id);
        if (_settings == null) {
          // Create default settings
          _settings = AppSettings.defaultSettings(user.id);
          await _settingsRepository.createSettings(_settings!);
        }
      }
    } catch (e) {
      print('Error initializing settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update UI mode
  Future<void> updateUIMode(UIMode mode) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        uiMode: mode,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error updating UI mode: $e');
    }
  }

  // Toggle app lock
  Future<void> toggleAppLock(bool enabled) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        appLockEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error toggling app lock: $e');
    }
  }

  // Toggle biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        biometricLockEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error toggling biometric: $e');
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        notificationsEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error toggling notifications: $e');
    }
  }

  // Toggle habit reminders
  Future<void> toggleHabitReminders(bool enabled) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        habitRemindersEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error toggling habit reminders: $e');
    }
  }

  // Toggle motivational quotes
  Future<void> toggleMotivationalQuotes(bool enabled) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        motivationalQuotesEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error toggling motivational quotes: $e');
    }
  }

  // Toggle Firebase backup
  Future<void> toggleFirebaseBackup(bool enabled) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        firebaseBackupEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error toggling Firebase backup: $e');
    }
  }

  // Toggle auto sync
  Future<void> toggleAutoSync(bool enabled) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        autoSyncEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error toggling auto sync: $e');
    }
  }

  // Perform manual backup
  Future<void> performManualBackup() async {
    _isBackingUp = true;
    notifyListeners();

    try {
      await _syncService.performFullSync();
      print('Manual backup completed successfully');
    } catch (e) {
      print('Error performing manual backup: $e');
    } finally {
      _isBackingUp = false;
      notifyListeners();
    }
  }

  // Export data
  Future<void> exportData() async {
    try {
      // Implementation for exporting user data
      print('Exporting data...');
      // This would typically create a JSON file with all user data
    } catch (e) {
      print('Error exporting data: $e');
    }
  }

  // Reset app
  Future<void> resetApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear all local data
      await _settingsRepository.deleteAllSettings();
      
      // Reset to default settings
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        _settings = AppSettings.defaultSettings(user.id);
        await _settingsRepository.createSettings(_settings!);
      }
      
      print('App reset completed');
    } catch (e) {
      print('Error resetting app: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update TTS settings
  Future<void> updateTTSSettings({bool? enabled, double? speed}) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        ttsEnabled: enabled ?? _settings!.ttsEnabled,
        ttsSpeed: speed ?? _settings!.ttsSpeed,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error updating TTS settings: $e');
    }
  }

  // Update notifications
  Future<void> updateNotificationsEnabled(bool enabled) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        notificationsEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error updating notifications: $e');
    }
  }

  // Update motivation engine
  Future<void> updateMotivationEngineEnabled(bool enabled) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        motivationEngineEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error updating motivation engine: $e');
    }
  }

  // Update app lock settings
  Future<void> updateAppLockSettings({
    bool? enabled,
    String? pin,
    bool? biometricEnabled,
  }) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        appLockEnabled: enabled ?? _settings!.appLockEnabled,
        appLockPin: pin ?? _settings!.appLockPin,
        biometricLockEnabled: biometricEnabled ?? _settings!.biometricLockEnabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error updating app lock settings: $e');
    }
  }

  // Update Firebase backup settings
  Future<void> updateFirebaseBackupSettings({
    bool? enabled,
    BackupFrequency? frequency,
  }) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        firebaseBackupEnabled: enabled ?? _settings!.firebaseBackupEnabled,
        backupFrequency: frequency ?? _settings!.backupFrequency,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error updating Firebase backup settings: $e');
    }
  }

  // Update offline first setting
  Future<void> updateOfflineFirstEnabled(bool enabled) async {
    if (_settings == null) return;

    try {
      final updatedSettings = _settings!.copyWith(
        offlineFirstEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.updateSettings(updatedSettings);
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      print('Error updating offline first setting: $e');
    }
  }

  // Get UI mode display name
  String getUIModeDisplayName(UIMode mode) {
    switch (mode) {
      case UIMode.warrior:
        return 'Warrior Mode';
      case UIMode.clarity:
        return 'Clarity Mode';
      case UIMode.dark:
        return 'Dark Mode';
      case UIMode.light:
        return 'Light Mode';
    }
  }

  // Get UI mode description
  String getUIModeDescription(UIMode mode) {
    switch (mode) {
      case UIMode.warrior:
        return 'High-energy theme for intense work sessions';
      case UIMode.clarity:
        return 'Clean, minimal theme for focused thinking';
      case UIMode.dark:
        return 'Dark theme for comfortable night usage';
      case UIMode.light:
        return 'Light theme for daytime productivity';
    }
  }

  // Get backup frequency display name
  String getBackupFrequencyDisplayName(BackupFrequency frequency) {
    switch (frequency) {
      case BackupFrequency.manual:
        return 'Manual';
      case BackupFrequency.daily:
        return 'Daily';
      case BackupFrequency.weekly:
        return 'Weekly';
    }
  }

  // Reset settings to default
  Future<void> resetToDefaults() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        _settings = AppSettings.defaultSettings(user.id);
        await _settingsRepository.updateSettings(_settings!);
      }
    } catch (e) {
      print('Error resetting settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    if (_settings == null) return {};
    return _settings!.toJson();
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> settingsData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final importedSettings = AppSettings.fromJson(settingsData);
      await _settingsRepository.updateSettings(importedSettings);
      _settings = importedSettings;
    } catch (e) {
      print('Error importing settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh settings
  Future<void> refresh() async {
    await initialize();
  }
}

