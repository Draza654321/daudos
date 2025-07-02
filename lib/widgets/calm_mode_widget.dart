import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/motivation_engine.dart';

class CalmModeWidget extends StatefulWidget {
  final VoidCallback? onClose;

  const CalmModeWidget({Key? key, this.onClose}) : super(key: key);

  @override
  State<CalmModeWidget> createState() => _CalmModeWidgetState();
}

class _CalmModeWidgetState extends State<CalmModeWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _fadeController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isBreathing = false;
  int _breathingCycles = 0;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      duration: Duration(seconds: 8), // 4 seconds in, 4 seconds out
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _breathingCycles = 0;
    });
    
    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _breathingCycles++;
        });
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (_isBreathing) {
          _breathingController.forward();
        }
      }
    });
    
    _breathingController.forward();
  }

  void _stopBreathing() {
    setState(() {
      _isBreathing = false;
    });
    _breathingController.stop();
    _breathingController.reset();
  }

  String _getBreathingInstruction() {
    if (!_isBreathing) return "Tap to start breathing";
    
    if (_breathingController.status == AnimationStatus.forward) {
      return "Breathe In...";
    } else {
      return "Breathe Out...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.shade100,
                  Colors.blue.shade100,
                  Colors.purple.shade100,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Calm Mode',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: Icon(Icons.close, color: Colors.indigo.shade700),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Breathing circle
                        GestureDetector(
                          onTap: _isBreathing ? _stopBreathing : _startBreathing,
                          child: AnimatedBuilder(
                            animation: _breathingAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 200 * _breathingAnimation.value,
                                height: 200 * _breathingAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.blue.shade200.withOpacity(0.8),
                                      Colors.blue.shade400.withOpacity(0.6),
                                      Colors.blue.shade600.withOpacity(0.4),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    _isBreathing ? Icons.pause : Icons.play_arrow,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        SizedBox(height: 32),
                        
                        // Breathing instruction
                        Text(
                          _getBreathingInstruction(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Cycles counter
                        if (_isBreathing)
                          Text(
                            'Cycles: $_breathingCycles',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.indigo.shade600,
                            ),
                          ),
                        
                        SizedBox(height: 48),
                        
                        // Calm affirmations
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 32),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.spa,
                                size: 32,
                                color: Colors.green.shade600,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'You are exactly where you need to be',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Take this moment to reset and recharge. Your empire will be here when you return.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.indigo.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<MotivationEngine>().triggerCalmMode();
                            },
                            icon: Icon(Icons.volume_up),
                            label: Text('Calm Voice'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade400,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onClose,
                            icon: Icon(Icons.check),
                            label: Text('I\'m Ready'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

