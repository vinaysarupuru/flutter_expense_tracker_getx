import 'package:flutter_expense_tracker_getx/data/repositories/auth_repository.dart';
import 'package:flutter_expense_tracker_getx/domain/models/user_model.dart';

class MockAuthRepository extends AuthRepository {
  @override
  Future<UserModel?> login(String email, String password) async {
    // Mock successful login
    return UserModel(
      id: 1,
      name: 'John Doe',
      email: email,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> signup(String email, String password, String name) async {
    // Mock successful signup
    return UserModel(
      id: 1,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {
    // Mock successful logout
  }
}