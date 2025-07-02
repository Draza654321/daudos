import 'package:flutter/material.dart';

class DailyStatsCard extends StatelessWidget {
  final int tasksCompleted;
  final int totalTasks;
  final int habitsCompleted;
  final int totalHabits;
  final double moodScore;

  const DailyStatsCard({
    Key? key,
    required this.tasksCompleted,
    required this.totalTasks,
    required this.habitsCompleted,
    required this.totalHabits,
    required this.moodScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Today\'s Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Tasks',
                    '$tasksCompleted/$totalTasks',
                    totalTasks > 0 ? tasksCompleted / totalTasks : 0.0,
                    Icons.task_alt,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Habits',
                    '$habitsCompleted/$totalHabits',
                    totalHabits > 0 ? habitsCompleted / totalHabits : 0.0,
                    Icons.track_changes,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Mood',
                    '${moodScore.toStringAsFixed(1)}/5.0',
                    moodScore / 5.0,
                    Icons.mood,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Focus Time',
                    '2h 30m',
                    0.75,
                    Icons.timer,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    double progress,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8),
          
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
          
          SizedBox(height: 4),
          
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

