import 'package:flutter/material.dart';
import '../models/goal.dart';

class AddGoalDialog extends StatefulWidget {
  final Goal? goal; // For editing existing goal
  final Function(
    String title,
    String? description,
    double targetValue,
    String unit,
    DateTime deadline,
    String category,
  ) onGoalCreated;

  const AddGoalDialog({
    Key? key,
    this.goal,
    required this.onGoalCreated,
  }) : super(key: key);

  @override
  _AddGoalDialogState createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _unitController = TextEditingController();

  String _selectedCategory = 'Personal';
  DateTime? _selectedDeadline;

  final List<String> _categories = [
    'Personal',
    'Health',
    'Finance',
    'Career',
    'Learning',
    'Fitness',
    'Relationships',
    'Travel',
    'Creative',
    'Business',
  ];

  @override
  void initState() {
    super.initState();
    
    // If editing existing goal, populate fields
    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description ?? '';
      _targetValueController.text = widget.goal!.targetValue.toString();
      _unitController.text = widget.goal!.unit;
      _selectedCategory = widget.goal!.category;
      _selectedDeadline = widget.goal!.deadline;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _unitController.dispose();
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
                    widget.goal != null ? 'Edit Goal' : 'Add New Goal',
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
                          labelText: 'Goal Title *',
                          hintText: 'e.g., Save $10,000 for emergency fund',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a goal title';
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
                          hintText: 'Add more details about your goal...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Target Value and Unit
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _targetValueController,
                              decoration: InputDecoration(
                                labelText: 'Target Value *',
                                hintText: '10000',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter target value';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _unitController,
                              decoration: InputDecoration(
                                labelText: 'Unit *',
                                hintText: 'USD, kg, hours',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter unit';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Text(_getCategoryIcon(category)),
                                SizedBox(width: 8),
                                Text(category),
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
                      
                      // Deadline
                      Text(
                        'Deadline',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDeadline,
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
                                _selectedDeadline != null
                                    ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                                    : 'Select deadline *',
                                style: TextStyle(
                                  color: _selectedDeadline != null
                                      ? Colors.black
                                      : Colors.grey[600],
                                ),
                              ),
                              Spacer(),
                              if (_selectedDeadline != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDeadline = null;
                                    });
                                  },
                                  child: Icon(Icons.clear, size: 20),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      if (_selectedDeadline == null) ...[
                        SizedBox(height: 8),
                        Text(
                          'Please select a deadline',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      
                      SizedBox(height: 20),
                      
                      // Quick Deadline Options
                      Text(
                        'Quick Options',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildQuickDeadlineChip('1 Month', 30),
                          _buildQuickDeadlineChip('3 Months', 90),
                          _buildQuickDeadlineChip('6 Months', 180),
                          _buildQuickDeadlineChip('1 Year', 365),
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
                      onPressed: _saveGoal,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(widget.goal != null ? 'Update' : 'Create'),
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

  Widget _buildQuickDeadlineChip(String label, int days) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeadline = DateTime.now().add(Duration(days: days));
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return '🏥';
      case 'finance':
        return '💰';
      case 'career':
        return '💼';
      case 'learning':
        return '📚';
      case 'fitness':
        return '💪';
      case 'relationships':
        return '❤️';
      case 'travel':
        return '✈️';
      case 'creative':
        return '🎨';
      case 'business':
        return '🚀';
      default:
        return '🎯';
    }
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDeadline = date;
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate() && _selectedDeadline != null) {
      final targetValue = double.parse(_targetValueController.text);
      
      widget.onGoalCreated(
        _titleController.text.trim(),
        _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        targetValue,
        _unitController.text.trim(),
        _selectedDeadline!,
        _selectedCategory,
      );
      
      Navigator.pop(context);
    }
  }
}

