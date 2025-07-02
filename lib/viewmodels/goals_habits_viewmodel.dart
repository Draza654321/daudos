import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../services/goal_repository.dart';
import '../services/habit_repository.dart';
import '../services/user_repository.dart';

class GoalsHabitsViewModel extends ChangeNotifier {
  final GoalRepository _goalRepository = GoalRepository();
  final HabitRepository _habitRepository = HabitRepository();
  final UserRepository _userRepository = UserRepository();

  List<Goal> _goals = [];
  List<Habit> _habits = [];
  bool _isLoading = false;
  HabitType _selectedHabitType = HabitType.power;

  // Getters
  List<Goal> get goals => _goals;
  List<Habit> get habits => _habits;
  List<Habit> get filteredHabits => _habits.where((habit) => habit.type == _selectedHabitType).toList();
  bool get isLoading => _isLoading;
  HabitType get selectedHabitType => _selectedHabitType;

  // Computed properties
  int get activeGoalsCount => _goals.where((goal) => goal.status == GoalStatus.active).length;
  int get completedGoalsCount => _goals.where((goal) => goal.status == GoalStatus.completed).length;
  int get activeStreaks => _habits.where((habit) => habit.currentStreak > 0).length;
  int get longestStreak => _habits.isNotEmpty 
      ? _habits.map((habit) => habit.longestStreak).reduce((a, b) => a > b ? a : b)
      : 0;

  // Initialize data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadGoals(user.id);
        await _loadHabits(user.id);
      }
    } catch (e) {
      print('Error initializing goals and habits data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load goals
  Future<void> _loadGoals(String userId) async {
    _goals = await _goalRepository.getGoalsForUser(userId);
  }

  // Load habits
  Future<void> _loadHabits(String userId) async {
    _habits = await _habitRepository.getHabitsForUser(userId);
  }

  // Set selected habit type
  void setSelectedHabitType(HabitType type) {
    _selectedHabitType = type;
    notifyListeners();
  }

  // Goal methods
  Future<void> createGoal({
    required String title,
    String? description,
    required double targetValue,
    required String unit,
    required DateTime deadline,
    required String category,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) return;

      final now = DateTime.now();
      final newGoal = Goal(
        id: 'goal_${user.id}_${now.millisecondsSinceEpoch}',
        userId: user.id,
        title: title,
        description: description,
        targetValue: targetValue,
        currentValue: 0.0,
        unit: unit,
        deadline: deadline,
        category: category,
        status: GoalStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      await _goalRepository.createGoal(newGoal);
      await _loadGoals(user.id);
    } catch (e) {
      print('Error creating goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGoal(Goal goal) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedGoal = goal.copyWith(updatedAt: DateTime.now());
      await _goalRepository.updateGoal(updatedGoal);
      
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadGoals(user.id);
      }
    } catch (e) {
      print('Error updating goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGoalProgress(String goalId, double progress) async {
    try {
      final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final updatedGoal = goal.copyWith(
          currentValue: progress,
          updatedAt: DateTime.now(),
          status: progress >= goal.targetValue ? GoalStatus.completed : GoalStatus.active,
        );
        
        await _goalRepository.updateGoal(updatedGoal);
        _goals[goalIndex] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating goal progress: $e');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _goalRepository.deleteGoal(goalId);
      
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadGoals(user.id);
      }
    } catch (e) {
      print('Error deleting goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Habit methods
  Future<void> createHabit({
    required String title,
    String? description,
    required HabitType type,
    required HabitFrequency frequency,
    TimeOfDay? reminderTime,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) return;

      final now = DateTime.now();
      final newHabit = Habit(
        id: 'habit_${user.id}_${now.millisecondsSinceEpoch}',
        userId: user.id,
        title: title,
        description: description,
        type: type,
        frequency: frequency,
        reminderTime: reminderTime,
        currentStreak: 0,
        longestStreak: 0,
        totalCompletions: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await _habitRepository.createHabit(newHabit);
      await _loadHabits(user.id);
    } catch (e) {
      print('Error creating habit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedHabit = habit.copyWith(updatedAt: DateTime.now());
      await _habitRepository.updateHabit(updatedHabit);
      
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadHabits(user.id);
      }
    } catch (e) {
      print('Error updating habit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleHabitCompletion(String habitId) async {
    try {
      final today = DateTime.now();
      await _habitRepository.toggleHabitCompletion(habitId, today);
      
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadHabits(user.id);
      }
    } catch (e) {
      print('Error toggling habit completion: $e');
    }
  }

  Future<void> toggleHabitCompletionForDate(String habitId, DateTime date) async {
    try {
      await _habitRepository.toggleHabitCompletion(habitId, date);
      
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadHabits(user.id);
      }
    } catch (e) {
      print('Error toggling habit completion for date: $e');
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _habitRepository.deleteHabit(habitId);
      
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadHabits(user.id);
      }
    } catch (e) {
      print('Error deleting habit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Analytics methods
  Map<String, dynamic> getGoalAnalytics() {
    final totalGoals = _goals.length;
    final completedGoals = _goals.where((goal) => goal.status == GoalStatus.completed).length;
    final activeGoals = _goals.where((goal) => goal.status == GoalStatus.active).length;
    final overdueGoals = _goals.where((goal) => 
      goal.status == GoalStatus.active && 
      goal.deadline.isBefore(DateTime.now())
    ).length;

    return {
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'activeGoals': activeGoals,
      'overdueGoals': overdueGoals,
      'completionRate': totalGoals > 0 ? completedGoals / totalGoals : 0.0,
    };
  }

  Map<String, dynamic> getHabitAnalytics() {
    final totalHabits = _habits.length;
    final activeHabits = _habits.where((habit) => habit.isActive).length;
    final powerHabits = _habits.where((habit) => habit.type == HabitType.power).length;
    final struggleHabits = _habits.where((habit) => habit.type == HabitType.struggle).length;
    final totalCompletions = _habits.fold<int>(0, (sum, habit) => sum + habit.totalCompletions);

    return {
      'totalHabits': totalHabits,
      'activeHabits': activeHabits,
      'powerHabits': powerHabits,
      'struggleHabits': struggleHabits,
      'totalCompletions': totalCompletions,
      'averageStreak': totalHabits > 0 
          ? _habits.fold<int>(0, (sum, habit) => sum + habit.currentStreak) / totalHabits
          : 0.0,
    };
  }

  // Get habit completion for specific date
  bool isHabitCompletedOnDate(String habitId, DateTime date) {
    // This would typically check the habit completion records
    // For now, return false as placeholder
    return false;
  }

  // Get habit completion streak data
  List<bool> getHabitStreakData(String habitId, int days) {
    // This would return the last N days of completion data
    // For now, return placeholder data
    return List.generate(days, (index) => index % 3 == 0);
  }

  // Refresh data
  Future<void> refresh() async {
    await initialize();
  }
}

