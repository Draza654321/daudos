import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onCheck;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCard({
    Key? key,
    required this.habit,
    this.onTap,
    this.onCheck,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompletedToday = _isCompletedToday();
    final streakColor = habit.currentStreak > 0 ? Colors.orange : Colors.grey;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompletedToday 
                  ? (habit.type == HabitType.power ? Colors.green : Colors.blue).withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompletedToday 
                    ? (habit.type == HabitType.power ? Colors.green : Colors.blue).withOpacity(0.3)
                    : _getHabitTypeColor().withOpacity(0.3),
                width: 1,
              ),
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
                // Header Row
                Row(
                  children: [
                    // Completion Checkbox
                    GestureDetector(
                      onTap: onCheck,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompletedToday
                              ? (habit.type == HabitType.power ? Colors.green : Colors.blue)
                              : Colors.transparent,
                          border: Border.all(
                            color: isCompletedToday
                                ? (habit.type == HabitType.power ? Colors.green : Colors.blue)
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isCompletedToday
                            ? Icon(
                                habit.type == HabitType.power ? Icons.check : Icons.close,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // Habit Title and Type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: isCompletedToday ? TextDecoration.lineThrough : null,
                              color: isCompletedToday ? Colors.grey[600] : null,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getHabitTypeColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getHabitTypeText(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _getHabitTypeColor(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getFrequencyText(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Streak Display
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: streakColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: streakColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: streakColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // More Options
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(Icons.more_vert, color: Colors.grey[600]),
                    ),
                  ],
                ),
                
                // Description
                if (habit.description != null && habit.description!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    habit.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                SizedBox(height: 12),
                
                // Stats Row
                Row(
                  children: [
                    // Current Streak
                    _buildStatItem(
                      'Current',
                      '${habit.currentStreak}d',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    
                    SizedBox(width: 16),
                    
                    // Longest Streak
                    _buildStatItem(
                      'Best',
                      '${habit.longestStreak}d',
                      Icons.emoji_events,
                      Colors.amber,
                    ),
                    
                    SizedBox(width: 16),
                    
                    // Total Completions
                    _buildStatItem(
                      'Total',
                      '${habit.totalCompletions}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    
                    Spacer(),
                    
                    // Reminder Time
                    if (habit.reminderTime != null) ...[
                      Icon(
                        Icons.notifications,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        _formatTime(habit.reminderTime!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
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

  String _getHabitTypeText() {
    switch (habit.type) {
      case HabitType.power:
        return 'Power';
      case HabitType.struggle:
        return 'Struggle';
    }
  }

  String _getFrequencyText() {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
    }
  }

  bool _isCompletedToday() {
    // This would typically check if the habit was completed today
    // For now, return false as placeholder
    return false;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

