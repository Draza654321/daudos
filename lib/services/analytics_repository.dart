import '../models/analytics.dart';
import 'database_service.dart';
import 'firebase_service.dart';

class AnalyticsRepository {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // Create daily analytics
  Future<void> createDailyAnalytics(DailyAnalytics analytics) async {
    final data = analytics.toJson();
    await _databaseService.insert('daily_analytics', data);
    await _firebaseService.syncRecord('daily_analytics', analytics.id, data, 'INSERT');
  }

  // Get daily analytics by ID
  Future<DailyAnalytics?> getDailyAnalyticsById(String id) async {
    final results = await _databaseService.query(
      'daily_analytics',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isNotEmpty) {
      return DailyAnalytics.fromJson(results.first);
    }
    return null;
  }

  // Get daily analytics for specific date
  Future<DailyAnalytics?> getDailyAnalytics(String userId, DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0];
    final results = await _databaseService.query(
      'daily_analytics',
      where: 'userId = ? AND date LIKE ?',
      whereArgs: [userId, '$dateString%'],
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      return DailyAnalytics.fromJson(results.first);
    }
    return null;
  }

  // Get daily analytics for date range
  Future<List<DailyAnalytics>> getDailyAnalyticsForDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final results = await _databaseService.query(
      'daily_analytics',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date ASC',
    );
    
    return results.map((data) => DailyAnalytics.fromJson(data)).toList();
  }

  // Update daily analytics
  Future<void> updateDailyAnalytics(DailyAnalytics analytics) async {
    final data = analytics.toJson();
    await _databaseService.update(
      'daily_analytics',
      data,
      'id = ?',
      [analytics.id],
    );
    await _firebaseService.syncRecord('daily_analytics', analytics.id, data, 'UPDATE');
  }

  // Delete daily analytics
  Future<void> deleteDailyAnalytics(String id) async {
    await _databaseService.delete('daily_analytics', 'id = ?', [id]);
    await _firebaseService.syncRecord('daily_analytics', id, {}, 'DELETE');
  }

  // Get analytics for last N days
  Future<List<DailyAnalytics>> getLastNDaysAnalytics(String userId, int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    return await getDailyAnalyticsForDateRange(userId, startDate, endDate);
  }

  // Get weekly analytics
  Future<List<DailyAnalytics>> getWeeklyAnalytics(String userId, DateTime weekStart) async {
    final weekEnd = weekStart.add(Duration(days: 6));
    return await getDailyAnalyticsForDateRange(userId, weekStart, weekEnd);
  }

  // Get monthly analytics
  Future<List<DailyAnalytics>> getMonthlyAnalytics(String userId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    
    return await getDailyAnalyticsForDateRange(userId, startOfMonth, endOfMonth);
  }

  // Calculate average scores for date range
  Future<Map<String, double>> getAverageScores(String userId, DateTime startDate, DateTime endDate) async {
    final analytics = await getDailyAnalyticsForDateRange(userId, startDate, endDate);
    
    if (analytics.isEmpty) {
      return {
        'taskCompletion': 0.0,
        'habitCompletion': 0.0,
        'moodScore': 0.0,
        'overallScore': 0.0,
      };
    }
    
    final totalTaskCompletion = analytics.fold<double>(0.0, (sum, a) => sum + a.taskCompletionRate);
    final totalHabitCompletion = analytics.fold<double>(0.0, (sum, a) => sum + a.habitCompletionRate);
    final totalMoodScore = analytics.fold<double>(0.0, (sum, a) => sum + a.averageMoodScore);
    final totalOverallScore = analytics.fold<double>(0.0, (sum, a) => sum + a.overallScore);
    
    final count = analytics.length;
    
    return {
      'taskCompletion': totalTaskCompletion / count,
      'habitCompletion': totalHabitCompletion / count,
      'moodScore': totalMoodScore / count / 5.0, // Normalize to 0-1
      'overallScore': totalOverallScore / count,
    };
  }

  // Get streak information
  Future<Map<String, int>> getStreakInfo(String userId) async {
    final analytics = await getLastNDaysAnalytics(userId, 365);
    
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    // Calculate current streak (from today backwards)
    final today = DateTime.now();
    for (int i = 0; i < analytics.length; i++) {
      final dayAnalytics = analytics.firstWhere(
        (a) => a.date.day == today.subtract(Duration(days: i)).day,
        orElse: () => DailyAnalytics(
          id: '',
          userId: userId,
          date: today.subtract(Duration(days: i)),
          tasksCompleted: 0,
          tasksTotal: 0,
          habitsCompleted: 0,
          habitsTotal: 0,
          mindGymMinutes: 0,
          averageMoodScore: 0,
          incomeProgress: 0,
          streakDays: 0,
          createdAt: DateTime.now(),
        ),
      );
      
      if (dayAnalytics.overallScore >= 0.7) {
        currentStreak++;
      } else {
        break;
      }
    }
    
    // Calculate longest streak
    for (final dayAnalytics in analytics) {
      if (dayAnalytics.overallScore >= 0.7) {
        tempStreak++;
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      } else {
        tempStreak = 0;
      }
    }
    
    return {
      'current': currentStreak,
      'longest': longestStreak,
    };
  }

  // Get productivity trends
  Future<Map<String, List<double>>> getProductivityTrends(String userId, int days) async {
    final analytics = await getLastNDaysAnalytics(userId, days);
    
    return {
      'taskCompletion': analytics.map((a) => a.taskCompletionRate).toList(),
      'habitCompletion': analytics.map((a) => a.habitCompletionRate).toList(),
      'moodScore': analytics.map((a) => a.averageMoodScore / 5.0).toList(),
      'overallScore': analytics.map((a) => a.overallScore).toList(),
    };
  }

  // Generate weekly report
  Future<WeeklyReport> generateWeeklyReport(String userId, DateTime weekStart) async {
    final weekEnd = weekStart.add(Duration(days: 6));
    final dailyData = await getWeeklyAnalytics(userId, weekStart);
    
    final averageScores = await getAverageScores(userId, weekStart, weekEnd);
    final streakInfo = await getStreakInfo(userId);
    
    final totalMindGymMinutes = dailyData.fold<int>(0, (sum, a) => sum + a.mindGymMinutes);
    
    // Generate achievements and improvements (simplified)
    final achievements = <String>[];
    final improvements = <String>[];
    
    if (averageScores['taskCompletion']! > 0.8) {
      achievements.add('Excellent task completion rate!');
    }
    if (averageScores['habitCompletion']! > 0.8) {
      achievements.add('Consistent habit tracking!');
    }
    if (streakInfo['current']! > 7) {
      achievements.add('Week-long productivity streak!');
    }
    
    if (averageScores['taskCompletion']! < 0.5) {
      improvements.add('Focus on completing more daily tasks');
    }
    if (averageScores['moodScore']! < 0.6) {
      improvements.add('Consider mood-boosting activities');
    }
    
    return WeeklyReport(
      id: 'weekly_${userId}_${weekStart.toIso8601String().split('T')[0]}',
      userId: userId,
      weekStart: weekStart,
      weekEnd: weekEnd,
      dailyData: dailyData,
      averageTaskCompletion: averageScores['taskCompletion']!,
      averageHabitCompletion: averageScores['habitCompletion']!,
      averageMoodScore: averageScores['moodScore']! * 5.0, // Convert back to 1-5 scale
      totalMindGymMinutes: totalMindGymMinutes,
      longestStreak: streakInfo['longest']!,
      achievements: achievements,
      improvements: improvements,
      createdAt: DateTime.now(),
    );
  }
}

