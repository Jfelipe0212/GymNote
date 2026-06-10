import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/workout_model.dart';
import '../widgets/workout_card.dart';
import 'add_workout_screen.dart';

class MyWorkoutsScreen extends StatefulWidget {
  const MyWorkoutsScreen({super.key});
  @override
  State<MyWorkoutsScreen> createState() => _MyWorkoutsScreenState();
}

class _MyWorkoutsScreenState extends State<MyWorkoutsScreen> {
  List<Workout> _workouts = [];

  Future<void> _load() async {
    final uid = AuthService().currentUser!.id;
    final list = await DatabaseService().getWorkouts(uid).first;
    if (mounted) setState(() => _workouts = list);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
          title: const Text('Meus Treinos'),
          automaticallyImplyLeading: false),
      body: RefreshIndicator(
        onRefresh: _load,
        color: Colors.orange,
        child: _workouts.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center,
                              color: Colors.white38, size: 64),
                          SizedBox(height: 16),
                          Text('Nenhum treino criado ainda.',
                              style: TextStyle(color: Colors.white54)),
                          SizedBox(height: 8),
                          Text('Toque no + para adicionar!',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12)),
                        ]),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _workouts.length,
                itemBuilder: (_, i) => WorkoutCard(
                      workout: _workouts[i],
                      onRefresh: _load,
                    )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddWorkoutScreen()));
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
