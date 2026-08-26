import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsave/auth/infrastructure/errors/auth_errors.dart';
import 'package:mindsave/auth/infrastructure/infrastructure.dart';

import '../../../home/infrastructure/services/services.dart';
import '../../domain/domain.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  const AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = "",
  });

  static const Object _notSet = Object();

  AuthState copyWith({
    AuthStatus? authStatus,
    Object? user = _notSet,
    String? errorMessage,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: identical(user, _notSet) ? this.user : user as User?,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoriesImpl(AuthDatasourceImpl());
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageServiceImpl();
});

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository authRepository;
  late LocalStorageService localStorageService;

  @override
  AuthState build() {
    authRepository = ref.watch(authRepositoryProvider);
    localStorageService = ref.watch(localStorageServiceProvider);
    unawaited(Future<void>.microtask(checkAuthStatus));
    return const AuthState();
  }

  Future<void> _setLoggedUser(User user) async {
    await localStorageService.setKeyValue("token", user.token);
    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: user,
      errorMessage: "",
    );
  }

  Future<void> logout([String? errorMessage]) async {
    await localStorageService.removeKey("token");

    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessage: errorMessage ?? "",
    );
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      final user = await authRepository.login(email, password);
      await _setLoggedUser(user);
      return true;
    } on WrongCredentials {
      await logout("Credenciales incorrectas");
      return false;
    } on ConnectionTimeout {
      await logout("Conexión perdida");
      return false;
    } on EmailNotVerified {
      await logout(
        "Cuenta aún no activada, por favor, revise su bandeja de entrada y siga las instrucciones para activarla",
      );
      return false;
    } catch (e) {
      await logout("Error al iniciar sesión");
      return false;
    }
  }

  Future<String?> registerUser(
    String email,
    String password,
    String name,
  ) async {
    try {
      final String? result = await authRepository.register(
        email,
        password,
        name,
      );
      return result;
    } on ConnectionTimeout {
      return "Conexión perdida";
    } catch (e) {
      return "Error al crear cuenta";
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      final String? result = await authRepository.resetPassword(email);
      return result;
    } on ConnectionTimeout {
      return "Conexión perdida";
    } catch (e) {
      return "Error al restablecer la contraseña";
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(
      authStatus: AuthStatus.checking,
      user: null,
      errorMessage: "",
    );
    final String? token = await localStorageService.getValue<String>("token");
    if (token == null) {
      await logout();
      return;
    }

    try {
      final user = await authRepository.checkAuthStatus(token);
      await _setLoggedUser(user);
    } on WrongCredentials {
      await logout();
    } catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.checking,
        user: null,
        errorMessage:
            "Error al intentar conectarse a los servidores de Mindsave",
      );
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
