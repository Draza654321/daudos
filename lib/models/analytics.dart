class DailyAnalytics {
  final String id;
  final String userId;
  final DateTime date;
  final int tasksCompleted;
  final int tasksTotal;
  final int habitsCompleted;
  final int habitsTotal;
  final int mindGymMinutes;
  final double averageMoodScore;
  final double incomeProgress; // percentage of monthly goal
  final int streakDays;
  final DateTime createdAt;

  DailyAnalytics({
    required this.id,
    required this.userId,
    required this.date,
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.habitsCompleted,
    required this.habitsTotal,
    required this.mindGymMinutes,
    required this.averageMoodScore,
    required this.incomeProgress,
    required this.streakDays,
    required this.createdAt,
  });

  double get taskCompletionRate => tasksTotal > 0 ? tasksCompleted / tasksTotal : 0.0;
  double get habitCompletionRate => habitsTotal > 0 ? habitsCompleted / habitsTotal : 0.0;
  double get overallScore => (taskCompletionRate + habitCompletionRate + (averageMoodScore / 5.0)) / 3.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'tasksCompleted': tasksCompleted,
      'tasksTotal': tasksTotal,
      'habitsCompleted': habitsCompleted,
      'habitsTotal': habitsTotal,
      'mindGymMinutes': mindGymMinutes,
      'averageMoodScore': averageMoodScore,
      'incomeProgress': incomeProgress,
      'streakDays': streakDays,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DailyAnalytics.fromJson(Map<String, dynamic> json) {
    return DailyAnalytics(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      tasksCompleted: json['tasksCompleted'],
      tasksTotal: json['tasksTotal'],
      habitsCompleted: json['habitsCompleted'],
      habitsTotal: json['habitsTotal'],
      mindGymMinutes: json['mindGymMinutes'],
      averageMoodScore: json['averageMoodScore'].toDouble(),
      incomeProgress: json['incomeProgress'].toDouble(),
      streakDays: json['streakDays'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  DailyAnalytics copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? tasksCompleted,
    int? tasksTotal,
    int? habitsCompleted,
    int? habitsTotal,
    int? mindGymMinutes,
    double? averageMoodScore,
    double? incomeProgress,
    int? streakDays,
    DateTime? createdAt,
  }) {
    return DailyAnalytics(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      tasksTotal: tasksTotal ?? this.tasksTotal,
      habitsCompleted: habitsCompleted ?? this.habitsCompleted,
      habitsTotal: habitsTotal ?? this.habitsTotal,
      mindGymMinutes: mindGymMinutes ?? this.mindGymMinutes,
      averageMoodScore: averageMoodScore ?? this.averageMoodScore,
      incomeProgress: incomeProgress ?? this.incomeProgress,
      streakDays: streakDays ?? this.streakDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class WeeklyReport {
  final String id;
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<DailyAnalytics> dailyData;
  final double averageTaskCompletion;
  final double averageHabitCompletion;
  final double averageMoodScore;
  final int totalMindGymMinutes;
  final int longestStreak;
  final List<String> achievements;
  final List<String> improvements;
  final DateTime createdAt;

  WeeklyReport({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.dailyData,
    required this.averageTaskCompletion,
    required this.averageHabitCompletion,
    required this.averageMoodScore,
    required this.totalMindGymMinutes,
    required this.longestStreak,
    required this.achievements,
    required this.improvements,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'dailyData': dailyData.map((d) => d.toJson()).toList(),
      'averageTaskCompletion': averageTaskCompletion,
      'averageHabitCompletion': averageHabitCompletion,
      'averageMoodScore': averageMoodScore,
      'totalMindGymMinutes': totalMindGymMinutes,
      'longestStreak': longestStreak,
      'achievements': achievements,
      'improvements': improvements,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    return WeeklyReport(
      id: json['id'],
      userId: json['userId'],
      weekStart: DateTime.parse(json['weekStart']),
      weekEnd: DateTime.parse(json['weekEnd']),
      dailyData: (json['dailyData'] as List)
          .map((d) => DailyAnalytics.fromJson(d))
          .toList(),
      averageTaskCompletion: json['averageTaskCompletion'].toDouble(),
      averageHabitCompletion: json['averageHabitCompletion'].toDouble(),
      averageMoodScore: json['averageMoodScore'].toDouble(),
      totalMindGymMinutes: json['totalMindGymMinutes'],
      longestStreak: json['longestStreak'],
      achievements: List<String>.from(json['achievements']),
      improvements: List<String>.from(json['improvements']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}


class WeeklyAnalytics {
  final String id;
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final double productivityScore;
  final double consistencyScore;
  final double wellBeingScore;
  final int totalTasks;
  final int completedTasks;
  final int totalHabits;
  final int completedHabits;
  final int mindGymSessions;
  final int totalMindGymMinutes;
  final double averageEnergy;
  final double averageFocus;
  final double averageClarity;
  final List<String> topAchievements;
  final List<String> improvementAreas;
  final DateTime createdAt;

  WeeklyAnalytics({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.productivityScore,
    required this.consistencyScore,
    required this.wellBeingScore,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalHabits,
    required this.completedHabits,
    required this.mindGymSessions,
    required this.totalMindGymMinutes,
    required this.averageEnergy,
    required this.averageFocus,
    required this.averageClarity,
    required this.topAchievements,
    required this.improvementAreas,
    required this.createdAt,
  });

  double get taskCompletionRate => totalTasks > 0 ? completedTasks / totalTasks : 0.0;
  double get habitCompletionRate => totalHabits > 0 ? completedHabits / totalHabits : 0.0;
  double get overallScore => (productivityScore + consistencyScore + wellBeingScore) / 3.0;
  
  // Getter properties for compatibility with UI widgets
  DateTime get weekStartDate => weekStart;
  double get overallPerformance => overallScore;
  double get totalFocusHours => totalMindGymMinutes / 60.0;
  double get averageMood => (averageEnergy + averageFocus + averageClarity) / 3.0;
  List<String> get achievements => topAchievements;
  List<String> get areasForImprovement => improvementAreas;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'productivityScore': productivityScore,
      'consistencyScore': consistencyScore,
      'wellBeingScore': wellBeingScore,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'mindGymSessions': mindGymSessions,
      'totalMindGymMinutes': totalMindGymMinutes,
      'averageEnergy': averageEnergy,
      'averageFocus': averageFocus,
      'averageClarity': averageClarity,
      'topAchievements': topAchievements,
      'improvementAreas': improvementAreas,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WeeklyAnalytics.fromJson(Map<String, dynamic> json) {
    return WeeklyAnalytics(
      id: json['id'],
      userId: json['userId'],
      weekStart: DateTime.parse(json['weekStart']),
      weekEnd: DateTime.parse(json['weekEnd']),
      productivityScore: json['productivityScore'].toDouble(),
      consistencyScore: json['consistencyScore'].toDouble(),
      wellBeingScore: json['wellBeingScore'].toDouble(),
      totalTasks: json['totalTasks'],
      completedTasks: json['completedTasks'],
      totalHabits: json['totalHabits'],
      completedHabits: json['completedHabits'],
      mindGymSessions: json['mindGymSessions'],
      totalMindGymMinutes: json['totalMindGymMinutes'],
      averageEnergy: json['averageEnergy'].toDouble(),
      averageFocus: json['averageFocus'].toDouble(),
      averageClarity: json['averageClarity'].toDouble(),
      topAchievements: List<String>.from(json['topAchievements']),
      improvementAreas: List<String>.from(json['improvementAreas']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MonthlyAnalytics {
  final String id;
  final String userId;
  final DateTime monthStart;
  final DateTime monthEnd;
  final double overallGrowth;
  final double productivityTrend;
  final double wellBeingTrend;
  final int totalGoalsSet;
  final int goalsAchieved;
  final int longestStreak;
  final double incomeProgress;
  final List<WeeklyAnalytics> weeklyData;
  final List<String> majorAchievements;
  final List<String> nextMonthFocus;
  final DateTime createdAt;

  MonthlyAnalytics({
    required this.id,
    required this.userId,
    required this.monthStart,
    required this.monthEnd,
    required this.overallGrowth,
    required this.productivityTrend,
    required this.wellBeingTrend,
    required this.totalGoalsSet,
    required this.goalsAchieved,
    required this.longestStreak,
    required this.incomeProgress,
    required this.weeklyData,
    required this.majorAchievements,
    required this.nextMonthFocus,
    required this.createdAt,
  });

  double get goalAchievementRate => totalGoalsSet > 0 ? goalsAchieved / totalGoalsSet : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'monthStart': monthStart.toIso8601String(),
      'monthEnd': monthEnd.toIso8601String(),
      'overallGrowth': overallGrowth,
      'productivityTrend': productivityTrend,
      'wellBeingTrend': wellBeingTrend,
      'totalGoalsSet': totalGoalsSet,
      'goalsAchieved': goalsAchieved,
      'longestStreak': longestStreak,
      'incomeProgress': incomeProgress,
      'weeklyData': weeklyData.map((w) => w.toJson()).toList(),
      'majorAchievements': majorAchievements,
      'nextMonthFocus': nextMonthFocus,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MonthlyAnalytics.fromJson(Map<String, dynamic> json) {
    return MonthlyAnalytics(
      id: json['id'],
      userId: json['userId'],
      monthStart: DateTime.parse(json['monthStart']),
      monthEnd: DateTime.parse(json['monthEnd']),
      overallGrowth: json['overallGrowth'].toDouble(),
      productivityTrend: json['productivityTrend'].toDouble(),
      wellBeingTrend: json['wellBeingTrend'].toDouble(),
      totalGoalsSet: json['totalGoalsSet'],
      goalsAchieved: json['goalsAchieved'],
      longestStreak: json['longestStreak'],
      incomeProgress: json['incomeProgress'].toDouble(),
      weeklyData: (json['weeklyData'] as List)
          .map((w) => WeeklyAnalytics.fromJson(w))
          .toList(),
      majorAchievements: List<String>.from(json['majorAchievements']),
      nextMonthFocus: List<String>.from(json['nextMonthFocus']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

