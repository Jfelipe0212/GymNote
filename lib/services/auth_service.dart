import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static const _keyUserId = 'current_user_id';
  static AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    if (userId != null) {
      _currentUser = await DatabaseService().getUserById(userId);
    }
  }

  Future<AppUser> login(
      {required String email, required String password}) async {
    final user = await DatabaseService().getUserByEmail(email.trim());
    if (user == null) {
      throw AuthException('user-not-found');
    }
    if (user.passwordHash != _hashPassword(password)) {
      throw AuthException('wrong-password');
    }
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    return user;
  }

  Future<AppUser> register(
      {required String email, required String password}) async {
    final existing =
        await DatabaseService().getUserByEmail(email.trim());
    if (existing != null) {
      throw AuthException('email-already-in-use');
    }
    if (password.length < 6) {
      throw AuthException('weak-password');
    }
    final user = AppUser(
      id: const Uuid().v4(),
      email: email.trim(),
      passwordHash: _hashPassword(password),
    );
    await DatabaseService().insertUser(user);
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'E-mail já cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca. Use ao menos 6 caracteres.';
      case 'invalid-email':
        return 'E-mail inválido.';
      default:
        return 'Erro desconhecido. Tente novamente.';
    }
  }
}

class AuthException implements Exception {
  final String code;
  AuthException(this.code);
}
