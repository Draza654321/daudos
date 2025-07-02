import 'package:flutter/foundation.dart';
import '../models/analytics.dart';
import '../models/mood.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/goal.dart';
import '../models/mind_gym.dart';
import '../services/analytics_repository.dart';
import '../services/mood_repository.dart';
import '../services/task_repository.dart';
import '../services/habit_repository.dart';
import '../services/goal_repository.dart';
import '../services/mind_gym_repository.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();
  final MoodRepository _moodRepository = MoodRepository();
  final TaskRepository _taskRepository = TaskRepository();
  final HabitRepository _habitRepository = HabitRepository();
  final GoalRepository _goalRepository = GoalRepository();
  final MindGymRepository _mindGymRepository = MindGymRepository();

  bool _isLoading = false;
  List<DailyAnalytics> _dailySnapshots = [];
  WeeklyAnalytics? _weeklyReport;
  MonthlyAnalytics? _monthlyReport;
  List<MoodTrendData> _moodTrends = [];
  List<ProgressData> _weeklyProgress = [];
  List<String> _moodInsights = [];

  // Mood metrics
  double _averageEnergy = 0.0;
  double _averageFocus = 0.0;
  double _averageClarity = 0.0;

  // Progress metrics
  int _tasksCompleted = 0;
  int _totalTasks = 0;
  int _habitsCompleted = 0;
  int _totalHabits = 0;
  int _goalsCompleted = 0;
  int _totalGoals = 0;
  int _mindGymSessions = 0;
  int _targetSessions = 30; // Monthly target

  // Income tracking
  double _monthlyIncomeGoal = 5000.0; // Default goal
  double _currentIncome = 0.0;

  // Getters
  bool get isLoading => _isLoading;
  List<DailyAnalytics> get dailySnapshots => _dailySnapshots;
  WeeklyAnalytics? get weeklyReport => _weeklyReport;
  MonthlyAnalytics? get monthlyReport => _monthlyReport;
  List<MoodTrendData> get moodTrends => _moodTrends;
  List<ProgressData> get weeklyProgress => _weeklyProgress;
  List<String> get moodInsights => _moodInsights;

  double get averageEnergy => _averageEnergy;
  double get averageFocus => _averageFocus;
  double get averageClarity => _averageClarity;

  int get tasksCompleted => _tasksCompleted;
  int get totalTasks => _totalTasks;
  int get habitsCompleted => _habitsCompleted;
  int get totalHabits => _totalHabits;
  int get goalsCompleted => _goalsCompleted;
  int get totalGoals => _totalGoals;
  int get mindGymSessions => _mindGymSessions;
  int get targetSessions => _targetSessions;

  double get monthlyIncomeGoal => _monthlyIncomeGoal;
  double get currentIncome => _currentIncome;
  double get incomeProgress => _monthlyIncomeGoal > 0 ? (_currentIncome / _monthlyIncomeGoal).clamp(0.0, 1.0) : 0.0;

  // Initialize analytics
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadMoodAnalytics(),
        _loadProgressAnalytics(),
        _loadDailySnapshots(),
        _loadReports(),
        _loadIncomeData(),
      ]);

      _generateInsights();
    } catch (e) {
      print('Error initializing analytics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load mood analytics
  Future<void> _loadMoodAnalytics() async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(Duration(days: 30));
      
      final moods = await _moodRepository.getMoodsBetweenDates(
        'user_daud',
        thirtyDaysAgo,
        now,
      );

      if (moods.isNotEmpty) {
        _averageEnergy = moods.map((m) => m.energy).reduce((a, b) => a + b) / moods.length;
        _averageFocus = moods.map((m) => m.focus).reduce((a, b) => a + b) / moods.length;
        _averageClarity = moods.map((m) => m.clarity).reduce((a, b) => a + b) / moods.length;

        // Generate mood trends
        _moodTrends = _generateMoodTrends(moods);
      }
    } catch (e) {
      print('Error loading mood analytics: $e');
    }
  }

  // Load progress analytics
  Future<void> _loadProgressAnalytics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Load tasks
      final tasks = await _taskRepository.getTasksBetweenDates(
        'user_daud',
        startOfMonth,
        now,
      );
      _totalTasks = tasks.length;
      _tasksCompleted = tasks.where((t) => t.isCompleted).length;

      // Load habits
      final habits = await _habitRepository.getHabitsForUser('user_daud');
      _totalHabits = habits.length;
      _habitsCompleted = habits.where((h) => h.currentStreak > 0).length;

      // Load goals
      final goals = await _goalRepository.getGoalsForUser('user_daud');
      _totalGoals = goals.length;
      _goalsCompleted = goals.where((g) => g.status == GoalStatus.completed).length;

      // Load mind gym sessions
      final sessions = await _mindGymRepository.getSessionsBetweenDates(
        'user_daud',
        startOfMonth,
        now,
      );
      _mindGymSessions = sessions.length;

      // Generate weekly progress
      _weeklyProgress = _generateWeeklyProgress();
    } catch (e) {
      print('Error loading progress analytics: $e');
    }
  }

  // Load daily snapshots
  Future<void> _loadDailySnapshots() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(Duration(days: 7));
      
      _dailySnapshots = await _analyticsRepository.getDailyAnalyticsBetweenDates(
        'user_daud',
        sevenDaysAgo,
        now,
      );
    } catch (e) {
      print('Error loading daily snapshots: $e');
    }
  }

  // Load reports
  Future<void> _loadReports() async {
    try {
      final now = DateTime.now();
      
      _weeklyReport = await _analyticsRepository.getWeeklyAnalytics(
        'user_daud',
        now,
      );
      
      _monthlyReport = await _analyticsRepository.getMonthlyAnalytics(
        'user_daud',
        now,
      );
    } catch (e) {
      print('Error loading reports: $e');
    }
  }

  // Load income data
  Future<void> _loadIncomeData() async {
    try {
      // This would typically load from user settings or income tracking
      _monthlyIncomeGoal = 5000.0; // Default goal
      _currentIncome = 3250.0; // Example current income
    } catch (e) {
      print('Error loading income data: $e');
    }
  }

  // Generate mood trends
  List<MoodTrendData> _generateMoodTrends(List<Mood> moods) {
    final trends = <MoodTrendData>[];
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayMoods = moods.where((m) => 
        m.timestamp.year == date.year &&
        m.timestamp.month == date.month &&
        m.timestamp.day == date.day
      ).toList();
      
      if (dayMoods.isNotEmpty) {
        final avgEnergy = dayMoods.map((m) => m.energy).reduce((a, b) => a + b) / dayMoods.length;
        final avgFocus = dayMoods.map((m) => m.focus).reduce((a, b) => a + b) / dayMoods.length;
        final avgClarity = dayMoods.map((m) => m.clarity).reduce((a, b) => a + b) / dayMoods.length;
        
        trends.add(MoodTrendData(
          date: date,
          energy: avgEnergy,
          focus: avgFocus,
          clarity: avgClarity,
        ));
      }
    }
    
    return trends;
  }

  // Generate weekly progress
  List<ProgressData> _generateWeeklyProgress() {
    final progress = <ProgressData>[];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      
      // Calculate completion percentage for the day
      final totalItems = 10; // Example: daily tasks + habits
      final completedItems = (totalItems * 0.7).round(); // Example completion rate
      
      progress.add(ProgressData(
        label: dayName,
        value: completedItems / totalItems,
        date: date,
      ));
    }
    
    return progress;
  }

  // Generate insights
  void _generateInsights() {
    _moodInsights.clear();
    
    // Energy insights
    if (_averageEnergy < 2.5) {
      _moodInsights.add('Your energy levels have been low. Consider more rest and mind gym sessions.');
    } else if (_averageEnergy > 4.0) {
      _moodInsights.add('Great energy levels! You\'re maintaining excellent momentum.');
    }
    
    // Focus insights
    if (_averageFocus < 2.5) {
      _moodInsights.add('Focus could be improved. Try breaking tasks into smaller chunks.');
    } else if (_averageFocus > 4.0) {
      _moodInsights.add('Excellent focus! Your concentration skills are strong.');
    }
    
    // Clarity insights
    if (_averageClarity < 2.5) {
      _moodInsights.add('Consider more planning sessions to improve mental clarity.');
    }
    
    // Progress insights
    final taskCompletionRate = _totalTasks > 0 ? (_tasksCompleted / _totalTasks) : 0.0;
    if (taskCompletionRate > 0.8) {
      _moodInsights.add('Outstanding task completion rate! You\'re crushing your goals.');
    } else if (taskCompletionRate < 0.5) {
      _moodInsights.add('Task completion could be improved. Consider adjusting your daily targets.');
    }
    
    // Habit insights
    final habitConsistency = _totalHabits > 0 ? (_habitsCompleted / _totalHabits) : 0.0;
    if (habitConsistency > 0.8) {
      _moodInsights.add('Excellent habit consistency! Your discipline is paying off.');
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await initialize();
  }

  // Export data
  Future<void> exportData() async {
    try {
      // Implementation for exporting analytics data
      print('Exporting analytics data...');
    } catch (e) {
      print('Error exporting data: $e');
    }
  }

  // Share report
  Future<void> shareReport() async {
    try {
      // Implementation for sharing analytics report
      print('Sharing analytics report...');
    } catch (e) {
      print('Error sharing report: $e');
    }
  }

  // Update income goal
  Future<void> updateIncomeGoal(double newGoal) async {
    _monthlyIncomeGoal = newGoal;
    notifyListeners();
    
    try {
      // Save to database
      print('Updated income goal to \$${newGoal.toStringAsFixed(0)}');
    } catch (e) {
      print('Error updating income goal: $e');
    }
  }

  // Update current income
  Future<void> updateCurrentIncome(double income) async {
    _currentIncome = income;
    notifyListeners();
    
    try {
      // Save to database
      print('Updated current income to \$${income.toStringAsFixed(0)}');
    } catch (e) {
      print('Error updating current income: $e');
    }
  }

  // Helper method to get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}

// Data classes for charts
class MoodTrendData {
  final DateTime date;
  final double energy;
  final double focus;
  final double clarity;

  MoodTrendData({
    required this.date,
    required this.energy,
    required this.focus,
    required this.clarity,
  });
}

class ProgressData {
  final String label;
  final double value;
  final DateTime date;

  ProgressData({
    required this.label,
    required this.value,
    required this.date,
  });
}

