import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsave/auth/domain/entities/user.dart';
import 'package:mindsave/auth/domain/repositories/auth_repository.dart';
import 'package:mindsave/auth/presentation/providers/auth_provider.dart';
import 'package:mindsave/auth/presentation/screens/check_auth_status_screen.dart';
import 'package:mindsave/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mindsave/auth/presentation/screens/login_screen.dart';
import 'package:mindsave/auth/presentation/screens/register_screen.dart';
import 'package:mindsave/auth/presentation/screens/successful_register_screen.dart';
import 'package:mindsave/config/theme/app_theme.dart';
import 'package:mindsave/home/infrastructure/services/local_storage_service.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('las cuatro pantallas auth renderizan en tamaño Pixel 9', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(const LoginScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();
    expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);

    await tester.pumpWidget(_testApp(const RegisterScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Crear cuenta'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_testApp(const ForgotPasswordScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Restablecer contraseña'), findsOneWidget);
    expect(find.text('Recuperar contraseña'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _testApp(const SuccessfulRegisterScreen(email: 'test@example.com')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cuenta creada con éxito'), findsOneWidget);
    expect(find.text('Revisa tu bandeja de entrada'), findsOneWidget);
    expect(find.text('Reenviar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reenviar activación utiliza el correo registrado', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(
      _testApp(
        const SuccessfulRegisterScreen(email: 'test@example.com'),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Reenviar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reenviar'));
    await tester.pumpAndSettle();

    expect(repository.resentValidationEmails, ['test@example.com']);
    expect(find.text('Correo de activación reenviado.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login presenta mensajes de validación sin llamar al servidor', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pump();

    expect(find.text('El campo es obligatorio'), findsNWidgets(2));
  });

  testWidgets('el error de conexión permite reintentar en tamaño Pixel 9', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _RetryingAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          localStorageServiceProvider.overrideWithValue(
            _TokenLocalStorageService(),
          ),
        ],
        child: MaterialApp(
          theme: const AppTheme(isDarkMode: true).getTheme(),
          home: const CheckAuthStatusScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión'), findsOneWidget);
    expect(
      find.text(
        'No pudimos conectar con el servidor. Comprueba tu conexión a internet e inténtalo de nuevo.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    expect(find.text('Reintentar conexión'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('retry-connection-button')));
    await tester.pump();

    expect(find.text('Conectando…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.retry.completeError(Exception('offline'));
    await tester.pumpAndSettle();

    expect(find.text('Reintentar conexión'), findsOneWidget);
    expect(repository.checkCalls, 2);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget home, {AuthRepository? repository}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        repository ?? _FakeAuthRepository(),
      ),
      localStorageServiceProvider.overrideWithValue(_FakeLocalStorageService()),
    ],
    child: MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A6A7),
          brightness: Brightness.dark,
        ),
      ),
      home: home,
    ),
  );
}

class _FakeAuthRepository implements AuthRepository {
  static const user = User(
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test',
    password: '',
    token: 'token',
  );
  final List<String> resentValidationEmails = [];

  @override
  Future<User> checkAuthStatus(String token) async => user;

  @override
  Future<User> login(String email, String password) async => user;

  @override
  Future<String?> register(String email, String password, String name) async =>
      null;

  @override
  Future<String?> resetPassword(String email) async => null;

  @override
  Future<String?> resendValidationEmail(String email) async {
    resentValidationEmails.add(email);
    return null;
  }
}

class _FakeLocalStorageService implements LocalStorageService {
  @override
  Future<T?> getValue<T>(String key) async => null;

  @override
  Future<bool> removeKey(String key) async => true;

  @override
  Future<void> setKeyValue<T>(String key, T value) async {}
}

class _RetryingAuthRepository implements AuthRepository {
  final retry = Completer<User>();
  int checkCalls = 0;

  @override
  Future<User> checkAuthStatus(String token) {
    checkCalls++;
    if (checkCalls == 1) return Future.error(Exception('offline'));
    return retry.future;
  }

  @override
  Future<User> login(String email, String password) =>
      throw UnimplementedError();

  @override
  Future<String?> register(String email, String password, String name) =>
      throw UnimplementedError();

  @override
  Future<String?> resetPassword(String email) => throw UnimplementedError();

  @override
  Future<String?> resendValidationEmail(String email) =>
      throw UnimplementedError();
}

class _TokenLocalStorageService implements LocalStorageService {
  @override
  Future<T?> getValue<T>(String key) async => 'saved-token' as T;

  @override
  Future<bool> removeKey(String key) async => true;

  @override
  Future<void> setKeyValue<T>(String key, T value) async {}
}
