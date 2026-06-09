import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise_model.dart';
import '../services/database_service.dart';

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final String workoutId;
  const ExerciseTile({super.key, required this.exercise, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(exercise.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(children: [
            _chip('${exercise.sets}x', Icons.repeat),
            const SizedBox(width: 8),
            _chip('${exercise.reps} reps', Icons.fitness_center),
            const SizedBox(width: 8),
            _chip('${exercise.weight}kg', Icons.monitor_weight),
          ]),
        ])),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            DatabaseService().deleteExercise(uid, workoutId, exercise.id);
          },
        ),
      ]),
    );
  }

  Widget _chip(String label, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
    child: Row(children: [
      Icon(icon, color: Colors.orange, size: 12),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.orange, fontSize: 11)),
    ]),
  );
}