import 'package:flutter/material.dart';
import 'dart:math' as math;

class WinMeter extends StatefulWidget {
  final double progress;
  final Color color;
  final String title;
  final String subtitle;

  const WinMeter({
    Key? key,
    required this.progress,
    required this.color,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  _WinMeterState createState() => _WinMeterState();
}

class _WinMeterState extends State<WinMeter> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();
    
    if (widget.progress > 0.8) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(WinMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      
      _progressController.reset();
      _progressController.forward();
      
      if (widget.progress > 0.8 && oldWidget.progress <= 0.8) {
        _pulseController.repeat(reverse: true);
      } else if (widget.progress <= 0.8 && oldWidget.progress > 0.8) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Title and Subtitle
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Circular Progress Meter
            AnimatedBuilder(
              animation: Listenable.merge([_progressAnimation, _pulseAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.progress > 0.8 ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: WinMeterPainter(
                        progress: _progressAnimation.value,
                        color: widget.color,
                        backgroundColor: Colors.grey[300]!,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(_progressAnimation.value * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: widget.color,
                              ),
                            ),
                            Text(
                              _getProgressLabel(_progressAnimation.value),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
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
            
            SizedBox(height: 20),
            
            // Progress Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProgressIndicator(
                  icon: Icons.task_alt,
                  label: 'Tasks',
                  progress: widget.progress,
                ),
                _buildProgressIndicator(
                  icon: Icons.track_changes,
                  label: 'Habits',
                  progress: widget.progress,
                ),
                _buildProgressIndicator(
                  icon: Icons.mood,
                  label: 'Mood',
                  progress: widget.progress,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({
    required IconData icon,
    required String label,
    required double progress,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: widget.color,
            size: 20,
          ),
        ),
        SizedBox(height: 4),
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

  String _getProgressLabel(double progress) {
    if (progress < 0.2) {
      return 'Getting Started';
    } else if (progress < 0.4) {
      return 'Building Momentum';
    } else if (progress < 0.6) {
      return 'Making Progress';
    } else if (progress < 0.8) {
      return 'Strong Performance';
    } else if (progress < 1.0) {
      return 'Crushing It!';
    } else {
      return 'Perfect Day!';
    }
  }
}

class WinMeterPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  WinMeterPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
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
    
    // Glow effect for high progress
    if (progress > 0.8) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(WinMeterPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}

