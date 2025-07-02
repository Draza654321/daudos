import 'package:flutter/material.dart';
import '../models/habit.dart';

class AddHabitDialog extends StatefulWidget {
  final Habit? habit; // For editing existing habit
  final Function(
    String title,
    String? description,
    HabitType type,
    HabitFrequency frequency,
    TimeOfDay? reminderTime,
  ) onHabitCreated;

  const AddHabitDialog({
    Key? key,
    this.habit,
    required this.onHabitCreated,
  }) : super(key: key);

  @override
  _AddHabitDialogState createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  HabitType _selectedType = HabitType.power;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  TimeOfDay? _selectedReminderTime;

  @override
  void initState() {
    super.initState();
    
    // If editing existing habit, populate fields
    if (widget.habit != null) {
      _titleController.text = widget.habit!.title;
      _descriptionController.text = widget.habit!.description ?? '';
      _selectedType = widget.habit!.type;
      _selectedFrequency = widget.habit!.frequency;
      _selectedReminderTime = widget.habit!.reminderTime;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
                    widget.habit != null ? 'Edit Habit' : 'Add New Habit',
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
                          labelText: 'Habit Title *',
                          hintText: 'e.g., Drink 8 glasses of water',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a habit title';
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
                          hintText: 'Add more details about your habit...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Habit Type Selection
                      Text(
                        'Habit Type',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildHabitTypeChip(
                              'Power Habit',
                              'Build positive behaviors',
                              HabitType.power,
                              Colors.green,
                              Icons.trending_up,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildHabitTypeChip(
                              'Struggle Habit',
                              'Break negative patterns',
                              HabitType.struggle,
                              Colors.red,
                              Icons.trending_down,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Frequency Selection
                      Text(
                        'Frequency',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                        children: HabitFrequency.values.map((frequency) {
                          return RadioListTile<HabitFrequency>(
                            title: Text(_getFrequencyTitle(frequency)),
                            subtitle: Text(_getFrequencyDescription(frequency)),
                            value: frequency,
                            groupValue: _selectedFrequency,
                            onChanged: (value) {
                              setState(() {
                                _selectedFrequency = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Reminder Time
                      Text(
                        'Reminder Time (Optional)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: _selectReminderTime,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.notifications, size: 20),
                              SizedBox(width: 8),
                              Text(
                                _selectedReminderTime != null
                                    ? _formatTime(_selectedReminderTime!)
                                    : 'Set reminder time',
                                style: TextStyle(
                                  color: _selectedReminderTime != null
                                      ? Colors.black
                                      : Colors.grey[600],
                                ),
                              ),
                              Spacer(),
                              if (_selectedReminderTime != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedReminderTime = null;
                                    });
                                  },
                                  child: Icon(Icons.clear, size: 20),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Quick Time Options
                      Text(
                        'Quick Options',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildQuickTimeChip('Morning', TimeOfDay(hour: 7, minute: 0)),
                          _buildQuickTimeChip('Afternoon', TimeOfDay(hour: 14, minute: 0)),
                          _buildQuickTimeChip('Evening', TimeOfDay(hour: 18, minute: 0)),
                          _buildQuickTimeChip('Night', TimeOfDay(hour: 21, minute: 0)),
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
                      onPressed: _saveHabit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(widget.habit != null ? 'Update' : 'Create'),
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

  Widget _buildHabitTypeChip(
    String title,
    String description,
    HabitType type,
    Color color,
    IconData icon,
  ) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTimeChip(String label, TimeOfDay time) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReminderTime = time;
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
          '$label (${_formatTime(time)})',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  String _getFrequencyTitle(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
    }
  }

  String _getFrequencyDescription(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Every day';
      case HabitFrequency.weekly:
        return 'Once per week';
      case HabitFrequency.monthly:
        return 'Once per month';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _selectedReminderTime = time;
      });
    }
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      widget.onHabitCreated(
        _titleController.text.trim(),
        _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        _selectedType,
        _selectedFrequency,
        _selectedReminderTime,
      );
      
      Navigator.pop(context);
    }
  }
}

