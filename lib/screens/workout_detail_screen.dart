import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../widgets/exercise_tile.dart';
import 'add_exercise_screen.dart';
import 'edit_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = DatabaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => EditWorkoutScreen(workout: workout))),
          ),
          IconButton(
            icon: Icon(workout.completed ? Icons.refresh : Icons.check_circle, color: Colors.green),
            onPressed: () async {
              workout.completed
                  ? await db.resetWorkout(uid, workout.id)
                  : await db.markAsCompleted(uid, workout.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Treino atualizado! 💪'), backgroundColor: Colors.green));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, db, uid),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _info('Dia', workout.dayOfWeek),
            _info('Objetivo', workout.goal),
            _info('Status', workout.completed ? 'Concluído' : 'Pendente'),
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<Exercise>>(
            stream: db.getExercises(uid, workout.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }
              final exercises = snapshot.data ?? [];
              if (exercises.isEmpty) {
                return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_circle_outline, color: Colors.white38, size: 48),
                  SizedBox(height: 12),
                  Text('Nenhum exercício adicionado.', style: TextStyle(color: Colors.white54)),
                ]));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: exercises.length,
                itemBuilder: (_, i) => ExerciseTile(exercise: exercises[i], workoutId: workout.id),
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AddExerciseScreen(workoutId: workout.id))),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _info(String label, String value) => Column(children: [
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
  ]);

  void _confirmDelete(BuildContext context, DatabaseService db, String uid) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF2C2C2E),
      title: const Text('Excluir treino', style: TextStyle(color: Colors.white)),
      content: const Text('Todos os exercícios serão removidos.', style: TextStyle(color: Colors.white54)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: () async {
            await db.deleteWorkout(uid, workout.id);
            if (context.mounted) { Navigator.pop(context); Navigator.pop(context); }
          },
          child: const Text('Excluir', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }
}