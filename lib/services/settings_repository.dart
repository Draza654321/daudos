import '../models/settings.dart';
import 'database_service.dart';
import 'firebase_service.dart';

class SettingsRepository {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // Create settings
  Future<void> createSettings(AppSettings settings) async {
    try {
      final data = settings.toJson();
      await _databaseService.insert('settings', data);
      await _firebaseService.syncRecord('settings', settings.id, data, 'INSERT');
    } catch (e) {
      print('Error creating settings: $e');
      rethrow;
    }
  }

  // Get settings by ID
  Future<AppSettings?> getSettingsById(String id) async {
    try {
      final results = await _databaseService.query(
        'settings',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (results.isNotEmpty) {
        return AppSettings.fromJson(results.first);
      }
      return null;
    } catch (e) {
      print('Error getting settings by ID: $e');
      return null;
    }
  }

  // Get settings for user
  Future<AppSettings?> getSettingsForUser(String userId) async {
    try {
      final results = await _databaseService.query(
        'settings',
        where: 'userId = ?',
        whereArgs: [userId],
        limit: 1,
      );
      
      if (results.isNotEmpty) {
        return AppSettings.fromJson(results.first);
      }
      return null;
    } catch (e) {
      print('Error getting settings for user: $e');
      return null;
    }
  }

  // Update settings
  Future<void> updateSettings(AppSettings settings) async {
    try {
      final data = settings.toJson();
      await _databaseService.update(
        'settings',
        data,
        'id = ?',
        [settings.id],
      );
      await _firebaseService.syncRecord('settings', settings.id, data, 'UPDATE');
    } catch (e) {
      print('Error updating settings: $e');
      rethrow;
    }
  }

  // Delete settings
  Future<void> deleteSettings(String id) async {
    try {
      await _databaseService.delete('settings', 'id = ?', [id]);
      await _firebaseService.syncRecord('settings', id, {}, 'DELETE');
    } catch (e) {
      print('Error deleting settings: $e');
      rethrow;
    }
  }

  // Delete all settings (for app reset)
  Future<void> deleteAllSettings() async {
    try {
      await _databaseService.delete('settings', null, null);
      // Note: This would typically also clear Firebase settings
      print('All settings deleted successfully');
    } catch (e) {
      print('Error deleting all settings: $e');
      rethrow;
    }
  }

  // Get all settings (for backup/export)
  Future<List<AppSettings>> getAllSettings() async {
    try {
      final results = await _databaseService.query('settings');
      return results.map((data) => AppSettings.fromJson(data)).toList();
    } catch (e) {
      print('Error getting all settings: $e');
      return [];
    }
  }

  // Backup settings to Firebase
  Future<void> backupSettings(AppSettings settings) async {
    try {
      await _firebaseService.backupData('settings', settings.id, settings.toJson());
    } catch (e) {
      print('Error backing up settings: $e');
      rethrow;
    }
  }

  // Restore settings from Firebase
  Future<AppSettings?> restoreSettings(String userId) async {
    try {
      final data = await _firebaseService.restoreData('settings', 'settings_$userId');
      if (data != null) {
        return AppSettings.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error restoring settings: $e');
      return null;
    }
  }

  // Check if settings exist for user
  Future<bool> settingsExistForUser(String userId) async {
    try {
      final settings = await getSettingsForUser(userId);
      return settings != null;
    } catch (e) {
      print('Error checking if settings exist: $e');
      return false;
    }
  }

  // Get settings count
  Future<int> getSettingsCount() async {
    try {
      final results = await _databaseService.query('settings');
      return results.length;
    } catch (e) {
      print('Error getting settings count: $e');
      return 0;
    }
  }
}

