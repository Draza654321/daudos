class User {
  final String id;
  final String name;
  final String workStartTime; // e.g., "18:00" for 6 PM PKT
  final String workEndTime; // e.g., "06:00" for 6 AM PKT
  final String timezone; // e.g., "Asia/Karachi"
  final double monthlyIncomeGoal; // USD
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.workStartTime,
    required this.workEndTime,
    required this.timezone,
    required this.monthlyIncomeGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'workStartTime': workStartTime,
      'workEndTime': workEndTime,
      'timezone': timezone,
      'monthlyIncomeGoal': monthlyIncomeGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      workStartTime: json['workStartTime'],
      workEndTime: json['workEndTime'],
      timezone: json['timezone'],
      monthlyIncomeGoal: json['monthlyIncomeGoal'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? workStartTime,
    String? workEndTime,
    String? timezone,
    double? monthlyIncomeGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      timezone: timezone ?? this.timezone,
      monthlyIncomeGoal: monthlyIncomeGoal ?? this.monthlyIncomeGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

