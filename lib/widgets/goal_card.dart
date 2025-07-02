import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(double)? onUpdateProgress;

  const GoalCard({
    Key? key,
    required this.goal,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onUpdateProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = goal.targetValue > 0 ? (goal.currentValue / goal.targetValue).clamp(0.0, 1.0) : 0.0;
    final isCompleted = goal.status == GoalStatus.completed;
    final isOverdue = goal.status == GoalStatus.active && goal.deadline.isBefore(DateTime.now());
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Colors.green.withOpacity(0.1)
                  : isOverdue 
                      ? Colors.red.withOpacity(0.1)
                      : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted 
                    ? Colors.green.withOpacity(0.3)
                    : isOverdue 
                        ? Colors.red.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Goal Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        color: _getCategoryColor(),
                        size: 24,
                      ),
                    ),
                    
                    SizedBox(width: 16),
                    
                    // Goal Title and Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? Colors.grey[600] : null,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              goal.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getCategoryColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
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
                if (goal.description != null && goal.description!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    goal.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                SizedBox(height: 20),
                
                // Progress Section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          
                          // Progress Bar
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 8),
                          
                          // Progress Values
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${goal.currentValue.toStringAsFixed(goal.currentValue.truncateToDouble() == goal.currentValue ? 0 : 1)} ${goal.unit}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Target: ${goal.targetValue.toStringAsFixed(goal.targetValue.truncateToDouble() == goal.targetValue ? 0 : 1)} ${goal.unit}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Footer Row
                Row(
                  children: [
                    // Deadline
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      _getFormattedDeadline(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.grey[600],
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    
                    Spacer(),
                    
                    // Quick Progress Update (if not completed)
                    if (!isCompleted && onUpdateProgress != null) ...[
                      GestureDetector(
                        onTap: () => _showProgressUpdateDialog(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
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

  Color _getCategoryColor() {
    // Simple color mapping based on category
    switch (goal.category.toLowerCase()) {
      case 'health':
        return Colors.green;
      case 'finance':
        return Colors.blue;
      case 'career':
        return Colors.purple;
      case 'learning':
        return Colors.orange;
      case 'personal':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }

  IconData _getCategoryIcon() {
    switch (goal.category.toLowerCase()) {
      case 'health':
        return Icons.favorite;
      case 'finance':
        return Icons.attach_money;
      case 'career':
        return Icons.work;
      case 'learning':
        return Icons.school;
      case 'personal':
        return Icons.person;
      default:
        return Icons.flag;
    }
  }

  Color _getStatusColor() {
    switch (goal.status) {
      case GoalStatus.active:
        return goal.deadline.isBefore(DateTime.now()) ? Colors.red : Colors.blue;
      case GoalStatus.completed:
        return Colors.green;
      case GoalStatus.paused:
        return Colors.orange;
    }
  }

  String _getStatusText() {
    switch (goal.status) {
      case GoalStatus.active:
        return goal.deadline.isBefore(DateTime.now()) ? 'Overdue' : 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.paused:
        return 'Paused';
    }
  }

  String _getFormattedDeadline() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final goalDate = DateTime(goal.deadline.year, goal.deadline.month, goal.deadline.day);
    
    if (goalDate == today) {
      return 'Due today';
    } else if (goalDate == tomorrow) {
      return 'Due tomorrow';
    } else if (goalDate.isBefore(today)) {
      final difference = today.difference(goalDate).inDays;
      return '${difference}d overdue';
    } else {
      final difference = goalDate.difference(today).inDays;
      if (difference <= 7) {
        return 'Due in ${difference}d';
      } else {
        return 'Due ${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}';
      }
    }
  }

  void _showProgressUpdateDialog(BuildContext context) {
    final controller = TextEditingController(text: goal.currentValue.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: ${goal.currentValue} ${goal.unit}'),
            Text('Target: ${goal.targetValue} ${goal.unit}'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New Progress',
                suffixText: goal.unit,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null) {
                onUpdateProgress?.call(newValue);
                Navigator.pop(context);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

