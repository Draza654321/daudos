import '../models/mind_gym.dart';
import 'database_service.dart';
import 'firebase_service.dart';

class MindGymRepository {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // Create session
  Future<void> createSession(MindGymSession session) async {
    final data = session.toJson();
    await _databaseService.insert('mind_gym_sessions', data);
    await _firebaseService.syncRecord('mind_gym_sessions', session.id, data, 'INSERT');
  }

  // Get sessions for user
  Future<List<MindGymSession>> getSessionsForUser(String userId) async {
    final results = await _databaseService.query(
      'mind_gym_sessions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'startTime DESC',
    );
    
    return results.map((data) => MindGymSession.fromJson(data)).toList();
  }

  // Update session
  Future<void> updateSession(MindGymSession session) async {
    final data = session.toJson();
    await _databaseService.update(
      'mind_gym_sessions',
      data,
      'id = ?',
      [session.id],
    );
    await _firebaseService.syncRecord('mind_gym_sessions', session.id, data, 'UPDATE');
  }

  // Delete session
  Future<void> deleteSession(String id) async {
    await _databaseService.delete('mind_gym_sessions', 'id = ?', [id]);
    await _firebaseService.syncRecord('mind_gym_sessions', id, {}, 'DELETE');
  }

  // Brain dump methods
  Future<void> saveBrainDumpEntry(String userId, String entry) async {
    final data = {
      'id': 'brain_dump_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'entry': entry,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _databaseService.insert('brain_dump_entries', data);
    await _firebaseService.syncRecord('brain_dump_entries', data['id'], data, 'INSERT');
  }

  Future<List<String>> getBrainDumpEntries(String userId) async {
    final results = await _databaseService.query(
      'brain_dump_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: 50,
    );
    
    return results.map((data) => data['entry'] as String).toList();
  }

  Future<void> deleteBrainDumpEntry(String userId, int index) async {
    final results = await _databaseService.query(
      'brain_dump_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: 50,
    );
    
    if (index < results.length) {
      final entryId = results[index]['id'];
      await _databaseService.delete('brain_dump_entries', 'id = ?', [entryId]);
      await _firebaseService.syncRecord('brain_dump_entries', entryId, {}, 'DELETE');
    }
  }
}

