import 'package:prueba/auth/domain/entities/user.dart';

abstract class AuthDatasource {
  Future<User> login(String email, String password);
  Future<String?> register(String email, String password, String name);
  Future<User> checkAuthStatus(String token);
  Future<String?> resetPassword(String email);
}
