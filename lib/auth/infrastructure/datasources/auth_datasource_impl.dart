import 'package:dio/dio.dart';
import 'package:mindsave/auth/domain/domain.dart';
import 'package:mindsave/auth/infrastructure/errors/auth_errors.dart';
import 'package:mindsave/config/constants/environment.dart';

class AuthDatasourceImpl extends AuthDatasource {
  late final Dio dio;

  AuthDatasourceImpl() {
    dio = Dio(BaseOptions(baseUrl: Environment.apiUrlBase));
  }

  bool _isConnectionError(DioException e) {
    if (e.response != null) return false;
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown;
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
      if (_isConnectionError(e)) throw ConnectionTimeout();
      throw CustomError("Error de Dio desconocido", 1);
    } catch (e) {
      if (e is ConnectionTimeout) rethrow;
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
      if (_isConnectionError(e)) {
        throw ConnectionTimeout();
      }
      throw CustomError("Error de Dio desconocido", 1);
    } catch (e) {
      if (e is WrongCredentials ||
          e is EmailNotVerified ||
          e is ConnectionTimeout) {
        rethrow;
      }
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
      if (_isConnectionError(e)) {
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
      if (_isConnectionError(e)) {
        return "Conexión perdida";
      }
      return defaultErrorMessage;
    } catch (e) {
      return defaultErrorMessage;
    }
  }

  @override
  Future<String?> resendValidationEmail(String email) async {
    const defaultErrorMessage =
        "Error al intentar reenviar el correo de activación";
    try {
      await dio.post(
        "/api/auth/resend-validation-email",
        data: {"email": email},
      );
      return null;
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        return "Conexión perdida";
      }
      final responseData = e.response?.data;
      if (responseData is Map && responseData["error"] is String) {
        final error = (responseData["error"] as String).trim();
        if (error.isNotEmpty) return error;
      }
      return defaultErrorMessage;
    } catch (_) {
      return defaultErrorMessage;
    }
  }
}
