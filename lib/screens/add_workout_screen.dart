import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../models/workout_model.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});
  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _day = 'Segunda', _goal = 'Hipertrofia';
  bool _loading = false;

  final _days = ['Segunda','Terça','Quarta','Quinta','Sexta','Sábado','Domingo'];
  final _goals = ['Hipertrofia','Resistência','Força','Emagrecimento','Condicionamento','Flexibilidade'];

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await DatabaseService().addWorkout(uid, Workout(
      id: const Uuid().v4(), userId: uid,
      name: _nameCtrl.text.trim(), dayOfWeek: _day, goal: _goal,
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(title: const Text('Novo Treino')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Nome do treino'),
            TextFormField(
              controller: _nameCtrl, style: const TextStyle(color: Colors.white),
              decoration: _dec('Ex: Peito e Tríceps'),
              validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 20),
            _label('Dia da semana'),
            _dropdown(_days, _day, (v) => setState(() => _day = v!)),
            const SizedBox(height: 20),
            _label('Objetivo'),
            _dropdown(_goals, _goal, (v) => setState(() => _goal = v!)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar Treino', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: const TextStyle(color: Colors.white54, fontSize: 13)));

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Colors.white38),
    filled: true, fillColor: const Color(0xFF2C2C2E),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange)),
  );

  Widget _dropdown(List<String> items, String value, void Function(String?) cb) =>
      DropdownButtonFormField<String>(
        value: value, onChanged: cb, dropdownColor: const Color(0xFF2C2C2E),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(filled: true, fillColor: const Color(0xFF2C2C2E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      );
}