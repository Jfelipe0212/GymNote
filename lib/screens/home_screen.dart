import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../models/workout_model.dart';
import '../widgets/workout_card.dart';
import 'add_workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getDayName(int weekday) {
    const days = ['Segunda','Terça','Quarta','Quinta','Sexta','Sábado','Domingo'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = DatabaseService();
    final today = _getDayName(DateTime.now().weekday);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(title: const Text('FitLog'), automaticallyImplyLeading: false),
      body: StreamBuilder<List<Workout>>(
        stream: db.getWorkouts(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          final all = snapshot.data ?? [];
          final todayList = all.where((w) => w.dayOfWeek == today).toList();
          final completed = all.where((w) => w.completed).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Icon(Icons.wb_sunny, color: Colors.orange),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Bom treino!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(today, style: const TextStyle(color: Colors.white54)),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _stat('${all.length}', 'Total'),
                  _stat('$completed', 'Concluídos'),
                  _stat('${todayList.length}', 'Hoje'),
                ]),
              ),
              const SizedBox(height: 24),
              Text('Treinos de hoje ($today)',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (todayList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(16)),
                  child: const Column(children: [
                    Icon(Icons.beach_access, color: Colors.white38, size: 48),
                    SizedBox(height: 12),
                    Text('Nenhum treino para hoje!', style: TextStyle(color: Colors.white54)),
                  ]),
                )
              else
                ...todayList.map((w) => WorkoutCard(workout: w)),
            ],
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

  Widget _stat(String value, String label) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
  ]);
}