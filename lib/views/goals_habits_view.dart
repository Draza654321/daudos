import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/goals_habits_viewmodel.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../widgets/goal_card.dart';
import '../widgets/habit_card.dart';
import '../widgets/add_goal_dialog.dart';
import '../widgets/add_habit_dialog.dart';
import '../widgets/streak_visualization.dart';

class GoalsHabitsView extends StatefulWidget {
  @override
  _GoalsHabitsViewState createState() => _GoalsHabitsViewState();
}

class _GoalsHabitsViewState extends State<GoalsHabitsView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalsHabitsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Goals & Habits'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.analytics),
                onPressed: () {
                  _showAnalytics(context, viewModel);
                },
                tooltip: 'View Analytics',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Goals', icon: Icon(Icons.flag)),
                Tab(text: 'Habits', icon: Icon(Icons.repeat)),
                Tab(text: 'Streaks', icon: Icon(Icons.local_fire_department)),
              ],
            ),
          ),
          body: viewModel.isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Goals Tab
                    _buildGoalsTab(viewModel),
                    
                    // Habits Tab
                    _buildHabitsTab(viewModel),
                    
                    // Streaks Tab
                    _buildStreaksTab(viewModel),
                  ],
                ),
          floatingActionButton: _buildFloatingActionButton(viewModel),
        );
      },
    );
  }

  Widget _buildGoalsTab(GoalsHabitsViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: viewModel.goals.isEmpty
          ? _buildEmptyState(
              'No goals yet',
              'Set your first goal to start your journey',
              Icons.flag_outlined,
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: viewModel.goals.length,
              itemBuilder: (context, index) {
                final goal = viewModel.goals[index];
                return GoalCard(
                  goal: goal,
                  onTap: () => _showGoalDetails(context, goal, viewModel),
                  onEdit: () => _showEditGoalDialog(context, goal, viewModel),
                  onDelete: () => _showDeleteGoalConfirmation(context, goal, viewModel),
                  onUpdateProgress: (progress) => viewModel.updateGoalProgress(goal.id, progress),
                );
              },
            ),
    );
  }

  Widget _buildHabitsTab(GoalsHabitsViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: Column(
        children: [
          // Habit Type Selector
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildHabitTypeChip(
                    'Power Habits',
                    HabitType.power,
                    viewModel.selectedHabitType == HabitType.power,
                    () => viewModel.setSelectedHabitType(HabitType.power),
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildHabitTypeChip(
                    'Struggle Habits',
                    HabitType.struggle,
                    viewModel.selectedHabitType == HabitType.struggle,
                    () => viewModel.setSelectedHabitType(HabitType.struggle),
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
          
          // Habits List
          Expanded(
            child: viewModel.filteredHabits.isEmpty
                ? _buildEmptyState(
                    'No ${viewModel.selectedHabitType.toString().split('.').last} habits',
                    'Add your first habit to start building consistency',
                    Icons.repeat_outlined,
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: viewModel.filteredHabits.length,
                    itemBuilder: (context, index) {
                      final habit = viewModel.filteredHabits[index];
                      return HabitCard(
                        habit: habit,
                        onTap: () => _showHabitDetails(context, habit, viewModel),
                        onCheck: () => viewModel.toggleHabitCompletion(habit.id),
                        onEdit: () => _showEditHabitDialog(context, habit, viewModel),
                        onDelete: () => _showDeleteHabitConfirmation(context, habit, viewModel),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksTab(GoalsHabitsViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Streak Stats
            Text(
              'Streak Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStreakStatCard(
                    'Longest Streak',
                    '${viewModel.longestStreak} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStreakStatCard(
                    'Current Streaks',
                    '${viewModel.activeStreaks}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Streak Visualization
            Text(
              'Habit Streaks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            if (viewModel.habits.isEmpty)
              _buildEmptyState(
                'No habits to track',
                'Add habits to see your streaks here',
                Icons.local_fire_department_outlined,
              )
            else
              ...viewModel.habits.map((habit) {
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: StreakVisualization(
                    habit: habit,
                    onDayTap: (date) => viewModel.toggleHabitCompletionForDate(habit.id, date),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitTypeChip(
    String label,
    HabitType type,
    bool isSelected,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(GoalsHabitsViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_tabController.index == 0) // Goals tab
          FloatingActionButton(
            onPressed: () => _showAddGoalDialog(context, viewModel),
            child: Icon(Icons.flag),
            tooltip: 'Add Goal',
          )
        else if (_tabController.index == 1) // Habits tab
          FloatingActionButton(
            onPressed: () => _showAddHabitDialog(context, viewModel),
            child: Icon(Icons.add),
            tooltip: 'Add Habit',
          ),
      ],
    );
  }

  void _showAddGoalDialog(BuildContext context, GoalsHabitsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AddGoalDialog(
        onGoalCreated: (title, description, targetValue, unit, deadline, category) {
          viewModel.createGoal(
            title: title,
            description: description,
            targetValue: targetValue,
            unit: unit,
            deadline: deadline,
            category: category,
          );
        },
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, Goal goal, GoalsHabitsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AddGoalDialog(
        goal: goal,
        onGoalCreated: (title, description, targetValue, unit, deadline, category) {
          final updatedGoal = goal.copyWith(
            title: title,
            description: description,
            targetValue: targetValue,
            unit: unit,
            deadline: deadline,
            category: category,
          );
          viewModel.updateGoal(updatedGoal);
        },
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, GoalsHabitsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AddHabitDialog(
        onHabitCreated: (title, description, type, frequency, reminderTime) {
          viewModel.createHabit(
            title: title,
            description: description,
            type: type,
            frequency: frequency,
            reminderTime: reminderTime,
          );
        },
      ),
    );
  }

  void _showEditHabitDialog(BuildContext context, Habit habit, GoalsHabitsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AddHabitDialog(
        habit: habit,
        onHabitCreated: (title, description, type, frequency, reminderTime) {
          final updatedHabit = habit.copyWith(
            title: title,
            description: description,
            type: type,
            frequency: frequency,
            reminderTime: reminderTime,
          );
          viewModel.updateHabit(updatedHabit);
        },
      ),
    );
  }

  void _showGoalDetails(BuildContext context, Goal goal, GoalsHabitsViewModel viewModel) {
    // TODO: Implement goal details modal
  }

  void _showHabitDetails(BuildContext context, Habit habit, GoalsHabitsViewModel viewModel) {
    // TODO: Implement habit details modal
  }

  void _showDeleteGoalConfirmation(BuildContext context, Goal goal, GoalsHabitsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteGoal(goal.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteHabitConfirmation(BuildContext context, Habit habit, GoalsHabitsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteHabit(habit.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAnalytics(BuildContext context, GoalsHabitsViewModel viewModel) {
    // TODO: Implement analytics modal
  }
}

