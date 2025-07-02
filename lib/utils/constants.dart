import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'DaudOS';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Personal productivity system for Daud Raza';
  
  // User Information
  static const String userName = 'Daud Raza';
  static const String userTitle = 'Self-Taught Entrepreneur';
  static const String workSchedule = 'U.S. Dispatch Hours: 6 PM - 6 AM PKT';
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 50.0;
  
  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
  
  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Font Sizes
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 24.0;
  static const double fontTitle = 28.0;
  static const double fontDisplay = 32.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 600);
  
  // Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple
  static const Color accentColor = Color(0xFF06B6D4); // Cyan
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color infoColor = Color(0xFF3B82F6); // Blue
  
  // Mood Colors
  static const Color moodExcellent = Color(0xFF10B981); // Green
  static const Color moodGood = Color(0xFF06B6D4); // Cyan
  static const Color moodAverage = Color(0xFFF59E0B); // Amber
  static const Color moodPoor = Color(0xFFEF4444); // Red
  static const Color moodTerrible = Color(0xFF7C2D12); // Dark Red
  
  // Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444); // Red
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber
  static const Color priorityLow = Color(0xFF10B981); // Green
  
  // Category Colors
  static const Color categoryWork = Color(0xFF3B82F6); // Blue
  static const Color categoryPersonal = Color(0xFF8B5CF6); // Purple
  static const Color categoryHealth = Color(0xFF10B981); // Green
  static const Color categoryLearning = Color(0xFF06B6D4); // Cyan
  static const Color categoryFinance = Color(0xFFF59E0B); // Amber
  static const Color categorySocial = Color(0xFFEC4899); // Pink
  static const Color categoryCreative = Color(0xFF8B5CF6); // Purple
  static const Color categoryMaintenance = Color(0xFF6B7280); // Gray
  
  // Gradient Colors
  static const List<Color> gradientPrimary = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];
  
  static const List<Color> gradientSecondary = [
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
  ];
  
  static const List<Color> gradientSuccess = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];
  
  static const List<Color> gradientWarning = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];
  
  static const List<Color> gradientError = [
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];
  
  // UI Mode Colors
  static const Map<String, List<Color>> uiModeGradients = {
    'warrior': [Color(0xFFEF4444), Color(0xFFDC2626)], // Red gradient
    'clarity': [Color(0xFF06B6D4), Color(0xFF0891B2)], // Cyan gradient
    'dark': [Color(0xFF1F2937), Color(0xFF111827)], // Dark gradient
    'light': [Color(0xFFF9FAFB), Color(0xFFF3F4F6)], // Light gradient
  };
  
  // Motivational Quotes
  static const List<String> motivationalQuotes = [
    "Daud, this is your 1% moment - every small step builds your empire!",
    "The dispatch hours are your power hours - own the night, build your future!",
    "Self-taught doesn't mean self-limited - you're writing your own success story!",
    "Every challenge tonight is building the entrepreneur you're becoming!",
    "Your dedication during these hours separates you from the rest!",
    "The grind never stops, but neither does your growth - keep pushing!",
    "You're not just working a job, you're funding your dreams!",
    "Each task completed is a step closer to your breakthrough!",
    "The world sleeps while you build - that's the entrepreneur advantage!",
    "Your future self is counting on the work you do right now!",
  ];
  
  // Time-based Quotes
  static const Map<String, List<String>> timeBasedQuotes = {
    'evening': [
      "Evening energy activated! Time to dominate these dispatch hours!",
      "The night shift begins - your empire-building time starts now!",
      "Fresh start, focused mind - let's make this evening count!",
    ],
    'night': [
      "Deep in the grind - this is where legends are made!",
      "While others sleep, you're building your future!",
      "Night warrior mode: activated. Keep pushing forward!",
    ],
    'lateNight': [
      "The late hours test your dedication - you're passing with flying colors!",
      "This is the time that separates dreamers from achievers!",
      "Your commitment to excellence shines brightest in these hours!",
    ],
    'earlyMorning': [
      "Final stretch of the night - finish strong!",
      "The dawn approaches, and so does your success!",
      "You've conquered another night - that's the entrepreneur spirit!",
    ],
  };
  
  // Default Values
  static const int defaultFocusMinutes = 25;
  static const int defaultBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
  static const int defaultPomodoroSessions = 4;
  
  // Habit Frequencies
  static const List<String> habitFrequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Custom',
  ];
  
  // Task Categories
  static const List<String> taskCategories = [
    'Work',
    'Personal',
    'Health',
    'Learning',
    'Finance',
    'Social',
    'Creative',
    'Maintenance',
  ];
  
  // Goal Categories
  static const List<String> goalCategories = [
    'Health',
    'Finance',
    'Career',
    'Learning',
    'Personal',
    'Relationships',
    'Spiritual',
    'Adventure',
  ];
  
  // Emotion Tags
  static const List<String> emotionTags = [
    'Happy',
    'Excited',
    'Calm',
    'Focused',
    'Motivated',
    'Grateful',
    'Confident',
    'Energetic',
    'Peaceful',
    'Optimistic',
    'Sad',
    'Anxious',
    'Stressed',
    'Frustrated',
    'Tired',
    'Overwhelmed',
    'Angry',
    'Worried',
    'Lonely',
    'Confused',
  ];
  
  // Achievement Levels
  static const Map<int, String> achievementLevels = {
    0: 'Beginner',
    100: 'Novice',
    250: 'Apprentice',
    500: 'Skilled',
    1000: 'Expert',
    2000: 'Master',
    5000: 'Grandmaster',
    10000: 'Legend',
  };
  
  // Streak Milestones
  static const List<int> streakMilestones = [
    3, 7, 14, 21, 30, 60, 90, 180, 365
  ];
  
  // App Settings Keys
  static const String keyUIMode = 'ui_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyHabitReminders = 'habit_reminders';
  static const String keyMotivationalQuotes = 'motivational_quotes';
  static const String keyAppLockEnabled = 'app_lock_enabled';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyAutoSyncEnabled = 'auto_sync_enabled';
  static const String keyDarkModeEnabled = 'dark_mode_enabled';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyUserName = 'user_name';
  static const String keyWorkSchedule = 'work_schedule';
  
  // Database Tables
  static const String tableMoods = 'moods';
  static const String tableTasks = 'tasks';
  static const String tableHabits = 'habits';
  static const String tableGoals = 'goals';
  static const String tableMindGym = 'mind_gym_sessions';
  static const String tableSettings = 'settings';
  static const String tableAnalytics = 'analytics';
  
  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.daudos.com';
  static const String syncEndpoint = '/sync';
  static const String backupEndpoint = '/backup';
  static const String analyticsEndpoint = '/analytics';
  
  // File Paths
  static const String assetsPath = 'assets/';
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String animationsPath = 'assets/animations/';
  static const String audioPath = 'assets/audio/';
  static const String fontsPath = 'assets/fonts/';
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 500;
  static const int maxGoalTitleLength = 100;
  static const int maxGoalDescriptionLength = 1000;
  static const int maxHabitNameLength = 50;
  static const int maxBrainDumpLength = 2000;
  
  // Performance Thresholds
  static const double excellentPerformance = 0.9;
  static const double goodPerformance = 0.7;
  static const double averagePerformance = 0.5;
  static const double poorPerformance = 0.3;
  
  // Burnout Detection Thresholds
  static const double highBurnoutThreshold = 0.7;
  static const double mediumBurnoutThreshold = 0.4;
  static const double lowBurnoutThreshold = 0.2;
  
  // Focus Session Durations
  static const List<int> focusDurations = [15, 25, 30, 45, 60, 90];
  
  // Break Durations
  static const List<int> breakDurations = [5, 10, 15, 20, 30];
  
  // Notification Channels
  static const String channelHabits = 'habit_reminders';
  static const String channelTasks = 'task_reminders';
  static const String channelMotivation = 'motivation';
  static const String channelBreaks = 'break_reminders';
  
  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorSync = 'Sync failed. Your data is safe locally.';
  static const String errorAuth = 'Authentication failed. Please try again.';
  static const String errorValidation = 'Please check your input and try again.';
  
  // Success Messages
  static const String successTaskCompleted = 'Task completed! Great job!';
  static const String successHabitCompleted = 'Habit completed! Keep the streak going!';
  static const String successGoalAchieved = 'Goal achieved! You\'re unstoppable!';
  static const String successDataSynced = 'Data synced successfully!';
  static const String successBackupCreated = 'Backup created successfully!';
  
  // Helper Methods
  static Color getMoodColor(double moodScore) {
    if (moodScore >= 4.5) return moodExcellent;
    if (moodScore >= 3.5) return moodGood;
    if (moodScore >= 2.5) return moodAverage;
    if (moodScore >= 1.5) return moodPoor;
    return moodTerrible;
  }
  
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return priorityMedium;
    }
  }
  
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return categoryWork;
      case 'personal':
        return categoryPersonal;
      case 'health':
        return categoryHealth;
      case 'learning':
        return categoryLearning;
      case 'finance':
        return categoryFinance;
      case 'social':
        return categorySocial;
      case 'creative':
        return categoryCreative;
      case 'maintenance':
        return categoryMaintenance;
      default:
        return primaryColor;
    }
  }
  
  static String getPerformanceLabel(double score) {
    if (score >= excellentPerformance) return 'Excellent';
    if (score >= goodPerformance) return 'Good';
    if (score >= averagePerformance) return 'Average';
    if (score >= poorPerformance) return 'Poor';
    return 'Needs Improvement';
  }
  
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 18 || hour < 6) {
      // Dispatch hours (6 PM - 6 AM PKT)
      if (hour >= 18 && hour < 22) return 'Good evening, Daud!';
      if (hour >= 22 || hour < 2) return 'Night shift warrior!';
      if (hour >= 2 && hour < 6) return 'Late night grinder!';
    }
    // Rest hours
    if (hour >= 6 && hour < 12) return 'Good morning, Daud!';
    if (hour >= 12 && hour < 18) return 'Good afternoon, Daud!';
    return 'Hello, Daud!';
  }
  
  static bool isDispatchHours() {
    final hour = DateTime.now().hour;
    return hour >= 18 || hour < 6;
  }
  
  static String formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
  
  static String formatStreak(int days) {
    if (days == 0) return 'Start your streak!';
    if (days == 1) return '1 day streak';
    if (days < 7) return '$days days streak';
    if (days < 30) return '${(days / 7).floor()} weeks streak';
    if (days < 365) return '${(days / 30).floor()} months streak';
    return '${(days / 365).floor()} years streak';
  }
}

