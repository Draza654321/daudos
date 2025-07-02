import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              color: task.status == TaskStatus.completed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: task.status == TaskStatus.completed
                    ? Colors.green.withOpacity(0.3)
                    : _getPriorityColor().withOpacity(0.3),
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
                      onTap: task.status != TaskStatus.completed ? onComplete : null,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: task.status == TaskStatus.completed
                              ? Colors.green
                              : Colors.transparent,
                          border: Border.all(
                            color: task.status == TaskStatus.completed
                                ? Colors.green
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: task.status == TaskStatus.completed
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // Task Title
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.status == TaskStatus.completed
                              ? Colors.grey[600]
                              : null,
                        ),
                      ),
                    ),
                    
                    // Priority Indicator
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getPriorityText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getPriorityColor(),
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
                if (task.description != null && task.description!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    task.description!,
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
                
                // Footer Row
                Row(
                  children: [
                    // Category
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getCategoryIcon(),
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 4),
                          Text(
                            _getCategoryText(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Spacer(),
                    
                    // Due Date
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: _isOverdue() ? Colors.red : Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        _getFormattedDueDate(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _isOverdue() ? Colors.red : Colors.grey[600],
                          fontWeight: _isOverdue() ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                    
                    // Estimated Time
                    if (task.estimatedMinutes != null) ...[
                      if (task.dueDate != null) SizedBox(width: 12),
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${task.estimatedMinutes}m',
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

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityText() {
    switch (task.priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Med';
      case TaskPriority.low:
        return 'Low';
    }
  }

  String _getCategoryIcon() {
    switch (task.category) {
      case TaskCategory.work:
        return '💼';
      case TaskCategory.personal:
        return '👤';
      case TaskCategory.health:
        return '🏥';
      case TaskCategory.learning:
        return '📚';
      case TaskCategory.finance:
        return '💰';
      case TaskCategory.social:
        return '👥';
      case TaskCategory.creative:
        return '🎨';
      case TaskCategory.maintenance:
        return '🔧';
    }
  }

  String _getCategoryText() {
    return task.category.toString().split('.').last;
  }

  bool _isOverdue() {
    if (task.dueDate == null || task.status == TaskStatus.completed) {
      return false;
    }
    return task.dueDate!.isBefore(DateTime.now());
  }

  String _getFormattedDueDate() {
    if (task.dueDate == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    
    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else if (taskDate.isBefore(today)) {
      final difference = today.difference(taskDate).inDays;
      return '${difference}d overdue';
    } else {
      final difference = taskDate.difference(today).inDays;
      if (difference <= 7) {
        return '${difference}d';
      } else {
        return '${task.dueDate!.day}/${task.dueDate!.month}';
      }
    }
  }
}

