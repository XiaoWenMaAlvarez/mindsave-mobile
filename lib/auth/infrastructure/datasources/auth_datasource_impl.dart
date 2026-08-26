import 'package:dio/dio.dart';
import 'package:mindsave/auth/domain/domain.dart';
import 'package:mindsave/auth/infrastructure/errors/auth_errors.dart';
import 'package:mindsave/config/constants/environment.dart';

class AuthDatasourceImpl extends AuthDatasource {
  late final Dio dio;

  AuthDatasourceImpl() {
    dio = Dio(BaseOptions(baseUrl: Environment.apiUrlBase));
  }

  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      final Response response = await dio.get(
        "/api/auth/check-status",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      final User user = User.fromObject(response.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw WrongCredentials();
      throw CustomError("Error de Dio desconocido", 1);
    } catch (e) {
      throw CustomError("Error desconocido", 2);
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post(
        "/api/auth/login",
        data: {"email": email, "password": password},
      );
      return User.fromObject(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) throw WrongCredentials();
      if (e.response?.statusCode == 401) throw EmailNotVerified();
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectionTimeout();
      }
      throw CustomError("Error de Dio desconocido", 1);
    } catch (e) {
      throw CustomError("Error que no es de Dio en la petición desconocido", 1);
    }
  }

  @override
  Future<String?> register(String email, String password, String name) async {
    final String defaultErrorMessage = "Error al crear usuario";
    try {
      final response = await dio.post(
        "/api/auth/register",
        data: {"email": email, "password": password, "name": name},
      );
      if (response.statusCode == 201) return null;
      return defaultErrorMessage;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return e.response?.data["error"] ?? defaultErrorMessage;
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        return "Conexión perdida";
      }
      return defaultErrorMessage;
    } catch (e) {
      return defaultErrorMessage;
    }
  }

  @override
  Future<String?> resetPassword(String email) async {
    final String defaultErrorMessage =
        "Error al intentar restablecer la contraseña";
    try {
      final response = await dio.post(
        "/api/auth/reset-password",
        data: {"email": email},
      );
      if (response.statusCode == 200) return null;
      return defaultErrorMessage;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return e.response?.data["error"] ?? defaultErrorMessage;
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        return "Conexión perdida";
      }
      return defaultErrorMessage;
    } catch (e) {
      return defaultErrorMessage;
    }
  }
}
