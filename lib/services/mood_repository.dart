import '../models/mood.dart';
import 'database_service.dart';
import 'firebase_service.dart';

class MoodRepository {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // Create mood entry
  Future<void> createMood(Mood mood) async {
    final data = mood.toJson();
    await _databaseService.insert('moods', data);
    await _firebaseService.syncRecord('moods', mood.id, data, 'INSERT');
  }

  // Get mood by ID
  Future<Mood?> getMoodById(String id) async {
    final results = await _databaseService.query(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isNotEmpty) {
      return Mood.fromJson(results.first);
    }
    return null;
  }

  // Get moods for user
  Future<List<Mood>> getMoodsForUser(String userId, {int? limit}) async {
    final results = await _databaseService.query(
      'moods',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    
    return results.map((data) => Mood.fromJson(data)).toList();
  }

  // Get mood for specific date
  Future<Mood?> getMoodForDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    final results = await _databaseService.query(
      'moods',
      where: 'userId = ? AND timestamp >= ? AND timestamp < ?',
      whereArgs: [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      return Mood.fromJson(results.first);
    }
    return null;
  }

  // Get moods for date range
  Future<List<Mood>> getMoodsForDateRange(String userId, DateTime startDate, DateTime endDate) async {
    final results = await _databaseService.query(
      'moods',
      where: 'userId = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [userId, startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp ASC',
    );
    
    return results.map((data) => Mood.fromJson(data)).toList();
  }

  // Update mood
  Future<void> updateMood(Mood mood) async {
    final data = mood.toJson();
    await _databaseService.update(
      'moods',
      data,
      'id = ?',
      [mood.id],
    );
    await _firebaseService.syncRecord('moods', mood.id, data, 'UPDATE');
  }

  // Delete mood
  Future<void> deleteMood(String id) async {
    await _databaseService.delete('moods', 'id = ?', [id]);
    await _firebaseService.syncRecord('moods', id, {}, 'DELETE');
  }

  // Get average mood score for date range
  Future<double> getAverageMoodScore(String userId, DateTime startDate, DateTime endDate) async {
    final moods = await getMoodsForDateRange(userId, startDate, endDate);
    if (moods.isEmpty) return 0.0;
    
    final totalScore = moods.fold<double>(0.0, (sum, mood) => sum + mood.averageScore);
    return totalScore / moods.length;
  }

  // Get mood trends (last 30 days)
  Future<Map<String, double>> getMoodTrends(String userId) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: 30));
    final moods = await getMoodsForDateRange(userId, startDate, endDate);
    
    if (moods.isEmpty) {
      return {
        'clarity': 0.0,
        'focus': 0.0,
        'energy': 0.0,
      };
    }
    
    final totalClarity = moods.fold<double>(0.0, (sum, mood) => sum + mood.clarity);
    final totalFocus = moods.fold<double>(0.0, (sum, mood) => sum + mood.focus);
    final totalEnergy = moods.fold<double>(0.0, (sum, mood) => sum + mood.energy);
    final count = moods.length;
    
    return {
      'clarity': totalClarity / count,
      'focus': totalFocus / count,
      'energy': totalEnergy / count,
    };
  }

  // Get today's mood
  Future<Mood?> getTodaysMood(String userId) async {
    return await getMoodForDate(userId, DateTime.now());
  }

  // Check if mood exists for today
  Future<bool> hasMoodForToday(String userId) async {
    final mood = await getTodaysMood(userId);
    return mood != null;
  }
}

