import 'package:flutter/material.dart';
import '../models/analytics.dart';

class WeeklyReportCard extends StatelessWidget {
  final WeeklyAnalytics? weeklyData;

  const WeeklyReportCard({
    Key? key,
    required this.weeklyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (weeklyData == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No weekly data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

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
            // Header
            Row(
              children: [
                Icon(
                  Icons.calendar_view_week,
                  color: Colors.blue,
                  size: 28,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getWeekRange(weeklyData!.weekStartDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPerformanceColor(weeklyData!.overallPerformance),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getPerformanceLabel(weeklyData!.overallPerformance),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Key metrics
            Row(
              children: [
                Expanded(
                  child: _buildWeeklyMetric(
                    'Productivity',
                    '${(weeklyData!.productivityScore * 100).toInt()}%',
                    Icons.trending_up,
                    Colors.blue,
                    weeklyData!.productivityScore,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildWeeklyMetric(
                    'Consistency',
                    '${(weeklyData!.consistencyScore * 100).toInt()}%',
                    Icons.repeat,
                    Colors.green,
                    weeklyData!.consistencyScore,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildWeeklyMetric(
                    'Focus Hours',
                    '${weeklyData!.totalFocusHours.toStringAsFixed(1)}h',
                    Icons.timer,
                    Colors.orange,
                    weeklyData!.totalFocusHours / 40, // Out of 40 hours per week
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildWeeklyMetric(
                    'Mood Average',
                    weeklyData!.averageMood.toStringAsFixed(1),
                    Icons.mood,
                    Colors.purple,
                    weeklyData!.averageMood / 5.0,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Achievements
            if (weeklyData!.achievements.isNotEmpty) ...[
              Text(
                'This Week\'s Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              ...weeklyData!.achievements.map((achievement) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        achievement,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              SizedBox(height: 16),
            ],
            
            // Areas for improvement
            if (weeklyData!.areasForImprovement.isNotEmpty) ...[
              Text(
                'Areas for Improvement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              ...weeklyData!.areasForImprovement.map((area) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        area,
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
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyMetric(String label, String value, IconData icon, Color color, double progress) {
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
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  String _getWeekRange(DateTime weekStart) {
    final weekEnd = weekStart.add(Duration(days: 6));
    final startMonth = _getMonthName(weekStart.month);
    final endMonth = _getMonthName(weekEnd.month);
    
    if (weekStart.month == weekEnd.month) {
      return '$startMonth ${weekStart.day}-${weekEnd.day}';
    } else {
      return '$startMonth ${weekStart.day} - $endMonth ${weekEnd.day}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Color _getPerformanceColor(double performance) {
    if (performance >= 0.8) {
      return Colors.green;
    } else if (performance >= 0.6) {
      return Colors.blue;
    } else if (performance >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getPerformanceLabel(double performance) {
    if (performance >= 0.8) {
      return 'Excellent';
    } else if (performance >= 0.6) {
      return 'Good';
    } else if (performance >= 0.4) {
      return 'Average';
    } else {
      return 'Needs Work';
    }
  }
}

