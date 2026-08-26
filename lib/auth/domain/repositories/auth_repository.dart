import 'package:mindsave/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<String?> register(String email, String password, String name);
  Future<User> checkAuthStatus(String token);
  Future<String?> resetPassword(String email);
}
