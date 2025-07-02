import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/motivation_engine.dart';

class MotivationOverlay extends StatefulWidget {
  final String quote;
  final MotivationLevel level;
  final VoidCallback? onDismiss;

  const MotivationOverlay({
    Key? key,
    required this.quote,
    required this.level,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<MotivationOverlay> createState() => _MotivationOverlayState();
}

class _MotivationOverlayState extends State<MotivationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    Future.delayed(Duration(seconds: 8), () {
      if (mounted) {
        _dismissOverlay();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _dismissOverlay() {
    _fadeController.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  Color _getBackgroundColor() {
    switch (widget.level) {
      case MotivationLevel.warrior:
        return Colors.red.withOpacity(0.9);
      case MotivationLevel.peak:
        return Colors.orange.withOpacity(0.9);
      case MotivationLevel.energetic:
        return Colors.blue.withOpacity(0.9);
      case MotivationLevel.calm:
        return Colors.green.withOpacity(0.9);
      case MotivationLevel.burnout:
        return Colors.purple.withOpacity(0.9);
      default:
        return Colors.indigo.withOpacity(0.9);
    }
  }

  IconData _getIcon() {
    switch (widget.level) {
      case MotivationLevel.warrior:
        return Icons.flash_on;
      case MotivationLevel.peak:
        return Icons.trending_up;
      case MotivationLevel.energetic:
        return Icons.battery_charging_full;
      case MotivationLevel.calm:
        return Icons.spa;
      case MotivationLevel.burnout:
        return Icons.self_improvement;
      default:
        return Icons.star;
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
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        margin: EdgeInsets.all(32),
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getBackgroundColor(),
                              _getBackgroundColor().withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
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
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: Icon(
                                _getIcon(),
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            
                            SizedBox(height: 24),
                            
                            Text(
                              widget.quote,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: 24),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Consumer<MotivationEngine>(
                                  builder: (context, engine, child) {
                                    if (engine.isSpeaking) {
                                      return ElevatedButton.icon(
                                        onPressed: () {
                                          engine.stopSpeaking();
                                        },
                                        icon: Icon(Icons.stop, color: Colors.red),
                                        label: Text('Stop'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                                
                                ElevatedButton.icon(
                                  onPressed: _dismissOverlay,
                                  icon: Icon(Icons.check, color: Colors.green),
                                  label: Text('Got it!'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

