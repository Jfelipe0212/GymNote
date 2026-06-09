import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => user != null ? const MainScreen() : const LoginScreen(),
    ));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.fitness_center, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 24),
            const Text('FitLog', style: TextStyle(color: Colors.orange, fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Diário de Treinos Pessoal', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.orange),
          ]),
        ),
      ),
    );
  }
}