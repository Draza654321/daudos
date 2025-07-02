import 'dart:convert';
import '../models/user.dart';
import 'database_service.dart';
import 'firebase_service.dart';

class UserRepository {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // Create user
  Future<void> createUser(User user) async {
    final data = user.toJson();
    await _databaseService.insert('users', data);
    await _firebaseService.syncRecord('users', user.id, data, 'INSERT');
  }

  // Get user by ID
  Future<User?> getUserById(String id) async {
    final results = await _databaseService.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isNotEmpty) {
      return User.fromJson(results.first);
    }
    return null;
  }

  // Update user
  Future<void> updateUser(User user) async {
    final data = user.toJson();
    await _databaseService.update(
      'users',
      data,
      'id = ?',
      [user.id],
    );
    await _firebaseService.syncRecord('users', user.id, data, 'UPDATE');
  }

  // Delete user
  Future<void> deleteUser(String id) async {
    await _databaseService.delete('users', 'id = ?', [id]);
    await _firebaseService.syncRecord('users', id, {}, 'DELETE');
  }

  // Get current user (assuming single user app)
  Future<User?> getCurrentUser() async {
    final results = await _databaseService.query('users', limit: 1);
    if (results.isNotEmpty) {
      return User.fromJson(results.first);
    }
    return null;
  }

  // Check if user exists
  Future<bool> userExists(String id) async {
    final results = await _databaseService.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty;
  }
}

