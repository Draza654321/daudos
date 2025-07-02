import 'package:flutter/material.dart';

class MoodSelector extends StatefulWidget {
  final Function(int clarity, int focus, int energy, String? notes) onMoodSelected;

  const MoodSelector({
    Key? key,
    required this.onMoodSelected,
  }) : super(key: key);

  @override
  _MoodSelectorState createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> with TickerProviderStateMixin {
  int _clarity = 3;
  int _focus = 3;
  int _energy = 3;
  final TextEditingController _notesController = TextEditingController();
  
  late AnimationController _submitController;
  late Animation<double> _submitAnimation;

  @override
  void initState() {
    super.initState();
    
    _submitController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    
    _submitAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _submitController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _notesController.dispose();
    _submitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clarity Selector
        _buildMoodSlider(
          'Clarity',
          'How clear is your thinking?',
          _clarity,
          Colors.blue,
          (value) => setState(() => _clarity = value),
        ),
        
        SizedBox(height: 20),
        
        // Focus Selector
        _buildMoodSlider(
          'Focus',
          'How focused do you feel?',
          _focus,
          Colors.green,
          (value) => setState(() => _focus = value),
        ),
        
        SizedBox(height: 20),
        
        // Energy Selector
        _buildMoodSlider(
          'Energy',
          'What\'s your energy level?',
          _energy,
          Colors.orange,
          (value) => setState(() => _energy = value),
        ),
        
        SizedBox(height: 20),
        
        // Notes Input
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Notes (optional)',
            hintText: 'How are you feeling? What\'s on your mind?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.note_alt_outlined),
          ),
          maxLines: 3,
          maxLength: 200,
        ),
        
        SizedBox(height: 20),
        
        // Submit Button
        AnimatedBuilder(
          animation: _submitAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _submitAnimation.value,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitMood,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text(
                        'Check In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMoodSlider(
    String title,
    String subtitle,
    int value,
    Color color,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                '$value/5',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12),
        
        // Custom Slider
        Row(
          children: List.generate(5, (index) {
            final isSelected = index < value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index + 1),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
        
        SizedBox(height: 8),
        
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Low',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
            Text(
              'High',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitMood() async {
    await _submitController.forward();
    await _submitController.reverse();
    
    widget.onMoodSelected(
      _clarity,
      _focus,
      _energy,
      _notesController.text.isNotEmpty ? _notesController.text : null,
    );
  }
}

