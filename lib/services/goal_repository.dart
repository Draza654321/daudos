import '../models/goal.dart';
import 'database_service.dart';
import 'firebase_service.dart';

class GoalRepository {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // Create goal
  Future<void> createGoal(Goal goal) async {
    try {
      // Save to local database
      await _databaseService.insertGoal(goal);
      
      // Sync to Firebase if available
      await _firebaseService.syncGoal(goal);
    } catch (e) {
      print('Error creating goal: $e');
      rethrow;
    }
  }

  // Get goals for user
  Future<List<Goal>> getGoalsForUser(String userId) async {
    try {
      return await _databaseService.getGoalsForUser(userId);
    } catch (e) {
      print('Error getting goals for user: $e');
      return [];
    }
  }

  // Get goal by ID
  Future<Goal?> getGoalById(String goalId) async {
    try {
      return await _databaseService.getGoalById(goalId);
    } catch (e) {
      print('Error getting goal by ID: $e');
      return null;
    }
  }

  // Update goal
  Future<void> updateGoal(Goal goal) async {
    try {
      // Update in local database
      await _databaseService.updateGoal(goal);
      
      // Sync to Firebase if available
      await _firebaseService.syncGoal(goal);
    } catch (e) {
      print('Error updating goal: $e');
      rethrow;
    }
  }

  // Delete goal
  Future<void> deleteGoal(String goalId) async {
    try {
      // Delete from local database
      await _databaseService.deleteGoal(goalId);
      
      // Delete from Firebase if available
      await _firebaseService.deleteGoal(goalId);
    } catch (e) {
      print('Error deleting goal: $e');
      rethrow;
    }
  }

  // Get active goals
  Future<List<Goal>> getActiveGoals(String userId) async {
    try {
      final goals = await getGoalsForUser(userId);
      return goals.where((goal) => goal.status == GoalStatus.active).toList();
    } catch (e) {
      print('Error getting active goals: $e');
      return [];
    }
  }

  // Get completed goals
  Future<List<Goal>> getCompletedGoals(String userId) async {
    try {
      final goals = await getGoalsForUser(userId);
      return goals.where((goal) => goal.status == GoalStatus.completed).toList();
    } catch (e) {
      print('Error getting completed goals: $e');
      return [];
    }
  }

  // Get overdue goals
  Future<List<Goal>> getOverdueGoals(String userId) async {
    try {
      final goals = await getGoalsForUser(userId);
      final now = DateTime.now();
      return goals.where((goal) => 
        goal.status == GoalStatus.active && 
        goal.deadline.isBefore(now)
      ).toList();
    } catch (e) {
      print('Error getting overdue goals: $e');
      return [];
    }
  }

  // Get goals by category
  Future<List<Goal>> getGoalsByCategory(String userId, String category) async {
    try {
      final goals = await getGoalsForUser(userId);
      return goals.where((goal) => goal.category == category).toList();
    } catch (e) {
      print('Error getting goals by category: $e');
      return [];
    }
  }

  // Update goal progress
  Future<void> updateGoalProgress(String goalId, double progress) async {
    try {
      final goal = await getGoalById(goalId);
      if (goal != null) {
        final updatedGoal = goal.copyWith(
          currentValue: progress,
          updatedAt: DateTime.now(),
          status: progress >= goal.targetValue ? GoalStatus.completed : GoalStatus.active,
        );
        await updateGoal(updatedGoal);
      }
    } catch (e) {
      print('Error updating goal progress: $e');
      rethrow;
    }
  }

  // Get goal completion percentage
  double getGoalCompletionPercentage(Goal goal) {
    if (goal.targetValue <= 0) return 0.0;
    return (goal.currentValue / goal.targetValue).clamp(0.0, 1.0);
  }

  // Check if goal is overdue
  bool isGoalOverdue(Goal goal) {
    return goal.status == GoalStatus.active && goal.deadline.isBefore(DateTime.now());
  }

  // Get days until deadline
  int getDaysUntilDeadline(Goal goal) {
    final now = DateTime.now();
    final difference = goal.deadline.difference(now);
    return difference.inDays;
  }

  // Search goals
  Future<List<Goal>> searchGoals(String userId, String query) async {
    try {
      final goals = await getGoalsForUser(userId);
      final lowercaseQuery = query.toLowerCase();
      return goals.where((goal) =>
        goal.title.toLowerCase().contains(lowercaseQuery) ||
        (goal.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
        goal.category.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      print('Error searching goals: $e');
      return [];
    }
  }

  // Get goal statistics
  Future<Map<String, dynamic>> getGoalStatistics(String userId) async {
    try {
      final goals = await getGoalsForUser(userId);
      final totalGoals = goals.length;
      final completedGoals = goals.where((goal) => goal.status == GoalStatus.completed).length;
      final activeGoals = goals.where((goal) => goal.status == GoalStatus.active).length;
      final overdueGoals = goals.where((goal) => isGoalOverdue(goal)).length;

      return {
        'totalGoals': totalGoals,
        'completedGoals': completedGoals,
        'activeGoals': activeGoals,
        'overdueGoals': overdueGoals,
        'completionRate': totalGoals > 0 ? completedGoals / totalGoals : 0.0,
        'averageProgress': activeGoals > 0 
            ? goals.where((goal) => goal.status == GoalStatus.active)
                   .map((goal) => getGoalCompletionPercentage(goal))
                   .reduce((a, b) => a + b) / activeGoals
            : 0.0,
      };
    } catch (e) {
      print('Error getting goal statistics: $e');
      return {};
    }
  }
}

