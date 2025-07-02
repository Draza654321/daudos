enum MindGymActivity {
  breathing,
  brainDump,
  clearIntention,
  focusBuilder,
  clarityChallenge,
  learningSprint,
  coolDown,
  weeklyReset
}

class MindGymSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<MindGymActivity> completedActivities;
  final Map<MindGymActivity, int> activityDurations; // in minutes
  final String? notes;
  final int? overallRating; // 1-5 scale
  final DateTime createdAt;

  MindGymSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.completedActivities,
    required this.activityDurations,
    this.notes,
    this.overallRating,
    required this.createdAt,
  });

  int get totalDuration {
    if (endTime != null) {
      return endTime!.difference(startTime).inMinutes;
    }
    return activityDurations.values.fold(0, (sum, duration) => sum + duration);
  }

  bool get isCompleted => endTime != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'completedActivities': completedActivities.map((a) => a.name).toList(),
      'activityDurations': activityDurations.map((k, v) => MapEntry(k.name, v)),
      'notes': notes,
      'overallRating': overallRating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MindGymSession.fromJson(Map<String, dynamic> json) {
    return MindGymSession(
      id: json['id'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      completedActivities: (json['completedActivities'] as List)
          .map((a) => MindGymActivity.values.firstWhere((e) => e.name == a))
          .toList(),
      activityDurations: (json['activityDurations'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(
              MindGymActivity.values.firstWhere((e) => e.name == k), v as int)),
      notes: json['notes'],
      overallRating: json['overallRating'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  MindGymSession copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    List<MindGymActivity>? completedActivities,
    Map<MindGymActivity, int>? activityDurations,
    String? notes,
    int? overallRating,
    DateTime? createdAt,
  }) {
    return MindGymSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completedActivities: completedActivities ?? this.completedActivities,
      activityDurations: activityDurations ?? this.activityDurations,
      notes: notes ?? this.notes,
      overallRating: overallRating ?? this.overallRating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BrainDumpEntry {
  final String id;
  final String userId;
  final String content;
  final List<String> emotionTags;
  final DateTime timestamp;

  BrainDumpEntry({
    required this.id,
    required this.userId,
    required this.content,
    required this.emotionTags,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'emotionTags': emotionTags,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BrainDumpEntry.fromJson(Map<String, dynamic> json) {
    return BrainDumpEntry(
      id: json['id'],
      userId: json['userId'],
      content: json['content'],
      emotionTags: List<String>.from(json['emotionTags']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  BrainDumpEntry copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? emotionTags,
    DateTime? timestamp,
  }) {
    return BrainDumpEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      emotionTags: emotionTags ?? this.emotionTags,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

