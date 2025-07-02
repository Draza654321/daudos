import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/mood.dart';
import '../services/mood_repository.dart';
import '../services/user_repository.dart';

class MoodViewModel extends ChangeNotifier {
  final MoodRepository _moodRepository = MoodRepository();
  final UserRepository _userRepository = UserRepository();

  Mood? _currentMood;
  List<Mood> _recentMoods = [];
  Map<String, double> _moodTrends = {};
  bool _isLoading = false;
  bool _hasCheckedInToday = false;

  // Getters
  Mood? get currentMood => _currentMood;
  List<Mood> get recentMoods => _recentMoods;
  Map<String, double> get moodTrends => _moodTrends;
  bool get isLoading => _isLoading;
  bool get hasCheckedInToday => _hasCheckedInToday;

  // Initialize mood data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        await _loadTodaysMood(user.id);
        await _loadRecentMoods(user.id);
        await _loadMoodTrends(user.id);
      }
    } catch (e) {
      print('Error initializing mood data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load today's mood
  Future<void> _loadTodaysMood(String userId) async {
    _currentMood = await _moodRepository.getTodaysMood(userId);
    _hasCheckedInToday = _currentMood != null;
  }

  // Load recent moods (last 7 days)
  Future<void> _loadRecentMoods(String userId) async {
    _recentMoods = await _moodRepository.getMoodsForUser(userId, limit: 7);
  }

  // Load mood trends (last 30 days)
  Future<void> _loadMoodTrends(String userId) async {
    _moodTrends = await _moodRepository.getMoodTrends(userId);
  }

  // Create or update mood check-in
  Future<void> checkInMood({
    required int clarity,
    required int focus,
    required int energy,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) return;

      final now = DateTime.now();
      
      if (_currentMood != null) {
        // Update existing mood
        final updatedMood = _currentMood!.copyWith(
          clarity: clarity,
          focus: focus,
          energy: energy,
          notes: notes,
          timestamp: now,
        );
        await _moodRepository.updateMood(updatedMood);
        _currentMood = updatedMood;
      } else {
        // Create new mood entry
        final newMood = Mood(
          id: 'mood_${user.id}_${now.millisecondsSinceEpoch}',
          userId: user.id,
          clarity: clarity,
          focus: focus,
          energy: energy,
          notes: notes,
          timestamp: now,
        );
        await _moodRepository.createMood(newMood);
        _currentMood = newMood;
      }

      _hasCheckedInToday = true;
      await _loadRecentMoods(user.id);
      await _loadMoodTrends(user.id);
    } catch (e) {
      print('Error checking in mood: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get mood color based on average score
  Color getMoodColor(double averageScore) {
    if (averageScore <= 1.5) {
      return Color(0xFFEF4444); // Red - Very low
    } else if (averageScore <= 2.5) {
      return Color(0xFFF59E0B); // Orange - Low
    } else if (averageScore <= 3.5) {
      return Color(0xFFEAB308); // Yellow - Medium
    } else if (averageScore <= 4.5) {
      return Color(0xFF22C55E); // Green - Good
    } else {
      return Color(0xFF10B981); // Emerald - Excellent
    }
  }

  // Get mood emoji based on average score
  String getMoodEmoji(double averageScore) {
    if (averageScore <= 1.5) {
      return '😞';
    } else if (averageScore <= 2.5) {
      return '😕';
    } else if (averageScore <= 3.5) {
      return '😐';
    } else if (averageScore <= 4.5) {
      return '😊';
    } else {
      return '😄';
    }
  }

  // Get mood description
  String getMoodDescription(double averageScore) {
    if (averageScore <= 1.5) {
      return 'Struggling';
    } else if (averageScore <= 2.5) {
      return 'Low Energy';
    } else if (averageScore <= 3.5) {
      return 'Neutral';
    } else if (averageScore <= 4.5) {
      return 'Good Vibes';
    } else {
      return 'Peak State';
    }
  }

  // Get suggestions based on current mood
  List<String> getMoodSuggestions() {
    if (_currentMood == null) {
      return [
        'Check in with your mood to get personalized suggestions',
        'Regular mood tracking helps identify patterns',
      ];
    }

    final avgScore = _currentMood!.averageScore;
    final clarity = _currentMood!.clarity;
    final focus = _currentMood!.focus;
    final energy = _currentMood!.energy;

    List<String> suggestions = [];

    // Low energy suggestions
    if (energy <= 2) {
      suggestions.addAll([
        'Take a 10-minute walk or do light stretching',
        'Try the 4-4-4 breathing exercise',
        'Consider a power nap (15-20 minutes)',
        'Hydrate and have a healthy snack',
      ]);
    }

    // Low focus suggestions
    if (focus <= 2) {
      suggestions.addAll([
        'Try the Pomodoro technique (25 min focused work)',
        'Clear your workspace of distractions',
        'Use background music or white noise',
        'Break large tasks into smaller chunks',
      ]);
    }

    // Low clarity suggestions
    if (clarity <= 2) {
      suggestions.addAll([
        'Do a brain dump - write down all your thoughts',
        'Practice meditation for 5-10 minutes',
        'Review your goals and priorities',
        'Talk to someone you trust about what\'s on your mind',
      ]);
    }

    // High mood suggestions
    if (avgScore >= 4) {
      suggestions.addAll([
        'Great energy! Tackle your most challenging task',
        'Use this momentum to make progress on important goals',
        'Share your positive energy with others',
        'Document what\'s working well for you today',
      ]);
    }

    return suggestions.take(3).toList();
  }

  // Refresh mood data
  Future<void> refresh() async {
    await initialize();
  }
}

