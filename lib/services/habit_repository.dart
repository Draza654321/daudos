import '../models/habit.dart';
import 'database_service.dart';
import 'firebase_service.dart';

class HabitRepository {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // Create habit
  Future<void> createHabit(Habit habit) async {
    final data = habit.toJson();
    await _databaseService.insert('habits', data);
    await _firebaseService.syncRecord('habits', habit.id, data, 'INSERT');
  }

  // Get habit by ID
  Future<Habit?> getHabitById(String id) async {
    final results = await _databaseService.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isNotEmpty) {
      return Habit.fromJson(results.first);
    }
    return null;
  }

  // Get habits for user
  Future<List<Habit>> getHabitsForUser(String userId) async {
    final results = await _databaseService.query(
      'habits',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    
    return results.map((data) => Habit.fromJson(data)).toList();
  }

  // Get active habits
  Future<List<Habit>> getActiveHabits(String userId) async {
    final results = await _databaseService.query(
      'habits',
      where: 'userId = ? AND isActive = 1',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    
    return results.map((data) => Habit.fromJson(data)).toList();
  }

  // Get habits by type
  Future<List<Habit>> getHabitsByType(String userId, HabitType type) async {
    final results = await _databaseService.query(
      'habits',
      where: 'userId = ? AND type = ? AND isActive = 1',
      whereArgs: [userId, type.name],
      orderBy: 'createdAt DESC',
    );
    
    return results.map((data) => Habit.fromJson(data)).toList();
  }

  // Update habit
  Future<void> updateHabit(Habit habit) async {
    final data = habit.toJson();
    await _databaseService.update(
      'habits',
      data,
      'id = ?',
      [habit.id],
    );
    await _firebaseService.syncRecord('habits', habit.id, data, 'UPDATE');
  }

  // Delete habit
  Future<void> deleteHabit(String id) async {
    await _databaseService.delete('habits', 'id = ?', [id]);
    await _firebaseService.syncRecord('habits', id, {}, 'DELETE');
  }

  // Create habit entry
  Future<void> createHabitEntry(HabitEntry entry) async {
    final data = entry.toJson();
    await _databaseService.insert('habit_entries', data);
    await _firebaseService.syncRecord('habit_entries', entry.id, data, 'INSERT');
  }

  // Get habit entry for date
  Future<HabitEntry?> getHabitEntryForDate(String habitId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    final results = await _databaseService.query(
      'habit_entries',
      where: 'habitId = ? AND date >= ? AND date < ?',
      whereArgs: [habitId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      return HabitEntry.fromJson(results.first);
    }
    return null;
  }

  // Get habit entries for date range
  Future<List<HabitEntry>> getHabitEntriesForDateRange(
    String habitId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final results = await _databaseService.query(
      'habit_entries',
      where: 'habitId = ? AND date >= ? AND date <= ?',
      whereArgs: [habitId, startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date ASC',
    );
    
    return results.map((data) => HabitEntry.fromJson(data)).toList();
  }

  // Update habit entry
  Future<void> updateHabitEntry(HabitEntry entry) async {
    final data = entry.toJson();
    await _databaseService.update(
      'habit_entries',
      data,
      'id = ?',
      [entry.id],
    );
    await _firebaseService.syncRecord('habit_entries', entry.id, data, 'UPDATE');
  }

  // Calculate habit streak
  Future<int> calculateHabitStreak(String habitId) async {
    final today = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final entry = await getHabitEntryForDate(habitId, checkDate);
      
      if (entry != null && entry.completed) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  // Get habit completion rate for date range
  Future<double> getHabitCompletionRate(String habitId, DateTime startDate, DateTime endDate) async {
    final entries = await getHabitEntriesForDateRange(habitId, startDate, endDate);
    if (entries.isEmpty) return 0.0;
    
    final completedEntries = entries.where((entry) => entry.completed).length;
    return completedEntries / entries.length;
  }

  // Get all habit entries for user and date
  Future<List<HabitEntry>> getHabitEntriesForUserAndDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    final results = await _databaseService.query(
      'habit_entries',
      where: 'userId = ? AND date >= ? AND date < ?',
      whereArgs: [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    
    return results.map((data) => HabitEntry.fromJson(data)).toList();
  }
}

