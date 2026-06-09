import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _workoutsRef(String uid) =>
      _db.collection('users').doc(uid).collection('workouts');

  CollectionReference _exercisesRef(String uid, String workoutId) =>
      _db.collection('users').doc(uid).collection('workouts').doc(workoutId).collection('exercises');

  Future<void> addWorkout(String uid, Workout w) =>
      _workoutsRef(uid).doc(w.id).set(w.toMap());

  Future<void> updateWorkout(String uid, Workout w) =>
      _workoutsRef(uid).doc(w.id).update(w.toMap());

  Future<void> deleteWorkout(String uid, String workoutId) async {
    final exercises = await _exercisesRef(uid, workoutId).get();
    for (var doc in exercises.docs) { await doc.reference.delete(); }
    await _workoutsRef(uid).doc(workoutId).delete();
  }

  Future<void> markAsCompleted(String uid, String workoutId) =>
      _workoutsRef(uid).doc(workoutId).update({
        'completed': true,
        'completedAt': DateTime.now().toIso8601String(),
      });

  Future<void> resetWorkout(String uid, String workoutId) =>
      _workoutsRef(uid).doc(workoutId).update({'completed': false, 'completedAt': null});

  Stream<List<Workout>> getWorkouts(String uid) => _workoutsRef(uid)
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map((d) => Workout.fromMap(d.data() as Map<String, dynamic>)).toList());

  Stream<List<Workout>> getCompletedWorkouts(String uid) => _workoutsRef(uid)
      .where('completed', isEqualTo: true)
      .orderBy('completedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Workout.fromMap(d.data() as Map<String, dynamic>)).toList());

  Future<void> addExercise(String uid, String workoutId, Exercise e) =>
      _exercisesRef(uid, workoutId).doc(e.id).set(e.toMap());

  Future<void> updateExercise(String uid, String workoutId, Exercise e) =>
      _exercisesRef(uid, workoutId).doc(e.id).update(e.toMap());

  Future<void> deleteExercise(String uid, String workoutId, String exId) =>
      _exercisesRef(uid, workoutId).doc(exId).delete();

  Stream<List<Exercise>> getExercises(String uid, String workoutId) =>
      _exercisesRef(uid, workoutId)
          .orderBy('createdAt')
          .snapshots()
          .map((s) => s.docs.map((d) => Exercise.fromMap(d.data() as Map<String, dynamic>)).toList());
}