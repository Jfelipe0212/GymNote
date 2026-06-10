import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/workout_model.dart';
import '../widgets/workout_card.dart';
import 'add_workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Workout> _workouts = [];

  String _getDayName(int weekday) {
    const days = [
      'Segunda', 'Terça', 'Quarta', 'Quinta',
      'Sexta', 'Sábado', 'Domingo'
    ];
    return days[weekday - 1];
  }

  Future<void> _load() async {
    final uid = AuthService().currentUser!.id;
    final list = await DatabaseService()
        .getWorkouts(uid)
        .first;
    if (mounted) setState(() => _workouts = list);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final today = _getDayName(DateTime.now().weekday);
    final todayList = _workouts.where((w) => w.dayOfWeek == today).toList();
    final completed = _workouts.where((w) => w.completed).length;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
          title: const Text('GymNote'),
          automaticallyImplyLeading: false),
      body: RefreshIndicator(
        onRefresh: _load,
        color: Colors.orange,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.wb_sunny, color: Colors.orange),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Bom treino!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(today,
                      style: const TextStyle(color: Colors.white54)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('${_workouts.length}', 'Total'),
                    _stat('$completed', 'Concluídos'),
                    _stat('${todayList.length}', 'Hoje'),
                  ]),
            ),
            const SizedBox(height: 24),
            Text('Treinos de hoje ($today)',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (todayList.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(16)),
                child: const Column(children: [
                  Icon(Icons.beach_access, color: Colors.white38, size: 48),
                  SizedBox(height: 12),
                  Text('Nenhum treino para hoje!',
                      style: TextStyle(color: Colors.white54)),
                ]),
              )
            else
              ...todayList.map((w) => WorkoutCard(
                    workout: w,
                    onRefresh: _load,
                  )),
          ],
        ),
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

  Widget _stat(String value, String label) => Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.orange,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ]);
}
