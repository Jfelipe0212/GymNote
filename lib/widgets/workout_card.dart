import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../screens/workout_detail_screen.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onRefresh;
  const WorkoutCard({super.key, required this.workout, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => WorkoutDetailScreen(workout: workout)));
        onRefresh?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: workout.completed
                  ? Colors.green.withOpacity(0.5)
                  : Colors.transparent),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.fitness_center, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(workout.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text('${workout.dayOfWeek} · ${workout.goal}',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ])),
          Icon(
              workout.completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: workout.completed ? Colors.green : Colors.red),
        ]),
      ),
    );
  }
}
