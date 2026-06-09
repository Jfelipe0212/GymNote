import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../models/exercise_model.dart';

class AddExerciseScreen extends StatefulWidget {
  final String workoutId;
  const AddExerciseScreen({super.key, required this.workoutId});
  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _setsCtrl = TextEditingController(text: '3');
  final _repsCtrl = TextEditingController(text: '12');
  final _weightCtrl = TextEditingController(text: '0');
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _setsCtrl.dispose();
    _repsCtrl.dispose(); _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await DatabaseService().addExercise(uid, widget.workoutId, Exercise(
      id: const Uuid().v4(), workoutId: widget.workoutId,
      name: _nameCtrl.text.trim(),
      sets: int.parse(_setsCtrl.text),
      reps: int.parse(_repsCtrl.text),
      weight: double.parse(_weightCtrl.text.replaceAll(',', '.')),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(title: const Text('Adicionar Exercício')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Nome do exercício'),
            TextFormField(
              controller: _nameCtrl, style: const TextStyle(color: Colors.white),
              decoration: _dec('Ex: Supino Reto'),
              validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Séries'),
                TextFormField(controller: _setsCtrl, style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number, decoration: _dec('3'),
                    validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Repetições'),
                TextFormField(controller: _repsCtrl, style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number, decoration: _dec('12'),
                    validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null),
              ])),
            ]),
            const SizedBox(height: 16),
            _label('Carga (kg)'),
            TextFormField(
              controller: _weightCtrl, style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _dec('Ex: 60'),
              validator: (v) => v == null || v.isEmpty ? 'Informe a carga' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar Exercício', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}