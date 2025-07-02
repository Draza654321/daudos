import 'package:flutter/material.dart';
import '../models/habit.dart';

class StreakVisualization extends StatelessWidget {
  final Habit habit;
  final Function(DateTime)? onDayTap;
  final int daysToShow;

  const StreakVisualization({
    Key? key,
    required this.habit,
    this.onDayTap,
    this.daysToShow = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getHabitTypeColor(),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  habit.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${habit.currentStreak}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Calendar Grid
          _buildCalendarGrid(context),
          
          SizedBox(height: 12),
          
          // Legend
          Row(
            children: [
              _buildLegendItem('Completed', _getCompletedColor()),
              SizedBox(width: 16),
              _buildLegendItem('Missed', Colors.grey[300]!),
              SizedBox(width: 16),
              _buildLegendItem('Today', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: daysToShow - 1));
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: daysToShow,
      itemBuilder: (context, index) {
        final date = startDate.add(Duration(days: index));
        final isToday = _isSameDay(date, today);
        final isCompleted = _isHabitCompletedOnDate(date);
        final isFuture = date.isAfter(today);
        
        return GestureDetector(
          onTap: isFuture ? null : () => onDayTap?.call(date),
          child: Container(
            decoration: BoxDecoration(
              color: _getDayColor(isCompleted, isToday, isFuture),
              borderRadius: BorderRadius.circular(6),
              border: isToday 
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getTextColor(isCompleted, isToday, isFuture),
                    ),
                  ),
                  if (isCompleted && !isFuture) ...[
                    SizedBox(height: 2),
                    Icon(
                      habit.type == HabitType.power ? Icons.check : Icons.close,
                      size: 8,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getHabitTypeColor() {
    switch (habit.type) {
      case HabitType.power:
        return Colors.green;
      case HabitType.struggle:
        return Colors.red;
    }
  }

  Color _getCompletedColor() {
    switch (habit.type) {
      case HabitType.power:
        return Colors.green;
      case HabitType.struggle:
        return Colors.blue; // Blue for successfully avoiding struggle habits
    }
  }

  Color _getDayColor(bool isCompleted, bool isToday, bool isFuture) {
    if (isFuture) {
      return Colors.grey[100]!;
    }
    
    if (isCompleted) {
      return _getCompletedColor();
    }
    
    if (isToday) {
      return Colors.blue.withOpacity(0.1);
    }
    
    return Colors.grey[300]!;
  }

  Color _getTextColor(bool isCompleted, bool isToday, bool isFuture) {
    if (isFuture) {
      return Colors.grey[400]!;
    }
    
    if (isCompleted) {
      return Colors.white;
    }
    
    if (isToday) {
      return Colors.blue;
    }
    
    return Colors.grey[600]!;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isHabitCompletedOnDate(DateTime date) {
    // This would typically check the habit completion records
    // For now, return a pattern for demonstration
    final daysSinceEpoch = date.difference(DateTime(2024, 1, 1)).inDays;
    
    // Create a realistic pattern with some missed days
    if (habit.type == HabitType.power) {
      // Power habits: completed most days with occasional misses
      return daysSinceEpoch % 7 != 0 && daysSinceEpoch % 11 != 0;
    } else {
      // Struggle habits: successfully avoided on most days
      return daysSinceEpoch % 5 != 0 && daysSinceEpoch % 13 != 0;
    }
  }
}

