import 'dart:math';
import '../models/mood.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/analytics.dart';
import 'mood_repository.dart';
import 'task_repository.dart';
import 'habit_repository.dart';
import 'analytics_repository.dart';

class AIRecommendationService {
  static final AIRecommendationService _instance = AIRecommendationService._internal();
  factory AIRecommendationService() => _instance;
  AIRecommendationService._internal();

  final MoodRepository _moodRepository = MoodRepository();
  final TaskRepository _taskRepository = TaskRepository();
  final HabitRepository _habitRepository = HabitRepository();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();

  /// Analyzes user patterns and suggests optimal task difficulty
  Future<TaskDifficulty> suggestTaskDifficulty() async {
    try {
      final currentTime = DateTime.now();
      final timeOfDay = _getTimeOfDay(currentTime);
      final recentMoods = await _moodRepository.getMoodHistory(7); // Last 7 days
      final weeklyAnalytics = await _analyticsRepository.getWeeklyAnalytics(currentTime);

      // Calculate average energy and focus for current time period
      final timeBasedMoods = recentMoods.where((mood) {
        final moodTime = _getTimeOfDay(mood.timestamp);
        return moodTime == timeOfDay;
      }).toList();

      double avgEnergy = 3.0;
      double avgFocus = 3.0;

      if (timeBasedMoods.isNotEmpty) {
        avgEnergy = timeBasedMoods.map((m) => m.energy).reduce((a, b) => a + b) / timeBasedMoods.length;
        avgFocus = timeBasedMoods.map((m) => m.focus).reduce((a, b) => a + b) / timeBasedMoods.length;
      }

      // Factor in weekly performance
      double performanceMultiplier = 1.0;
      if (weeklyAnalytics != null) {
        performanceMultiplier = weeklyAnalytics.productivityScore;
      }

      // Calculate difficulty score
      double difficultyScore = (avgEnergy + avgFocus) / 2 * performanceMultiplier;

      // Adjust for time of day (Daud's U.S. dispatch hours: 6 PM - 6 AM PKT)
      if (_isDispatchHours(currentTime)) {
        // During work hours, suggest moderate to high difficulty
        difficultyScore += 0.5;
      } else {
        // During rest hours, suggest easier tasks
        difficultyScore -= 0.3;
      }

      // Map score to difficulty level
      if (difficultyScore >= 4.0) {
        return TaskDifficulty.high;
      } else if (difficultyScore >= 2.5) {
        return TaskDifficulty.medium;
      } else {
        return TaskDifficulty.low;
      }
    } catch (e) {
      // Default to medium difficulty if analysis fails
      return TaskDifficulty.medium;
    }
  }

  /// Suggests optimal focus session duration based on patterns
  Future<int> suggestFocusSessionDuration() async {
    try {
      final currentTime = DateTime.now();
      final recentMoods = await _moodRepository.getMoodHistory(14); // Last 2 weeks
      final weeklyAnalytics = await _analyticsRepository.getWeeklyAnalytics(currentTime);

      // Calculate average focus level
      double avgFocus = 3.0;
      if (recentMoods.isNotEmpty) {
        avgFocus = recentMoods.map((m) => m.focus).reduce((a, b) => a + b) / recentMoods.length;
      }

      // Base duration on focus level
      int baseDuration = 25; // Default Pomodoro
      
      if (avgFocus >= 4.0) {
        baseDuration = 45; // High focus - longer sessions
      } else if (avgFocus >= 3.0) {
        baseDuration = 25; // Medium focus - standard Pomodoro
      } else {
        baseDuration = 15; // Low focus - shorter sessions
      }

      // Adjust for time of day
      if (_isDispatchHours(currentTime)) {
        // During work hours, can handle longer sessions
        baseDuration = (baseDuration * 1.2).round();
      }

      // Factor in recent performance
      if (weeklyAnalytics != null && weeklyAnalytics.consistencyScore < 0.6) {
        // If consistency is low, suggest shorter sessions to build habit
        baseDuration = (baseDuration * 0.8).round();
      }

      return baseDuration.clamp(10, 60); // Min 10 minutes, max 60 minutes
    } catch (e) {
      return 25; // Default Pomodoro duration
    }
  }

  /// Analyzes patterns and suggests habit adjustments
  Future<List<HabitRecommendation>> suggestHabitAdjustments() async {
    try {
      final habits = await _habitRepository.getAllHabits();
      final recentMoods = await _moodRepository.getMoodHistory(7);
      final recommendations = <HabitRecommendation>[];

      for (final habit in habits) {
        final completionRate = await _calculateHabitCompletionRate(habit.id, 7);
        
        if (completionRate < 0.5) {
          // Low completion rate - suggest easier frequency or reminders
          recommendations.add(HabitRecommendation(
            habitId: habit.id,
            type: HabitRecommendationType.reduceFrequency,
            reason: 'Low completion rate (${(completionRate * 100).toInt()}%). Consider reducing frequency to build consistency.',
            suggestedAction: 'Reduce from ${habit.frequency} to a more manageable schedule.',
          ));
        } else if (completionRate > 0.8 && habit.currentStreak > 14) {
          // High completion rate - suggest increasing challenge
          recommendations.add(HabitRecommendation(
            habitId: habit.id,
            type: HabitRecommendationType.increaseChallenge,
            reason: 'Excellent consistency (${(completionRate * 100).toInt()}%) and ${habit.currentStreak}-day streak!',
            suggestedAction: 'Consider increasing the challenge or adding a related habit.',
          ));
        }

        // Check for habits that might be causing stress
        if (habit.type == HabitType.power && completionRate < 0.3) {
          final avgMoodDuringHabit = _calculateMoodDuringHabitTime(habit, recentMoods);
          if (avgMoodDuringHabit < 2.5) {
            recommendations.add(HabitRecommendation(
              habitId: habit.id,
              type: HabitRecommendationType.adjustTiming,
              reason: 'This habit might be causing stress. Low mood detected during habit time.',
              suggestedAction: 'Try scheduling this habit at a different time when energy is higher.',
            ));
          }
        }
      }

      return recommendations;
    } catch (e) {
      return [];
    }
  }

  /// Suggests optimal task generation based on current context
  Future<List<Task>> suggestTasks() async {
    try {
      final currentTime = DateTime.now();
      final difficulty = await suggestTaskDifficulty();
      final recentMoods = await _moodRepository.getMoodHistory(3);
      final tasks = <Task>[];

      // Get current mood context
      double currentEnergy = 3.0;
      double currentFocus = 3.0;
      if (recentMoods.isNotEmpty) {
        final latestMood = recentMoods.first;
        currentEnergy = latestMood.energy;
        currentFocus = latestMood.focus;
      }

      if (_isDispatchHours(currentTime)) {
        // During work hours - focus on work-related tasks
        tasks.addAll(_generateWorkTasks(difficulty, currentEnergy, currentFocus));
      } else {
        // During rest hours - focus on personal development
        tasks.addAll(_generatePersonalTasks(difficulty, currentEnergy, currentFocus));
      }

      // Add mood-specific tasks
      if (currentEnergy < 2.5) {
        tasks.addAll(_generateLowEnergyTasks());
      } else if (currentEnergy > 4.0) {
        tasks.addAll(_generateHighEnergyTasks(difficulty));
      }

      return tasks.take(5).toList(); // Return top 5 suggestions
    } catch (e) {
      return _getDefaultTasks();
    }
  }

  /// Detects burnout patterns and suggests interventions
  Future<BurnoutAssessment> assessBurnout() async {
    try {
      final recentMoods = await _moodRepository.getMoodHistory(7);
      final weeklyAnalytics = await _analyticsRepository.getWeeklyAnalytics(DateTime.now());

      if (recentMoods.isEmpty) {
        return BurnoutAssessment(
          riskLevel: BurnoutRisk.low,
          confidence: 0.0,
          recommendations: [],
        );
      }

      // Calculate trend indicators
      final avgEnergy = recentMoods.map((m) => m.energy).reduce((a, b) => a + b) / recentMoods.length;
      final avgClarity = recentMoods.map((m) => m.clarity).reduce((a, b) => a + b) / recentMoods.length;
      final avgFocus = recentMoods.map((m) => m.focus).reduce((a, b) => a + b) / recentMoods.length;

      // Check for declining trends
      final recentAvg = recentMoods.take(3).map((m) => (m.energy + m.clarity + m.focus) / 3).reduce((a, b) => a + b) / 3;
      final olderAvg = recentMoods.skip(4).map((m) => (m.energy + m.clarity + m.focus) / 3).reduce((a, b) => a + b) / 3;
      final trendDecline = olderAvg - recentAvg;

      // Calculate burnout score
      double burnoutScore = 0.0;
      
      // Low energy indicator
      if (avgEnergy < 2.5) burnoutScore += 0.3;
      
      // Low clarity indicator
      if (avgClarity < 2.5) burnoutScore += 0.2;
      
      // Declining trend indicator
      if (trendDecline > 0.5) burnoutScore += 0.3;
      
      // Low productivity indicator
      if (weeklyAnalytics != null && weeklyAnalytics.productivityScore < 0.4) {
        burnoutScore += 0.2;
      }

      // Determine risk level
      BurnoutRisk riskLevel;
      if (burnoutScore >= 0.7) {
        riskLevel = BurnoutRisk.high;
      } else if (burnoutScore >= 0.4) {
        riskLevel = BurnoutRisk.medium;
      } else {
        riskLevel = BurnoutRisk.low;
      }

      // Generate recommendations
      final recommendations = _generateBurnoutRecommendations(riskLevel, avgEnergy, avgClarity, avgFocus);

      return BurnoutAssessment(
        riskLevel: riskLevel,
        confidence: burnoutScore,
        recommendations: recommendations,
      );
    } catch (e) {
      return BurnoutAssessment(
        riskLevel: BurnoutRisk.low,
        confidence: 0.0,
        recommendations: [],
      );
    }
  }

  // Helper methods

  TimeOfDay _getTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 6 && hour < 12) return TimeOfDay.morning;
    if (hour >= 12 && hour < 18) return TimeOfDay.afternoon;
    if (hour >= 18 && hour < 24) return TimeOfDay.evening;
    return TimeOfDay.night;
  }

  bool _isDispatchHours(DateTime dateTime) {
    final hour = dateTime.hour;
    // U.S. dispatch hours: 6 PM - 6 AM PKT (18:00 - 06:00)
    return hour >= 18 || hour < 6;
  }

  Future<double> _calculateHabitCompletionRate(String habitId, int days) async {
    try {
      final completions = await _habitRepository.getHabitCompletions(habitId, days);
      return completions.length / days;
    } catch (e) {
      return 0.0;
    }
  }

  double _calculateMoodDuringHabitTime(Habit habit, List<Mood> moods) {
    // Simplified calculation - in real implementation, would match habit schedule
    if (moods.isEmpty) return 3.0;
    return moods.map((m) => (m.energy + m.focus + m.clarity) / 3).reduce((a, b) => a + b) / moods.length;
  }

  List<Task> _generateWorkTasks(TaskDifficulty difficulty, double energy, double focus) {
    final tasks = <Task>[];
    final now = DateTime.now();

    switch (difficulty) {
      case TaskDifficulty.high:
        tasks.add(Task(
          id: 'work_${now.millisecondsSinceEpoch}_1',
          title: 'Complete dispatch performance review',
          description: 'Analyze last week\'s dispatch metrics and identify improvement areas',
          priority: TaskPriority.high,
          category: TaskCategory.work,
          dueDate: now.add(Duration(hours: 2)),
          estimatedMinutes: 45,
          isCompleted: false,
          createdAt: now,
        ));
        break;
      case TaskDifficulty.medium:
        tasks.add(Task(
          id: 'work_${now.millisecondsSinceEpoch}_2',
          title: 'Update dispatch logs and documentation',
          description: 'Ensure all dispatch records are current and accurate',
          priority: TaskPriority.medium,
          category: TaskCategory.work,
          dueDate: now.add(Duration(hours: 4)),
          estimatedMinutes: 30,
          isCompleted: false,
          createdAt: now,
        ));
        break;
      case TaskDifficulty.low:
        tasks.add(Task(
          id: 'work_${now.millisecondsSinceEpoch}_3',
          title: 'Organize workspace and tools',
          description: 'Clean and organize dispatch workspace for better efficiency',
          priority: TaskPriority.low,
          category: TaskCategory.work,
          dueDate: now.add(Duration(hours: 6)),
          estimatedMinutes: 15,
          isCompleted: false,
          createdAt: now,
        ));
        break;
    }

    return tasks;
  }

  List<Task> _generatePersonalTasks(TaskDifficulty difficulty, double energy, double focus) {
    final tasks = <Task>[];
    final now = DateTime.now();

    switch (difficulty) {
      case TaskDifficulty.high:
        tasks.add(Task(
          id: 'personal_${now.millisecondsSinceEpoch}_1',
          title: 'Plan next business venture strategy',
          description: 'Research and outline strategy for expanding entrepreneurial activities',
          priority: TaskPriority.high,
          category: TaskCategory.personal,
          dueDate: now.add(Duration(days: 1)),
          estimatedMinutes: 60,
          isCompleted: false,
          createdAt: now,
        ));
        break;
      case TaskDifficulty.medium:
        tasks.add(Task(
          id: 'personal_${now.millisecondsSinceEpoch}_2',
          title: 'Complete online learning module',
          description: 'Continue skill development with focused learning session',
          priority: TaskPriority.medium,
          category: TaskCategory.learning,
          dueDate: now.add(Duration(hours: 12)),
          estimatedMinutes: 30,
          isCompleted: false,
          createdAt: now,
        ));
        break;
      case TaskDifficulty.low:
        tasks.add(Task(
          id: 'personal_${now.millisecondsSinceEpoch}_3',
          title: 'Read motivational content',
          description: 'Spend time reading inspiring entrepreneurial stories',
          priority: TaskPriority.low,
          category: TaskCategory.personal,
          dueDate: now.add(Duration(hours: 8)),
          estimatedMinutes: 20,
          isCompleted: false,
          createdAt: now,
        ));
        break;
    }

    return tasks;
  }

  List<Task> _generateLowEnergyTasks() {
    final tasks = <Task>[];
    final now = DateTime.now();

    tasks.add(Task(
      id: 'lowenergy_${now.millisecondsSinceEpoch}',
      title: 'Take a mindful break',
      description: 'Do some light stretching or breathing exercises',
      priority: TaskPriority.low,
      category: TaskCategory.health,
      dueDate: now.add(Duration(minutes: 30)),
      estimatedMinutes: 10,
      isCompleted: false,
      createdAt: now,
    ));

    return tasks;
  }

  List<Task> _generateHighEnergyTasks(TaskDifficulty difficulty) {
    final tasks = <Task>[];
    final now = DateTime.now();

    tasks.add(Task(
      id: 'highenergy_${now.millisecondsSinceEpoch}',
      title: 'Tackle challenging project',
      description: 'Use this high energy to make significant progress on important goals',
      priority: TaskPriority.high,
      category: TaskCategory.work,
      dueDate: now.add(Duration(hours: 2)),
      estimatedMinutes: difficulty == TaskDifficulty.high ? 60 : 45,
      isCompleted: false,
      createdAt: now,
    ));

    return tasks;
  }

  List<Task> _getDefaultTasks() {
    final now = DateTime.now();
    return [
      Task(
        id: 'default_${now.millisecondsSinceEpoch}',
        title: 'Plan your day',
        description: 'Take a few minutes to organize your priorities',
        priority: TaskPriority.medium,
        category: TaskCategory.personal,
        dueDate: now.add(Duration(hours: 1)),
        estimatedMinutes: 15,
        isCompleted: false,
        createdAt: now,
      ),
    ];
  }

  List<String> _generateBurnoutRecommendations(BurnoutRisk risk, double energy, double clarity, double focus) {
    final recommendations = <String>[];

    switch (risk) {
      case BurnoutRisk.high:
        recommendations.addAll([
          'Take immediate rest - consider a longer break or reduced workload',
          'Focus on basic self-care: sleep, nutrition, and hydration',
          'Engage in calm mode activities: breathing exercises and meditation',
          'Postpone non-essential tasks and reduce commitments',
          'Consider talking to someone about your stress levels',
        ]);
        break;
      case BurnoutRisk.medium:
        recommendations.addAll([
          'Schedule regular breaks throughout your work sessions',
          'Prioritize sleep and maintain consistent sleep schedule',
          'Incorporate more mind gym activities into your routine',
          'Review and adjust your goals to be more realistic',
          'Take time for activities you enjoy outside of work',
        ]);
        break;
      case BurnoutRisk.low:
        recommendations.addAll([
          'Maintain your current healthy patterns',
          'Continue regular mood check-ins to stay aware',
          'Keep up with your mind gym and self-care routines',
          'Consider gradually increasing challenges if you feel ready',
        ]);
        break;
    }

    // Add specific recommendations based on low scores
    if (energy < 2.5) {
      recommendations.add('Focus on energy-boosting activities: light exercise, fresh air, or energizing music');
    }
    if (clarity < 2.5) {
      recommendations.add('Try clarity-enhancing activities: journaling, meditation, or organizing your space');
    }
    if (focus < 2.5) {
      recommendations.add('Use shorter focus sessions and eliminate distractions');
    }

    return recommendations;
  }
}

// Supporting enums and classes

enum TaskDifficulty { low, medium, high }

enum TimeOfDay { morning, afternoon, evening, night }

enum HabitRecommendationType {
  reduceFrequency,
  increaseChallenge,
  adjustTiming,
  addReminder,
  changeApproach,
}

enum BurnoutRisk { low, medium, high }

class HabitRecommendation {
  final String habitId;
  final HabitRecommendationType type;
  final String reason;
  final String suggestedAction;

  HabitRecommendation({
    required this.habitId,
    required this.type,
    required this.reason,
    required this.suggestedAction,
  });
}

class BurnoutAssessment {
  final BurnoutRisk riskLevel;
  final double confidence;
  final List<String> recommendations;

  BurnoutAssessment({
    required this.riskLevel,
    required this.confidence,
    required this.recommendations,
  });
}

