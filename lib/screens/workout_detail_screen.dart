import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../widgets/exercise_tile.dart';
import 'add_exercise_screen.dart';
import 'edit_workout_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});
  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late Workout _workout;
  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final uid = AuthService().currentUser!.id;
    final list =
        await DatabaseService().getExercises(uid, _workout.id).first;
    if (mounted) setState(() => _exercises = list);
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser!.id;
    final db = DatabaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: Text(_workout.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          EditWorkoutScreen(workout: _workout)));
              // Reload workout data
              final workouts =
                  await db.getWorkouts(uid).first;
              final updated =
                  workouts.where((w) => w.id == _workout.id).firstOrNull;
              if (updated != null && mounted) {
                setState(() => _workout = updated);
              }
            },
          ),
          IconButton(
            icon: Icon(
                _workout.completed ? Icons.refresh : Icons.check_circle,
                color: Colors.green),
            onPressed: () async {
              _workout.completed
                  ? await db.resetWorkout(uid, _workout.id)
                  : await db.markAsCompleted(uid, _workout.id);
              final workouts = await db.getWorkouts(uid).first;
              final updated =
                  workouts.where((w) => w.id == _workout.id).firstOrNull;
              if (updated != null && mounted) {
                setState(() => _workout = updated);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Treino atualizado! 💪'),
                    backgroundColor: Colors.green));
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
          decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _info('Dia', _workout.dayOfWeek),
            _info('Objetivo', _workout.goal),
            _info('Status', _workout.completed ? 'Concluído' : 'Pendente'),
          ]),
        ),
        Expanded(
          child: _exercises.isEmpty
              ? const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.add_circle_outline,
                          color: Colors.white38, size: 48),
                      SizedBox(height: 12),
                      Text('Nenhum exercício adicionado.',
                          style: TextStyle(color: Colors.white54)),
                    ]))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _exercises.length,
                  itemBuilder: (_, i) => ExerciseTile(
                        exercise: _exercises[i],
                        workoutId: _workout.id,
                        onDeleted: _loadExercises,
                      ),
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AddExerciseScreen(workoutId: _workout.id)));
          _loadExercises();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _info(String label, String value) => Column(children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.orange, fontWeight: FontWeight.bold)),
      ]);

  void _confirmDelete(
      BuildContext context, DatabaseService db, String uid) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: const Color(0xFF2C2C2E),
              title: const Text('Excluir treino',
                  style: TextStyle(color: Colors.white)),
              content: const Text('Todos os exercícios serão removidos.',
                  style: TextStyle(color: Colors.white54)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                TextButton(
                  onPressed: () async {
                    await db.deleteWorkout(uid, _workout.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Excluir',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ));
  }
}
