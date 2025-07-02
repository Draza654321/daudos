import 'package:flutter/material.dart';
import '../models/analytics.dart';

class DailySnapshotCard extends StatelessWidget {
  final DailyAnalytics snapshot;

  const DailySnapshotCard({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(snapshot.date),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getDayOfWeek(snapshot.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getOverallScoreColor(snapshot.overallScore),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(snapshot.overallScore * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Metrics grid
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'Tasks',
                    '${snapshot.tasksCompleted}/${snapshot.totalTasks}',
                    Icons.check_circle,
                    Colors.blue,
                    snapshot.totalTasks > 0 ? snapshot.tasksCompleted / snapshot.totalTasks : 0.0,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildMetric(
                    'Habits',
                    '${snapshot.habitsCompleted}/${snapshot.totalHabits}',
                    Icons.repeat,
                    Colors.green,
                    snapshot.totalHabits > 0 ? snapshot.habitsCompleted / snapshot.totalHabits : 0.0,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'Focus Time',
                    '${snapshot.focusTimeMinutes}m',
                    Icons.timer,
                    Colors.orange,
                    snapshot.focusTimeMinutes / 480, // Out of 8 hours
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildMetric(
                    'Mood Avg',
                    snapshot.averageMood.toStringAsFixed(1),
                    Icons.mood,
                    Colors.purple,
                    snapshot.averageMood / 5.0,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Highlights section
            if (snapshot.highlights.isNotEmpty) ...[
              Text(
                'Highlights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              ...snapshot.highlights.map((highlight) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        highlight,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
            
            // Reflection section
            if (snapshot.reflection.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Reflection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  snapshot.reflection,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color, double progress) {
    return Column(
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getDayOfWeek(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Color _getOverallScoreColor(double score) {
    if (score >= 0.8) {
      return Colors.green;
    } else if (score >= 0.6) {
      return Colors.blue;
    } else if (score >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

