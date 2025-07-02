import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mind_gym_viewmodel.dart';
import 'dart:math' as math;

class BreathingExercise extends StatefulWidget {
  @override
  _BreathingExerciseState createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      duration: Duration(seconds: 12), // 4-4-4 cycle
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
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
                '4-4-4 Breathing',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Breathe in for 4, hold for 4, breathe out for 4',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 40),
              
              // Breathing Circle
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_breathingAnimation, _pulseAnimation]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: viewModel.isBreathingActive ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 250,
                          height: 250,
                          child: CustomPaint(
                            painter: BreathingCirclePainter(
                              progress: _breathingAnimation.value,
                              phase: viewModel.breathingPhase,
                              isActive: viewModel.isBreathingActive,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getPhaseText(viewModel.breathingPhase),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: _getPhaseColor(viewModel.breathingPhase),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  if (viewModel.isBreathingActive)
                                    Text(
                                      'Cycle ${viewModel.breathingCycle + 1}',
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
                      );
                    },
                  ),
                ),
              ),
              
              SizedBox(height: 40),
              
              // Instructions
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  viewModel.isBreathingActive
                      ? _getInstructionText(viewModel.breathingPhase)
                      : 'Tap the button below to start your breathing exercise. Find a comfortable position and focus on your breath.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: 30),
              
              // Control Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (viewModel.isBreathingActive) {
                      viewModel.stopBreathing();
                      _breathingController.stop();
                      _pulseController.stop();
                    } else {
                      viewModel.startBreathing();
                      _breathingController.repeat();
                      _pulseController.repeat(reverse: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: viewModel.isBreathingActive
                        ? Colors.red[400]
                        : Theme.of(context).colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        viewModel.isBreathingActive
                            ? Icons.stop
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        viewModel.isBreathingActive ? 'Stop' : 'Start Breathing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPhaseText(String phase) {
    switch (phase) {
      case 'inhale':
        return 'Inhale';
      case 'hold':
        return 'Hold';
      case 'exhale':
        return 'Exhale';
      default:
        return 'Ready';
    }
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'inhale':
        return Colors.green;
      case 'hold':
        return Colors.orange;
      case 'exhale':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getInstructionText(String phase) {
    switch (phase) {
      case 'inhale':
        return 'Breathe in slowly through your nose. Fill your lungs completely.';
      case 'hold':
        return 'Hold your breath gently. Stay relaxed and calm.';
      case 'exhale':
        return 'Breathe out slowly through your mouth. Release all tension.';
      default:
        return 'Focus on your breath and let your mind become calm.';
    }
  }
}

class BreathingCirclePainter extends CustomPainter {
  final double progress;
  final String phase;
  final bool isActive;

  BreathingCirclePainter({
    required this.progress,
    required this.phase,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2 - 20;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(center, baseRadius, backgroundPaint);
    
    if (isActive) {
      // Animated breathing circle
      final breathingRadius = baseRadius * (0.6 + 0.4 * _getBreathingProgress());
      final breathingPaint = Paint()
        ..color = _getPhaseColor().withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, breathingRadius, breathingPaint);
      
      // Outer ring
      final ringPaint = Paint()
        ..color = _getPhaseColor()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      
      canvas.drawCircle(center, breathingRadius, ringPaint);
    }
  }

  double _getBreathingProgress() {
    // Convert progress to breathing cycle
    final cycleProgress = (progress * 3) % 3;
    
    if (cycleProgress < 1) {
      // Inhale phase
      return cycleProgress;
    } else if (cycleProgress < 2) {
      // Hold phase
      return 1.0;
    } else {
      // Exhale phase
      return 1.0 - (cycleProgress - 2);
    }
  }

  Color _getPhaseColor() {
    switch (phase) {
      case 'inhale':
        return Colors.green;
      case 'hold':
        return Colors.orange;
      case 'exhale':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(BreathingCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.phase != phase ||
           oldDelegate.isActive != isActive;
  }
}

