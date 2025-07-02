import 'package:flutter/material.dart';
import '../models/analytics.dart';

class MonthlyReportCard extends StatelessWidget {
  final MonthlyAnalytics? monthlyData;

  const MonthlyReportCard({
    Key? key,
    required this.monthlyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (monthlyData == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No monthly data available',
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
                  Icons.calendar_month,
                  color: Colors.purple,
                  size: 28,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getMonthYear(monthlyData!.month),
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
                    color: _getGrowthColor(monthlyData!.growthRate),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        monthlyData!.growthRate >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${(monthlyData!.growthRate * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Key metrics grid
            Row(
              children: [
                Expanded(
                  child: _buildMonthlyMetric(
                    'Total Tasks',
                    monthlyData!.totalTasksCompleted.toString(),
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildMonthlyMetric(
                    'Habit Streaks',
                    monthlyData!.longestHabitStreak.toString(),
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMonthlyMetric(
                    'Goals Achieved',
                    monthlyData!.goalsAchieved.toString(),
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildMonthlyMetric(
                    'Focus Hours',
                    '${monthlyData!.totalFocusHours.toStringAsFixed(0)}h',
                    Icons.timer,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Progress indicators
            Text(
              'Monthly Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            _buildProgressIndicator(
              'Productivity',
              monthlyData!.productivityImprovement,
              Colors.blue,
            ),
            SizedBox(height: 12),
            
            _buildProgressIndicator(
              'Consistency',
              monthlyData!.consistencyImprovement,
              Colors.green,
            ),
            SizedBox(height: 12),
            
            _buildProgressIndicator(
              'Well-being',
              monthlyData!.wellBeingImprovement,
              Colors.purple,
            ),
            
            SizedBox(height: 24),
            
            // Major achievements
            if (monthlyData!.majorAchievements.isNotEmpty) ...[
              Text(
                'Major Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              ...monthlyData!.majorAchievements.map((achievement) => Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          achievement,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
              SizedBox(height: 16),
            ],
            
            // Next month goals
            if (monthlyData!.nextMonthGoals.isNotEmpty) ...[
              Text(
                'Next Month\'s Focus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              ...monthlyData!.nextMonthGoals.map((goal) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goal,
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

  Widget _buildMonthlyMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double improvement, Color color) {
    final isPositive = improvement >= 0;
    final percentage = (improvement * 100).abs();
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: (improvement.abs() / 1.0).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              isPositive ? color : Colors.red,
            ),
          ),
        ),
        SizedBox(width: 12),
        Row(
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? color : Colors.red,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isPositive ? color : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getMonthYear(DateTime month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month.month - 1]} ${month.year}';
  }

  Color _getGrowthColor(double growthRate) {
    if (growthRate >= 0.1) {
      return Colors.green;
    } else if (growthRate >= 0) {
      return Colors.blue;
    } else if (growthRate >= -0.1) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

