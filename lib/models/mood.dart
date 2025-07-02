class Mood {
  final String id;
  final String userId;
  final int clarity; // 1-5 scale
  final int focus; // 1-5 scale
  final int energy; // 1-5 scale
  final String? notes;
  final DateTime timestamp;

  Mood({
    required this.id,
    required this.userId,
    required this.clarity,
    required this.focus,
    required this.energy,
    this.notes,
    required this.timestamp,
  });

  double get averageScore => (clarity + focus + energy) / 3.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'clarity': clarity,
      'focus': focus,
      'energy': energy,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'],
      userId: json['userId'],
      clarity: json['clarity'],
      focus: json['focus'],
      energy: json['energy'],
      notes: json['notes'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Mood copyWith({
    String? id,
    String? userId,
    int? clarity,
    int? focus,
    int? energy,
    String? notes,
    DateTime? timestamp,
  }) {
    return Mood(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clarity: clarity ?? this.clarity,
      focus: focus ?? this.focus,
      energy: energy ?? this.energy,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

