class Exercise {
  final String id;
  final String workoutId;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'workoutId': workoutId,
        'name': name,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'] ?? '',
        workoutId: map['workoutId'] ?? '',
        name: map['name'] ?? '',
        sets: map['sets'] ?? 0,
        reps: map['reps'] ?? 0,
        weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : DateTime.now(),
      );

  Exercise copyWith({String? name, int? sets, int? reps, double? weight}) =>
      Exercise(
        id: id,
        workoutId: workoutId,
        name: name ?? this.name,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        weight: weight ?? this.weight,
        createdAt: createdAt,
      );
}