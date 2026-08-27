import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsave/auth/domain/entities/user.dart';
import 'package:mindsave/auth/domain/repositories/auth_repository.dart';
import 'package:mindsave/auth/presentation/providers/auth_provider.dart';
import 'package:mindsave/externalizacion_de_voces/infrastructure/datasources/externalizacion_de_voces_datasource_impl.dart';
import 'package:mindsave/home/infrastructure/services/local_storage_service.dart';
import 'package:mindsave/shared/infrastructure/http/authenticated_http_client.dart';
import 'package:mindsave/shared/presentation/providers/authenticated_http_client_provider.dart';

void main() {
  dotenv.loadFromString(envString: 'API_URL_BASE=https://api.example.com');

  group('AuthenticatedHttpClient', () {
    test('normaliza parametros y separa las entradas por usuario', () {
      final userOneKey = sessionCacheKeyBuilder('user-1');
      final userTwoKey = sessionCacheKeyBuilder('user-2');
      final firstUri = Uri.parse(
        'https://api.example.com/resource?year=2026&page=2',
      );
      final reorderedUri = Uri.parse(
        'https://api.example.com/resource?page=2&year=2026',
      );

      expect(userOneKey(url: firstUri), userOneKey(url: reorderedUri));
      expect(userOneKey(url: firstUri), isNot(userTwoKey(url: firstUri)));
    });

    test('reutiliza un GET fresco con los mismos parametros', () async {
      final adapter = _RecordingAdapter();
      final client = _createClient(adapter: adapter);
      addTearDown(client.close);

      final first = await client.dio.get<Map<String, dynamic>>(
        '/resource',
        queryParameters: {'year': 2026, 'page': 2},
      );
      final second = await client.dio.get<Map<String, dynamic>>(
        '/resource',
        queryParameters: {'page': 2, 'year': 2026},
      );

      expect(adapter.count('GET', '/resource'), 1);
      expect(second.data, first.data);

      await client.dio.get<Map<String, dynamic>>(
        '/resource',
        queryParameters: {'page': 3, 'year': 2026},
      );
      expect(adapter.count('GET', '/resource'), 2);
    });

    test('vuelve a la red cuando transcurren cinco minutos', () async {
      var now = DateTime.now().toUtc();
      final adapter = _RecordingAdapter();
      final client = _createClient(adapter: adapter, currentTime: () => now);
      addTearDown(client.close);

      await client.dio.get<Map<String, dynamic>>('/resource');
      now = now.add(const Duration(minutes: 5, seconds: 1));
      await client.dio.get<Map<String, dynamic>>('/resource');

      expect(adapter.count('GET', '/resource'), 2);
    });

    test('usa la respuesta vencida si falla la red', () async {
      var now = DateTime.now().toUtc();
      final adapter = _RecordingAdapter();
      final client = _createClient(adapter: adapter, currentTime: () => now);
      addTearDown(client.close);

      final networkResponse = await client.dio.get<Map<String, dynamic>>(
        '/resource',
      );
      now = now.add(const Duration(minutes: 6));
      adapter.failNetwork = true;

      final cachedResponse = await client.dio.get<Map<String, dynamic>>(
        '/resource',
      );

      expect(adapter.count('GET', '/resource'), 2);
      expect(cachedResponse.data, networkResponse.data);
      expect(cachedResponse.extra[extraFromNetworkKey], isFalse);
    });

    test('clear elimina todas las entradas de la sesion', () async {
      final adapter = _RecordingAdapter();
      final client = _createClient(adapter: adapter);
      addTearDown(client.close);

      await client.dio.get<Map<String, dynamic>>('/resource');
      await client.dio.get<Map<String, dynamic>>('/resource');
      expect(adapter.count('GET', '/resource'), 1);

      await client.clear();
      await client.dio.get<Map<String, dynamic>>('/resource');
      expect(adapter.count('GET', '/resource'), 2);
    });

    test('las mutaciones no se almacenan en cache', () async {
      final adapter = _RecordingAdapter();
      final client = _createClient(adapter: adapter);
      addTearDown(client.close);

      await client.dio.post<Map<String, dynamic>>('/mutation');
      await client.dio.post<Map<String, dynamic>>('/mutation');

      expect(adapter.count('POST', '/mutation'), 2);
    });

    test('notifica una respuesta 401 y conserva el error HTTP', () async {
      final adapter = _RecordingAdapter()..statusCode = 401;
      var unauthorizedNotifications = 0;
      final client = _createClient(
        adapter: adapter,
        onUnauthorized: () => unauthorizedNotifications++,
      );
      addTearDown(client.close);

      await expectLater(
        client.dio.get<Map<String, dynamic>>('/private'),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            401,
          ),
        ),
      );

      expect(unauthorizedNotifications, 1);
    });

    test('crear un chat invalida solo la familia de chats', () async {
      final adapter = _RecordingAdapter();
      final client = _createClient(adapter: adapter);
      final datasource = ExternalizacionDeVocesDatasourceImpl(
        httpClient: client,
      );
      addTearDown(client.close);

      await datasource.getChatsByUser();
      await datasource.getChatsByUser();
      await client.dio.get<Map<String, dynamic>>('/api/unrelated');
      await client.dio.get<Map<String, dynamic>>('/api/unrelated');

      expect(adapter.count('GET', '/api/chat-ia/get-chats-by-user'), 1);
      expect(adapter.count('GET', '/api/unrelated'), 1);

      await datasource.createNewChat('Nuevo chat');
      await datasource.getChatsByUser();
      await client.dio.get<Map<String, dynamic>>('/api/unrelated');

      expect(adapter.count('POST', '/api/chat-ia/new-chat'), 1);
      expect(adapter.count('GET', '/api/chat-ia/get-chats-by-user'), 2);
      expect(adapter.count('GET', '/api/unrelated'), 1);
    });

    test('el chat conserva texto si el UTF-8 termina incompleto', () async {
      final adapter = _RecordingAdapter()
        ..chatStreamChunks = [
          Uint8List.fromList(utf8.encode('Respuesta recibida')),
          Uint8List.fromList(const [0xC3]),
        ];
      final client = _createClient(adapter: adapter);
      final datasource = ExternalizacionDeVocesDatasourceImpl(
        httpClient: client,
      );
      addTearDown(client.close);

      final responses = await datasource
          .sendMessageToChat('chat-1', 'Hola')
          .toList();

      expect(responses, isNotEmpty);
      expect(responses.last, startsWith('Respuesta recibida'));
      expect(
        adapter.count('POST', '/api/chat-ia/send-message-to-chat/chat-1'),
        1,
      );
    });
  });

  test(
    'el cliente cambia al reemplazar token, usuario o cerrar sesion',
    () async {
      final repository = _SessionAuthRepository();
      final storage = _MemoryStorage();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          localStorageServiceProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      await pumpEventQueue();
      await container.read(authProvider.notifier).loginUser('a@b.cl', 'secret');
      final firstClient = container.read(authenticatedHttpClientProvider);

      await container.read(authProvider.notifier).loginUser('a@b.cl', 'secret');
      final refreshedTokenClient = container.read(
        authenticatedHttpClientProvider,
      );
      expect(refreshedTokenClient, isNot(same(firstClient)));

      await container.read(authProvider.notifier).logout();
      final loggedOutClient = container.read(authenticatedHttpClientProvider);
      expect(loggedOutClient, isNot(same(refreshedTokenClient)));

      repository.userId = 'user-2';
      await container.read(authProvider.notifier).loginUser('c@d.cl', 'secret');
      final secondUserClient = container.read(authenticatedHttpClientProvider);
      expect(secondUserClient, isNot(same(loggedOutClient)));
    },
  );

  test('un 401 del cliente autenticado cierra la sesion', () async {
    final repository = _SessionAuthRepository();
    final storage = _MemoryStorage();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        localStorageServiceProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    await pumpEventQueue();
    await container.read(authProvider.notifier).loginUser('a@b.cl', 'secret');
    final client = container.read(authenticatedHttpClientProvider);
    client.dio.httpClientAdapter = _RecordingAdapter()..statusCode = 401;

    await expectLater(
      client.dio.get<Map<String, dynamic>>('/private'),
      throwsA(isA<DioException>()),
    );

    final authState = container.read(authProvider);
    expect(authState.authStatus, AuthStatus.notAuthenticated);
    expect(authState.user, isNull);
    expect(
      authState.errorMessage,
      'Tu sesión expiró. Inicia sesión nuevamente.',
    );
    expect(storage.values.containsKey('token'), isFalse);
  });
}

AuthenticatedHttpClient _createClient({
  required _RecordingAdapter adapter,
  CurrentTime? currentTime,
  UnauthorizedCallback? onUnauthorized,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  dio.httpClientAdapter = adapter;
  return AuthenticatedHttpClient(
    baseUrl: 'https://api.example.com',
    sessionId: 'user-1',
    accessToken: 'token',
    currentTime: currentTime,
    dio: dio,
    onUnauthorized: onUnauthorized,
  );
}

class _RecordingAdapter implements HttpClientAdapter {
  final Map<String, int> _counts = {};
  bool failNetwork = false;
  int statusCode = 200;
  List<Uint8List>? chatStreamChunks;

  int count(String method, String path) => _counts['$method $path'] ?? 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final key = '${options.method.toUpperCase()} ${options.uri.path}';
    _counts.update(key, (value) => value + 1, ifAbsent: () => 1);

    if (failNetwork) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'offline',
      );
    }

    if (options.responseType == ResponseType.stream &&
        options.uri.path.startsWith('/api/chat-ia/send-message-to-chat/')) {
      return ResponseBody(
        Stream<Uint8List>.fromIterable(chatStreamChunks ?? const []),
        statusCode,
      );
    }

    final Object data;
    if (options.uri.path == '/api/chat-ia/get-chats-by-user') {
      data = {'results': <Object>[]};
    } else if (options.uri.path == '/api/chat-ia/new-chat') {
      data = {'result': 'chat-1'};
    } else {
      data = {
        'method': options.method,
        'path': options.uri.path,
        'query': options.uri.queryParameters,
        'request': _counts[key],
      };
    }

    return ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _SessionAuthRepository implements AuthRepository {
  var loginCount = 0;
  var userId = 'user-1';

  User get currentUser => User(
    id: userId,
    email: 'test@example.com',
    name: 'Test',
    password: '',
    token: 'token-${++loginCount}',
  );

  @override
  Future<User> checkAuthStatus(String token) async => currentUser;

  @override
  Future<User> login(String email, String password) async => currentUser;

  @override
  Future<String?> register(String email, String password, String name) async =>
      null;

  @override
  Future<String?> resetPassword(String email) async => null;

  @override
  Future<String?> resendValidationEmail(String email) async => null;
}

class _MemoryStorage implements LocalStorageService {
  final Map<String, Object> values = {};

  @override
  Future<T?> getValue<T>(String key) async => values[key] as T?;

  @override
  Future<bool> removeKey(String key) async => values.remove(key) != null;

  @override
  Future<void> setKeyValue<T>(String key, T value) async {
    values[key] = value as Object;
  }
}
