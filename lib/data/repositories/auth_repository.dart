import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import '../../domain/models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserModel?> login(String email, String password) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (users.isEmpty) {
      // Check if the email exists first
      final emailExists = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (emailExists.isEmpty) {
        throw Exception('User not found');
      } else {
        throw Exception('Incorrect password');
      }
    }

    final user = UserModel.fromJson(users.first);
    await _storage.write(key: 'user_id', value: user.id.toString());
    return user;
  }

  Future<UserModel> signup(String name, String email, String password) async {
    final db = await _db.database;
    // Check if email already exists
    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Email already exists');
    }

    final userData = {
      'name': name,
      'email': email,
      'password': password,
      'created_at': DateTime.now().toIso8601String(),
    };

    final id = await db.insert('users', userData);
    final user = UserModel.fromJson({...userData, 'id': id});
    await _storage.write(key: 'user_id', value: user.id.toString());
    return user;
  }

  Future<void> logout() async {
    try {
      // First clear secure storage
      await _storage.deleteAll();
      await _storage.delete(key: 'user_id');

      // Wait a bit to ensure all async operations complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Close and clear database
      final db = await _db.database;
      await db.close();

      // Reset database instance
      DatabaseHelper.resetDatabase();

      // Clear all user preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Wait a bit to ensure all async operations complete
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      // print('Error during logout: $e');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final userId = await _storage.read(key: 'user_id');
    if (userId == null) return null;

    final db = await _db.database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [int.parse(userId)],
    );

    if (users.isEmpty) return null;
    return UserModel.fromJson(users.first);
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    final db = await _db.database;
    final result = await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
    return result > 0;
  }
}
