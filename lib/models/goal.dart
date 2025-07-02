enum GoalStatus { active, completed, paused, cancelled }

enum GoalCategory { career, financial, health, skill, personal }

class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalCategory category;
  final GoalStatus status;
  final DateTime targetDate;
  final double progress; // 0.0 to 1.0
  final List<String> milestones;
  final List<bool> milestoneCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.targetDate,
    required this.progress,
    required this.milestones,
    required this.milestoneCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == GoalStatus.completed;
  bool get isOverdue => targetDate.isBefore(DateTime.now()) && !isCompleted;
  int get completedMilestones => milestoneCompleted.where((completed) => completed).length;
  double get milestoneProgress => milestones.isEmpty ? 0.0 : completedMilestones / milestones.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category.name,
      'status': status.name,
      'targetDate': targetDate.toIso8601String(),
      'progress': progress,
      'milestones': milestones,
      'milestoneCompleted': milestoneCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      category: GoalCategory.values.firstWhere((e) => e.name == json['category']),
      status: GoalStatus.values.firstWhere((e) => e.name == json['status']),
      targetDate: DateTime.parse(json['targetDate']),
      progress: json['progress'].toDouble(),
      milestones: List<String>.from(json['milestones']),
      milestoneCompleted: List<bool>.from(json['milestoneCompleted']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    GoalCategory? category,
    GoalStatus? status,
    DateTime? targetDate,
    double? progress,
    List<String>? milestones,
    List<bool>? milestoneCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      targetDate: targetDate ?? this.targetDate,
      progress: progress ?? this.progress,
      milestones: milestones ?? this.milestones,
      milestoneCompleted: milestoneCompleted ?? this.milestoneCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

