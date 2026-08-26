import 'package:prueba/auth/domain/domain.dart';

class AuthRepositoriesImpl extends AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoriesImpl(this.datasource);

  @override
  Future<User> checkAuthStatus(String token) {
    return datasource.checkAuthStatus(token);
  }

  @override
  Future<User> login(String email, String password) {
    return datasource.login(email, password);
  }

  @override
  Future<String?> register(String email, String password, String name) {
    return datasource.register(email, password, name);
  }

  @override
  Future<String?> resetPassword(String email) {
    return datasource.resetPassword(email);
  }
}
