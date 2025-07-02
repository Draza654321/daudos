import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/mind_gym.dart';

class MindGymViewModel extends ChangeNotifier {
  List<MindGymSession> _sessions = [];
  MindGymSession? _currentSession;
  bool _isLoading = false;
  bool _isSessionActive = false;
  
  // Breathing exercise state
  bool _isBreathingActive = false;
  int _breathingCycle = 0;
  String _breathingPhase = 'inhale';
  Timer? _breathingTimer;
  
  // Brain dump state
  String _brainDumpText = '';
  List<String> _brainDumpEntries = [];
  
  // Focus session state
  bool _isFocusSessionActive = false;
  int _focusSessionMinutes = 25;
  int _focusSessionSecondsRemaining = 0;
  Timer? _focusTimer;

  // Getters
  List<MindGymSession> get sessions => _sessions;
  MindGymSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  bool get isSessionActive => _isSessionActive;
  
  bool get isBreathingActive => _isBreathingActive;
  int get breathingCycle => _breathingCycle;
  String get breathingPhase => _breathingPhase;
  
  String get brainDumpText => _brainDumpText;
  List<String> get brainDumpEntries => _brainDumpEntries;
  
  bool get isFocusSessionActive => _isFocusSessionActive;
  int get focusSessionMinutes => _focusSessionMinutes;
  int get focusSessionSecondsRemaining => _focusSessionSecondsRemaining;

  // Initialize
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    // TODO: Load data from repository
    _isLoading = false;
    notifyListeners();
  }

  // Breathing methods
  void startBreathing() {
    _isBreathingActive = true;
    _breathingCycle = 0;
    _breathingPhase = 'inhale';
    notifyListeners();
  }

  void stopBreathing() {
    _breathingTimer?.cancel();
    _isBreathingActive = false;
    notifyListeners();
  }

  // Brain dump methods
  void updateBrainDumpText(String text) {
    _brainDumpText = text;
    notifyListeners();
  }

  // Focus session methods
  void startFocusSession() {
    _isFocusSessionActive = true;
    _focusSessionSecondsRemaining = _focusSessionMinutes * 60;
    notifyListeners();
  }

  void stopFocusSession() {
    _focusTimer?.cancel();
    _isFocusSessionActive = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _focusTimer?.cancel();
    super.dispose();
  }
}

