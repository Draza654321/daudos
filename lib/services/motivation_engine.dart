import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/mood.dart';
import '../models/user.dart';
import '../models/analytics.dart';
import '../services/mood_repository.dart';
import '../services/analytics_repository.dart';

class MotivationEngine extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  final MoodRepository _moodRepository = MoodRepository();
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();
  
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentQuote = '';
  MotivationLevel _currentLevel = MotivationLevel.neutral;
  Timer? _dailyMotivationTimer;
  Timer? _burnoutCheckTimer;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  String get currentQuote => _currentQuote;
  MotivationLevel get currentLevel => _currentLevel;

  // Initialize the motivation engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize TTS
      await _initializeTTS();
      
      // Start daily motivation timer
      _startDailyMotivationTimer();
      
      // Start burnout check timer
      _startBurnoutCheckTimer();
      
      _isInitialized = true;
      notifyListeners();
      
      print('Motivation Engine initialized successfully');
    } catch (e) {
      print('Error initializing Motivation Engine: $e');
    }
  }

  // Initialize Text-to-Speech
  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      notifyListeners();
      print('TTS Error: $msg');
    });
  }

  // Start daily motivation timer
  void _startDailyMotivationTimer() {
    // Trigger motivation every 4 hours during work hours
    _dailyMotivationTimer = Timer.periodic(Duration(hours: 4), (timer) {
      _triggerDailyMotivation();
    });
  }

  // Start burnout check timer
  void _startBurnoutCheckTimer() {
    // Check for burnout every 30 minutes
    _burnoutCheckTimer = Timer.periodic(Duration(minutes: 30), (timer) {
      _checkForBurnout();
    });
  }

  // Trigger daily motivation based on time and mood
  Future<void> _triggerDailyMotivation() async {
    try {
      final now = DateTime.now();
      final hour = now.hour;
      
      // Daud's work hours: 6 PM - 6 AM PKT (18:00 - 06:00)
      if ((hour >= 18 && hour <= 23) || (hour >= 0 && hour <= 6)) {
        final quote = _getTimeBasedQuote(hour);
        await speakMotivation(quote);
      }
    } catch (e) {
      print('Error triggering daily motivation: $e');
    }
  }

  // Check for burnout and provide calm mode suggestions
  Future<void> _checkForBurnout() async {
    try {
      final recentMoods = await _moodRepository.getRecentMoods('user_daud', 3);
      
      if (recentMoods.length >= 2) {
        final avgEnergy = recentMoods.map((m) => m.energy).reduce((a, b) => a + b) / recentMoods.length;
        final avgFocus = recentMoods.map((m) => m.focus).reduce((a, b) => a + b) / recentMoods.length;
        
        if (avgEnergy < 2.5 && avgFocus < 2.5) {
          _currentLevel = MotivationLevel.burnout;
          await _triggerBurnoutSupport();
        } else if (avgEnergy > 4.0 && avgFocus > 4.0) {
          _currentLevel = MotivationLevel.peak;
          await _triggerPeakPerformanceMotivation();
        } else {
          _currentLevel = MotivationLevel.neutral;
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error checking for burnout: $e');
    }
  }

  // Trigger burnout support
  Future<void> _triggerBurnoutSupport() async {
    final burnoutQuotes = [
      "Daud, even the strongest warriors need rest. Take a moment to breathe.",
      "Your empire is built one brick at a time. Rest is part of the foundation.",
      "Champions know when to push and when to recover. This is your recovery moment.",
      "The dispatch world is demanding, but you're stronger than any challenge.",
      "Take 5 minutes for yourself. Your future self will thank you.",
    ];
    
    final quote = burnoutQuotes[Random().nextInt(burnoutQuotes.length)];
    await speakMotivation(quote, isCalm: true);
  }

  // Trigger peak performance motivation
  Future<void> _triggerPeakPerformanceMotivation() async {
    final peakQuotes = [
      "Daud, you're in the zone! This is your 1% moment - seize it!",
      "Your energy is electric right now. Channel it into your empire building!",
      "Peak performance mode activated. Show the world what a self-taught champion can do!",
      "This is the energy that separates entrepreneurs from employees. Keep pushing!",
      "You're operating at full capacity. This is how empires are built!",
    ];
    
    final quote = peakQuotes[Random().nextInt(peakQuotes.length)];
    await speakMotivation(quote, isEnergetic: true);
  }

  // Get time-based motivational quote
  String _getTimeBasedQuote(int hour) {
    if (hour >= 18 && hour <= 20) {
      // Evening start quotes
      final quotes = [
        "Daud, the night shift begins! Time to build your empire while others sleep.",
        "Evening warrior mode activated. Let's make this dispatch session legendary!",
        "The world sleeps, but champions work. Your time is now, Daud!",
        "Another night, another step closer to your dreams. Let's dominate!",
        "The dispatch desk is your battlefield. Show them what a self-taught king can do!",
      ];
      return quotes[Random().nextInt(quotes.length)];
    } else if (hour >= 21 && hour <= 23) {
      // Mid-evening quotes
      final quotes = [
        "Daud, you're in the deep work zone. This is where magic happens!",
        "The night is young and so is your potential. Keep grinding!",
        "Every call you handle is building your future. Stay focused!",
        "This is your prime time. Make every moment count!",
        "The dispatch world needs your excellence. Deliver it!",
      ];
      return quotes[Random().nextInt(quotes.length)];
    } else if (hour >= 0 && hour <= 2) {
      // Late night quotes
      final quotes = [
        "Daud, the midnight oil burns bright for champions like you!",
        "While others dream, you're building reality. Respect!",
        "The late night grind separates the ordinary from the extraordinary.",
        "Your dedication at this hour is what legends are made of!",
        "The night shift is your domain. Rule it with excellence!",
      ];
      return quotes[Random().nextInt(quotes.length)];
    } else if (hour >= 3 && hour <= 6) {
      // Early morning quotes
      final quotes = [
        "Daud, the final stretch! Finish strong like the champion you are!",
        "Dawn approaches, and so does your victory. Push through!",
        "The hardest hours make the strongest warriors. You've got this!",
        "Almost there, champion. Your empire awaits your final push!",
        "The sunrise will celebrate another successful night. Make it count!",
      ];
      return quotes[Random().nextInt(quotes.length)];
    } else {
      // General motivational quotes
      final quotes = [
        "Daud, every moment is a chance to level up. Take it!",
        "Your journey from zero to hero continues. Keep climbing!",
        "Self-taught, self-made, self-motivated. That's the Daud way!",
        "The dispatch world is lucky to have your excellence!",
        "Another step forward in your empire-building journey!",
      ];
      return quotes[Random().nextInt(quotes.length)];
    }
  }

  // Speak motivation with TTS
  Future<void> speakMotivation(String text, {bool isCalm = false, bool isEnergetic = false}) async {
    if (!_isInitialized) return;

    try {
      _currentQuote = text;
      
      // Adjust TTS settings based on mood
      if (isCalm) {
        await _flutterTts.setSpeechRate(0.4);
        await _flutterTts.setPitch(0.8);
      } else if (isEnergetic) {
        await _flutterTts.setSpeechRate(0.6);
        await _flutterTts.setPitch(1.2);
      } else {
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);
      }
      
      await _flutterTts.speak(text);
      notifyListeners();
      
      // Log motivation event
      await _logMotivationEvent(text, isCalm, isEnergetic);
    } catch (e) {
      print('Error speaking motivation: $e');
    }
  }

  // Stop current speech
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    }
  }

  // Get mood-aware motivation
  Future<String> getMoodAwareMotivation(Mood mood) async {
    if (mood.energy < 2.5 && mood.focus < 2.5) {
      // Low energy and focus - burnout support
      final quotes = [
        "Daud, your energy is low but your spirit is unbreakable. Take a moment to recharge.",
        "Even rockets need fuel stops. Rest now, soar later.",
        "The strongest trees bend in the storm. Be flexible with yourself today.",
        "Your empire needs a rested king. Take care of yourself first.",
        "Low energy today means explosive energy tomorrow. Rest is productive.",
      ];
      return quotes[Random().nextInt(quotes.length)];
    } else if (mood.energy > 4.0 && mood.focus > 4.0) {
      // High energy and focus - peak performance
      final quotes = [
        "Daud, you're operating at maximum capacity! This is your moment to shine!",
        "Peak performance mode: ACTIVATED! Show the world what excellence looks like!",
        "Your energy and focus are aligned perfectly. This is how empires are built!",
        "You're in the zone, champion! Every action you take right now creates your future!",
        "Maximum power, maximum focus. You're unstoppable right now!",
      ];
      return quotes[Random().nextInt(quotes.length)];
    } else if (mood.clarity < 2.5) {
      // Low clarity - focus support
      final quotes = [
        "Daud, when the path seems unclear, trust your instincts. You've got this!",
        "Clarity comes to those who keep moving forward. Take the next step.",
        "The fog will lift, champion. Your vision is stronger than any confusion.",
        "Every successful entrepreneur faces unclear moments. Push through!",
        "Your clarity will return. For now, trust your experience and keep going.",
      ];
      return quotes[Random().nextInt(quotes.length)];
    } else {
      // Balanced mood - general motivation
      final quotes = [
        "Daud, you're in a good flow state. Ride this wave to success!",
        "Balanced energy, focused mind. Perfect conditions for empire building!",
        "You're operating in the sweet spot. Make the most of this momentum!",
        "Steady progress, steady growth. This is the path to greatness!",
        "Your consistency is your superpower. Keep this rhythm going!",
      ];
      return quotes[Random().nextInt(quotes.length)];
    }
  }

  // Get random motivational quote
  String getRandomQuote() {
    final quotes = [
      "Daud, every expert was once a beginner. You're already ahead of the game!",
      "Self-taught means self-motivated. That's your competitive advantage!",
      "The dispatch world is your training ground for bigger things!",
      "Your empire starts with today's actions. Make them count!",
      "Champions aren't made in comfort zones. You're exactly where you need to be!",
      "The night shift is your secret weapon. Use it wisely!",
      "Every call you handle builds your communication empire!",
      "You're not just working, you're investing in your future!",
      "The grind today creates the freedom tomorrow!",
      "Your dedication is your differentiation. Keep grinding!",
    ];
    
    _currentQuote = quotes[Random().nextInt(quotes.length)];
    return _currentQuote;
  }

  // Log motivation event for analytics
  Future<void> _logMotivationEvent(String quote, bool isCalm, bool isEnergetic) async {
    try {
      // This would log the motivation event for analytics
      print('Motivation Event: $quote (Calm: $isCalm, Energetic: $isEnergetic)');
    } catch (e) {
      print('Error logging motivation event: $e');
    }
  }

  // Trigger calm mode
  Future<void> triggerCalmMode() async {
    _currentLevel = MotivationLevel.calm;
    notifyListeners();
    
    final calmQuote = "Daud, take a deep breath. You're exactly where you need to be. Let's find your center.";
    await speakMotivation(calmQuote, isCalm: true);
  }

  // Trigger warrior mode
  Future<void> triggerWarriorMode() async {
    _currentLevel = MotivationLevel.warrior;
    notifyListeners();
    
    final warriorQuote = "Daud, warrior mode activated! Time to conquer your goals with unstoppable energy!";
    await speakMotivation(warriorQuote, isEnergetic: true);
  }

  // Get streak celebration message
  String getStreakCelebration(int streak, String habitName) {
    if (streak == 1) {
      return "Daud, great start with $habitName! Day 1 is always the hardest!";
    } else if (streak == 7) {
      return "One week of $habitName! You're building unstoppable momentum!";
    } else if (streak == 30) {
      return "30 days of $habitName! You've officially built a habit, champion!";
    } else if (streak == 100) {
      return "100 days of $habitName! You're in the elite 1% now, Daud!";
    } else if (streak % 10 == 0) {
      return "$streak days of $habitName! Your consistency is legendary!";
    } else {
      return "Day $streak of $habitName! Every day you're getting stronger!";
    }
  }

  // Dispose resources
  void dispose() {
    _dailyMotivationTimer?.cancel();
    _burnoutCheckTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}

enum MotivationLevel {
  burnout,
  calm,
  neutral,
  energetic,
  peak,
  warrior,
}

