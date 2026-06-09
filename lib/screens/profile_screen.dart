import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/workout_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(title: const Text('Perfil'), automaticallyImplyLeading: false),
      body: StreamBuilder<List<Workout>>(
        stream: DatabaseService().getWorkouts(user.uid),
        builder: (context, snapshot) {
          final all = snapshot.data ?? [];
          final completed = all.where((w) => w.completed).length;

          return ListView(padding: const EdgeInsets.all(24), children: [
            Center(child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 12),
              Text(user.email ?? '—', style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Atleta FitLog', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ])),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(16)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _stat('${all.length}', 'Criados'),
                _stat('$completed', 'Concluídos'),
                _stat('${all.length - completed}', 'Pendentes'),
              ]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Sair', style: TextStyle(color: Colors.red, fontSize: 16)),
                onPressed: () => _confirmLogout(context),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _stat(String value, String label) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
  ]);

  void _confirmLogout(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF2C2C2E),
      title: const Text('Sair', style: TextStyle(color: Colors.white)),
      content: const Text('Deseja sair da conta?', style: TextStyle(color: Colors.white54)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: () async {
            await AuthService().logout();
            if (context.mounted) Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
          },
          child: const Text('Sair', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }
}