import 'package:flutter/material.dart';
import '../models/task.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? task; // For editing existing task
  final Function(
    String title,
    String? description,
    TaskPriority priority,
    TaskCategory category,
    DateTime? dueDate,
    int? estimatedMinutes,
  ) onTaskCreated;

  const AddTaskDialog({
    Key? key,
    this.task,
    required this.onTaskCreated,
  }) : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedMinutesController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskCategory _selectedCategory = TaskCategory.work;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    
    // If editing existing task, populate fields
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedPriority = widget.task!.priority;
      _selectedCategory = widget.task!.category;
      _selectedDueDate = widget.task!.dueDate;
      if (widget.task!.estimatedMinutes != null) {
        _estimatedMinutesController.text = widget.task!.estimatedMinutes.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.task != null ? 'Edit Task' : 'Add New Task',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Task Title *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task title';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Priority Selection
                      Text(
                        'Priority',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: TaskPriority.values.map((priority) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: _buildPriorityChip(priority),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Category Selection
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<TaskCategory>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: TaskCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Text(_getCategoryIcon(category)),
                                SizedBox(width: 8),
                                Text(_getCategoryName(category)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Due Date
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Due Date',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                InkWell(
                                  onTap: _selectDueDate,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          _selectedDueDate != null
                                              ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                                              : 'Select date',
                                          style: TextStyle(
                                            color: _selectedDueDate != null
                                                ? Colors.black
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        Spacer(),
                                        if (_selectedDueDate != null)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedDueDate = null;
                                              });
                                            },
                                            child: Icon(Icons.clear, size: 20),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(width: 16),
                          
                          // Estimated Time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Est. Time (min)',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _estimatedMinutesController,
                                  decoration: InputDecoration(
                                    hintText: '30',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(widget.task != null ? 'Update' : 'Create'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    final isSelected = _selectedPriority == priority;
    final color = _getPriorityColor(priority);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
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
            _getPriorityName(priority),
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  String _getCategoryIcon(TaskCategory category) {
    switch (category) {
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

  String _getCategoryName(TaskCategory category) {
    return category.toString().split('.').last.replaceFirst(
      category.toString().split('.').last[0],
      category.toString().split('.').last[0].toUpperCase(),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final estimatedMinutes = _estimatedMinutesController.text.isNotEmpty
          ? int.tryParse(_estimatedMinutesController.text)
          : null;
      
      widget.onTaskCreated(
        _titleController.text.trim(),
        _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        _selectedPriority,
        _selectedCategory,
        _selectedDueDate,
        estimatedMinutes,
      );
      
      Navigator.pop(context);
    }
  }
}

