import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../models/workout_model.dart';
import '../widgets/workout_card.dart';
import 'add_workout_screen.dart';

class MyWorkoutsScreen extends StatelessWidget {
  const MyWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(title: const Text('Meus Treinos'), automaticallyImplyLeading: false),
      body: StreamBuilder<List<Workout>>(
        stream: DatabaseService().getWorkouts(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          final workouts = snapshot.data ?? [];
          if (workouts.isEmpty) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.fitness_center, color: Colors.white38, size: 64),
              SizedBox(height: 16),
              Text('Nenhum treino criado ainda.', style: TextStyle(color: Colors.white54)),
              SizedBox(height: 8),
              Text('Toque no + para adicionar!', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (_, i) => WorkoutCard(workout: workouts[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddWorkoutScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}