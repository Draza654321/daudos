enum HabitType { power, struggle }

enum HabitFrequency { daily, weekly, monthly }

class Habit {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final HabitType type;
  final HabitFrequency frequency;
  final int targetCount; // e.g., 1 for daily, 7 for weekly
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.type,
    required this.frequency,
    required this.targetCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'type': type.name,
      'frequency': frequency.name,
      'targetCount': targetCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      type: HabitType.values.firstWhere((e) => e.name == json['type']),
      frequency: HabitFrequency.values.firstWhere((e) => e.name == json['frequency']),
      targetCount: json['targetCount'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    HabitType? type,
    HabitFrequency? frequency,
    int? targetCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      targetCount: targetCount ?? this.targetCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HabitEntry {
  final String id;
  final String habitId;
  final String userId;
  final DateTime date;
  final bool completed;
  final String? notes;
  final DateTime createdAt;

  HabitEntry({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.completed,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'userId': userId,
      'date': date.toIso8601String(),
      'completed': completed,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HabitEntry.fromJson(Map<String, dynamic> json) {
    return HabitEntry(
      id: json['id'],
      habitId: json['habitId'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      completed: json['completed'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  HabitEntry copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? date,
    bool? completed,
    String? notes,
    DateTime? createdAt,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

