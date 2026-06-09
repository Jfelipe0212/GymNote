class Workout {
  final String id;
  final String userId;
  final String name;
  final String dayOfWeek;
  final String goal;
  final bool completed;
  final DateTime? completedAt;
  final DateTime createdAt;

  Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.dayOfWeek,
    required this.goal,
    this.completed = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'dayOfWeek': dayOfWeek,
        'goal': goal,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Workout.fromMap(Map<String, dynamic> map) => Workout(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        name: map['name'] ?? '',
        dayOfWeek: map['dayOfWeek'] ?? '',
        goal: map['goal'] ?? '',
        completed: map['completed'] ?? false,
        completedAt: map['completedAt'] != null
            ? DateTime.parse(map['completedAt'])
            : null,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : DateTime.now(),
      );

  Workout copyWith({
    String? name,
    String? dayOfWeek,
    String? goal,
    bool? completed,
    DateTime? completedAt,
  }) =>
      Workout(
        id: id,
        userId: userId,
        name: name ?? this.name,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        goal: goal ?? this.goal,
        completed: completed ?? this.completed,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt,
      );
}