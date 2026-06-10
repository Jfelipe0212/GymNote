import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gymnote.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            passwordHash TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE workouts (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            name TEXT NOT NULL,
            dayOfWeek TEXT NOT NULL,
            goal TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            completedAt TEXT,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE exercises (
            id TEXT PRIMARY KEY,
            workoutId TEXT NOT NULL,
            name TEXT NOT NULL,
            sets INTEGER NOT NULL,
            reps INTEGER NOT NULL,
            weight REAL NOT NULL,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (workoutId) REFERENCES workouts(id)
          )
        ''');
      },
    );
  }

  // ─── Users ────────────────────────────────────────────────────────────────

  Future<void> insertUser(AppUser user) async {
    final db = await database;
    await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query('users',
        where: 'email = ?', whereArgs: [email], limit: 1);
    if (result.isEmpty) return null;
    return AppUser.fromMap(result.first);
  }

  Future<AppUser?> getUserById(String id) async {
    final db = await database;
    final result =
        await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return AppUser.fromMap(result.first);
  }

  // ─── Workouts ─────────────────────────────────────────────────────────────

  Future<void> addWorkout(String uid, Workout w) async {
    final db = await database;
    await db.insert('workouts', w.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateWorkout(String uid, Workout w) async {
    final db = await database;
    await db.update('workouts', w.toMap(),
        where: 'id = ?', whereArgs: [w.id]);
  }

  Future<void> deleteWorkout(String uid, String workoutId) async {
    final db = await database;
    await db.delete('exercises',
        where: 'workoutId = ?', whereArgs: [workoutId]);
    await db.delete('workouts', where: 'id = ?', whereArgs: [workoutId]);
  }

  Future<void> markAsCompleted(String uid, String workoutId) async {
    final db = await database;
    await db.update(
      'workouts',
      {
        'completed': 1,
        'completedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  Future<void> resetWorkout(String uid, String workoutId) async {
    final db = await database;
    await db.update(
      'workouts',
      {'completed': 0, 'completedAt': null},
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  Stream<List<Workout>> getWorkouts(String uid) async* {
    yield await _fetchWorkouts(uid);
  }

  Future<List<Workout>> _fetchWorkouts(String uid) async {
    final db = await database;
    final result = await db.query('workouts',
        where: 'userId = ?', whereArgs: [uid], orderBy: 'createdAt ASC');
    return result.map((e) => Workout.fromMap(e)).toList();
  }

  Stream<List<Workout>> getCompletedWorkouts(String uid) async* {
    yield await _fetchCompletedWorkouts(uid);
  }

  Future<List<Workout>> _fetchCompletedWorkouts(String uid) async {
    final db = await database;
    final result = await db.query('workouts',
        where: 'userId = ? AND completed = 1',
        whereArgs: [uid],
        orderBy: 'completedAt DESC');
    return result.map((e) => Workout.fromMap(e)).toList();
  }

  // ─── Exercises ────────────────────────────────────────────────────────────

  Future<void> addExercise(
      String uid, String workoutId, Exercise e) async {
    final db = await database;
    await db.insert('exercises', e.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateExercise(
      String uid, String workoutId, Exercise e) async {
    final db = await database;
    await db.update('exercises', e.toMap(),
        where: 'id = ?', whereArgs: [e.id]);
  }

  Future<void> deleteExercise(
      String uid, String workoutId, String exId) async {
    final db = await database;
    await db.delete('exercises', where: 'id = ?', whereArgs: [exId]);
  }

  Stream<List<Exercise>> getExercises(String uid, String workoutId) async* {
    yield await _fetchExercises(workoutId);
  }

  Future<List<Exercise>> _fetchExercises(String workoutId) async {
    final db = await database;
    final result = await db.query('exercises',
        where: 'workoutId = ?',
        whereArgs: [workoutId],
        orderBy: 'createdAt ASC');
    return result.map((e) => Exercise.fromMap(e)).toList();
  }
}
