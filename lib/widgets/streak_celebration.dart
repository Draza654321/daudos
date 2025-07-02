import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class StreakCelebration extends StatefulWidget {
  final int streak;
  final String habitName;
  final VoidCallback? onDismiss;

  const StreakCelebration({
    Key? key,
    required this.streak,
    required this.habitName,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<StreakCelebration> createState() => _StreakCelebrationState();
}

class _StreakCelebrationState extends State<StreakCelebration>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late ConfettiController _confettiController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _confettiController = ConfettiController(
      duration: Duration(seconds: 3),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _rotationController.repeat();
    _confettiController.play();

    // Auto dismiss after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _fadeController.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  String _getCelebrationMessage() {
    if (widget.streak == 1) {
      return "Great start!";
    } else if (widget.streak == 7) {
      return "One week strong!";
    } else if (widget.streak == 30) {
      return "Habit formed!";
    } else if (widget.streak == 100) {
      return "Elite level!";
    } else if (widget.streak % 10 == 0) {
      return "Milestone reached!";
    } else {
      return "Keep it up!";
    }
  }

  Color _getStreakColor() {
    if (widget.streak >= 100) {
      return Colors.purple;
    } else if (widget.streak >= 30) {
      return Colors.orange;
    } else if (widget.streak >= 7) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Material(
            color: Colors.black54,
            child: Stack(
              children: [
                // Confetti
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: 1.57, // radians - 90 degrees
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 50,
                    gravity: 0.05,
                    shouldLoop: false,
                    colors: [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.orange,
                      Colors.purple,
                    ],
                  ),
                ),
                
                // Main content
                Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          margin: EdgeInsets.all(32),
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getStreakColor(),
                                _getStreakColor().withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Fire icon with rotation
                              AnimatedBuilder(
                                animation: _rotationAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _rotationAnimation.value * 0.1,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.local_fire_department,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Streak number
                              Text(
                                '${widget.streak}',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              
                              Text(
                                'Day Streak!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Habit name
                              Text(
                                widget.habitName,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              SizedBox(height: 8),
                              
                              // Celebration message
                              Text(
                                _getCelebrationMessage(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Dismiss button
                              ElevatedButton.icon(
                                onPressed: _dismiss,
                                icon: Icon(Icons.celebration, color: _getStreakColor()),
                                label: Text('Awesome!'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: _getStreakColor(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

