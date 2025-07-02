import 'package:flutter/material.dart';
enum HabitType { power, struggle }

enum HabitFrequency { daily, weekly, monthly }

class Habit {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final HabitType type;
  final HabitFrequency frequency;
  final int targetCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 🔧 Added fields used in the UI
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final TimeOfDay? reminderTime;

  // 🔧 To satisfy `habit.title`
  String get title => name;

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
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.reminderTime,
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
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalCompletions': totalCompletions,
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    final reminder = json['reminderTime']?.split(':');
    TimeOfDay? parsedReminder;
    if (reminder != null && reminder.length == 2) {
      parsedReminder = TimeOfDay(
        hour: int.tryParse(reminder[0]) ?? 0,
        minute: int.tryParse(reminder[1]) ?? 0,
      );
    }

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
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalCompletions: json['totalCompletions'] ?? 0,
      reminderTime: parsedReminder,
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
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    TimeOfDay? reminderTime,
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
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
