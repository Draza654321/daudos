import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mind_gym_viewmodel.dart';
import 'dart:math' as math;

class FocusTimer extends StatefulWidget {
  @override
  _FocusTimerState createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> with TickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;

  @override
  void initState() {
    super.initState();
    
    _timerController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    
    _timerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _timerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MindGymViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Text(
                'Focus Builder',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Use the Pomodoro technique to build deep focus',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 40),
              
              // Timer Display
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Circular Timer
                      Container(
                        width: 250,
                        height: 250,
                        child: CustomPaint(
                          painter: TimerCirclePainter(
                            progress: viewModel.isFocusSessionActive
                                ? 1.0 - (viewModel.focusSessionSecondsRemaining / (viewModel.focusSessionMinutes * 60))
                                : 0.0,
                            isActive: viewModel.isFocusSessionActive,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  viewModel.isFocusSessionActive
                                      ? '${(viewModel.focusSessionSecondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(viewModel.focusSessionSecondsRemaining % 60).toString().padLeft(2, '0')}'
                                      : '${viewModel.focusSessionMinutes}:00',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: viewModel.isFocusSessionActive
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  viewModel.isFocusSessionActive
                                      ? 'Focus Time'
                                      : 'Ready to Focus',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 40),
                      
                      // Duration Selector
                      if (!viewModel.isFocusSessionActive) ...[
                        Text(
                          'Session Duration',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDurationButton(15, viewModel),
                            _buildDurationButton(25, viewModel),
                            _buildDurationButton(45, viewModel),
                            _buildDurationButton(60, viewModel),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 40),
              
              // Instructions
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  viewModel.isFocusSessionActive
                      ? 'Stay focused on your task. Avoid distractions and give your full attention to what you\'re working on.'
                      : 'Choose your focus duration and start a deep work session. Put away distractions and commit to focused work.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: 30),
              
              // Control Buttons
              if (viewModel.isFocusSessionActive) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          viewModel.stopFocusSession();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Stop'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement pause/resume
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Pause'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.startFocusSession();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 8),
                        Text(
                          'Start Focus Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDurationButton(int minutes, MindGymViewModel viewModel) {
    final isSelected = viewModel.focusSessionMinutes == minutes;
    
    return GestureDetector(
      onTap: () {
        viewModel.setFocusSessionDuration(minutes);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '${minutes}m',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

class TimerCirclePainter extends CustomPainter {
  final double progress;
  final bool isActive;

  TimerCirclePainter({
    required this.progress,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    if (isActive && progress > 0) {
      // Progress arc
      final progressPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      
      final startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(TimerCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}

