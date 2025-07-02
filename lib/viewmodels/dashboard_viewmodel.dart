import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/mood.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/analytics.dart';
import '../services/user_repository.dart';
import '../services/mood_repository.dart';
import '../services/task_repository.dart';
import '../services/habit_repository.dart';
import '../services/analytics_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final MoodRepository _moodRepository = MoodRepository();
  final TaskRepository _taskRepository = TaskRepository();
  final HabitRepository _habitRepository = HabitRepository();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();

  User? _currentUser;
  Mood? _todaysMood;
  List<Task> _todaysTasks = [];
  List<Habit> _activeHabits = [];
  DailyAnalytics? _todaysAnalytics;
  String _motivationalQuote = '';
  bool _isLoading = true;

  // Getters
  User? get currentUser => _currentUser;
  Mood? get todaysMood => _todaysMood;
  List<Task> get todaysTasks => _todaysTasks;
  List<Habit> get activeHabits => _activeHabits;
  DailyAnalytics? get todaysAnalytics => _todaysAnalytics;
  String get motivationalQuote => _motivationalQuote;
  bool get isLoading => _isLoading;

  // Computed properties
  double get winMeterProgress {
    if (_todaysAnalytics == null) return 0.0;
    return _todaysAnalytics!.overallScore;
  }

  int get completedTasksCount {
    return _todaysTasks.where((task) => task.isCompleted).length;
  }

  int get totalTasksCount => _todaysTasks.length;

  int get completedHabitsCount {
    if (_todaysAnalytics == null) return 0;
    return _todaysAnalytics!.habitsCompleted;
  }

  int get totalHabitsCount {
    if (_todaysAnalytics == null) return 0;
    return _todaysAnalytics!.habitsTotal;
  }

  double get taskCompletionRate {
    if (totalTasksCount == 0) return 0.0;
    return completedTasksCount / totalTasksCount;
  }

  double get habitCompletionRate {
    if (totalHabitsCount == 0) return 0.0;
    return completedHabitsCount / totalHabitsCount;
  }

  double get averageMoodScore {
    if (_todaysMood == null) return 0.0;
    return _todaysMood!.averageScore;
  }

  String get greetingMessage {
    final hour = DateTime.now().hour;
    final name = _currentUser?.name ?? 'Daud';
    
    if (hour < 6) {
      return 'Night Warrior, $name';
    } else if (hour < 12) {
      return 'Good Morning, $name';
    } else if (hour < 18) {
      return 'Good Afternoon, $name';
    } else {
      return 'Evening Grind, $name';
    }
  }

  // Initialize dashboard data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadCurrentUser();
      await _loadTodaysData();
      await _generateMotivationalQuote();
    } catch (e) {
      print('Error initializing dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load current user
  Future<void> _loadCurrentUser() async {
    _currentUser = await _userRepository.getCurrentUser();
    if (_currentUser == null) {
      // Create default user for Daud
      _currentUser = User(
        id: 'daud_raza_001',
        name: 'Daud Raza',
        workStartTime: '18:00',
        workEndTime: '06:00',
        timezone: 'Asia/Karachi',
        monthlyIncomeGoal: 5000.0, // USD
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userRepository.createUser(_currentUser!);
    }
  }

  // Load today's data
  Future<void> _loadTodaysData() async {
    if (_currentUser == null) return;

    final userId = _currentUser!.id;
    final today = DateTime.now();

    // Load today's mood
    _todaysMood = await _moodRepository.getTodaysMood(userId);

    // Load today's tasks
    _todaysTasks = await _taskRepository.getTodaysTasks(userId);

    // Load active habits
    _activeHabits = await _habitRepository.getActiveHabits(userId);

    // Load or generate today's analytics
    _todaysAnalytics = await _analyticsRepository.getDailyAnalytics(userId, today);
    if (_todaysAnalytics == null) {
      await _generateTodaysAnalytics();
    }
  }

  // Generate today's analytics
  Future<void> _generateTodaysAnalytics() async {
    if (_currentUser == null) return;

    final userId = _currentUser!.id;
    final today = DateTime.now();
    
    final completedTasks = _todaysTasks.where((task) => task.isCompleted).length;
    final totalTasks = _todaysTasks.length;
    
    // Calculate habit completion (simplified for now)
    final completedHabits = 0; // Will be calculated based on habit entries
    final totalHabits = _activeHabits.length;
    
    final avgMoodScore = _todaysMood?.averageScore ?? 0.0;
    
    _todaysAnalytics = DailyAnalytics(
      id: 'analytics_${userId}_${today.toIso8601String().split('T')[0]}',
      userId: userId,
      date: today,
      tasksCompleted: completedTasks,
      tasksTotal: totalTasks,
      habitsCompleted: completedHabits,
      habitsTotal: totalHabits,
      mindGymMinutes: 0, // Will be updated when mind gym is used
      averageMoodScore: avgMoodScore,
      incomeProgress: 0.0, // Will be updated manually
      streakDays: 0, // Will be calculated based on historical data
      createdAt: DateTime.now(),
    );

    await _analyticsRepository.createDailyAnalytics(_todaysAnalytics!);
  }

  // Generate motivational quote based on mood and time
  void _generateMotivationalQuote() {
    final hour = DateTime.now().hour;
    final moodScore = averageMoodScore;
    
    List<String> quotes = [];
    
    // Time-based quotes
    if (hour >= 18 || hour < 6) {
      // Night shift quotes
      quotes.addAll([
        "The night is your battlefield, Daud. Conquer it.",
        "While others sleep, you build your empire.",
        "Night warriors don't need daylight to shine.",
        "Your dedication in darkness creates tomorrow's light.",
        "The grind doesn't stop when the sun goes down.",
      ]);
    } else {
      // Day quotes
      quotes.addAll([
        "Every moment is a chance to level up, Daud.",
        "Your potential is unlimited. Prove it today.",
        "Success is built one focused hour at a time.",
        "You're not just working, you're crafting your future.",
        "Today's effort is tomorrow's breakthrough.",
      ]);
    }
    
    // Mood-based adjustments
    if (moodScore < 2.5) {
      // Low mood - encouraging quotes
      quotes.addAll([
        "Tough times don't last, but tough people do.",
        "Every setback is a setup for a comeback.",
        "Your strength grows in moments of struggle.",
        "This too shall pass. Keep pushing forward.",
      ]);
    } else if (moodScore > 4.0) {
      // High mood - momentum quotes
      quotes.addAll([
        "You're on fire! Keep this energy flowing.",
        "Momentum is your superpower. Use it wisely.",
        "High energy, high results. Let's go!",
        "You're in the zone. Make it count.",
      ]);
    }
    
    quotes.shuffle();
    _motivationalQuote = quotes.first;
  }

  // Refresh dashboard data
  Future<void> refresh() async {
    await initialize();
  }

  // Update mood and refresh analytics
  Future<void> updateMood(Mood mood) async {
    _todaysMood = mood;
    await _generateTodaysAnalytics();
    _generateMotivationalQuote();
    notifyListeners();
  }

  // Complete task and update analytics
  Future<void> completeTask(String taskId) async {
    final taskIndex = _todaysTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      await _taskRepository.completeTask(taskId);
      _todaysTasks[taskIndex] = _todaysTasks[taskIndex].copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
      await _generateTodaysAnalytics();
      notifyListeners();
    }
  }

  // Get time-based greeting color
  Color getGreetingColor() {
    final hour = DateTime.now().hour;
    if (hour >= 18 || hour < 6) {
      return Color(0xFFFF6B35); // Orange for night shift
    } else {
      return Color(0xFF3B82F6); // Blue for day
    }
  }

  // Get win meter color based on progress
  Color getWinMeterColor() {
    final progress = winMeterProgress;
    if (progress < 0.3) {
      return Color(0xFFEF4444); // Red
    } else if (progress < 0.7) {
      return Color(0xFFF59E0B); // Yellow
    } else {
      return Color(0xFF10B981); // Green
    }
  }
}

