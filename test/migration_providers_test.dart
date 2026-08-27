import 'dart:async';

import 'package:flutter_chat_core/flutter_chat_core.dart' as chat;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindsave/auth/domain/entities/user.dart' as auth;
import 'package:mindsave/auth/domain/repositories/auth_repository.dart';
import 'package:mindsave/auth/presentation/providers/auth_provider.dart';
import 'package:mindsave/externalizacion_de_voces/domain/entities/entities.dart';
import 'package:mindsave/externalizacion_de_voces/domain/repositories/externalizacion_de_voces_repository.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/providers/chat_ia_repository_provider.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/providers/chat_provider.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/providers/chats_list_provider.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/providers/user_provider.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/screens/externalizacion_voces_chat_screen.dart';
import 'package:mindsave/home/infrastructure/services/local_storage_service.dart';
import 'package:mindsave/home/infrastructure/services/local_storage_service_impl.dart';
import 'package:mindsave/home/presentation/providers/selected_menu_item_provider.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/domain/repositories/registro_estado_animo_repository.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/registro_estado_animo_provider.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/registro_estado_animo_repository_provider.dart';
import 'package:mindsave/test_breve_estado_animo/presentation/providers/is_loading_provider.dart';
import 'package:mindsave/test_breve_estado_animo/presentation/providers/selected_year_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('AuthState permite eliminar explícitamente el usuario', () {
    const user = auth.User(
      id: 'user-1',
      email: 'test@example.com',
      name: 'Test',
      password: '',
      token: 'token',
    );
    const initial = AuthState(authStatus: AuthStatus.authenticated, user: user);

    final loggedOut = initial.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
    );

    expect(loggedOut.user, isNull);
    expect(loggedOut.authStatus, AuthStatus.notAuthenticated);
  });

  test(
    'AuthNotifier espera el login y limpia usuario/token al salir',
    () async {
      final storage = _FakeLocalStorageService();
      final repository = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          localStorageServiceProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      await pumpEventQueue();
      expect(await notifier.loginUser('test@example.com', 'password'), isTrue);
      expect(container.read(authProvider).user?.id, 'user-1');
      expect(storage.values['token'], 'token');

      await notifier.logout();
      expect(container.read(authProvider).user, isNull);
      expect(storage.values.containsKey('token'), isFalse);
    },
  );

  test('los providers simples usan Notifier y actualizan su estado', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(selectedMenuItemProvider.notifier).select(2);
    container.read(selectedYearProvider.notifier).select(2024);
    container.read(isLoadingProvider.notifier).setLoading(true);

    expect(container.read(selectedMenuItemProvider), 2);
    expect(container.read(selectedYearProvider), 2024);
    expect(container.read(isLoadingProvider), isTrue);
  });

  test('el indicador global conserva cargas concurrentes activas', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(isLoadingProvider.notifier);

    notifier.setLoading(true);
    notifier.setLoading(true);
    notifier.setLoading(false);
    expect(container.read(isLoadingProvider), isTrue);

    notifier.setLoading(false);
    expect(container.read(isLoadingProvider), isFalse);
  });

  test(
    'la carga inicial CBT convierte errores de red en estado recuperable',
    () async {
      final container = ProviderContainer(
        overrides: [
          registroEstadoAnimoRepositoryProvider.overrideWithValue(
            _FailingRegistroRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(registroEstadoDeAnimoProvider);
      await pumpEventQueue();

      final state = container.read(registroEstadoDeAnimoProvider);
      expect(state.isLoading, isFalse);
      expect(state.completosError, contains('completados'));
      expect(state.pendientesError, contains('pendientes'));
    },
  );

  test(
    'la carga de un detalle CBT no se pierde mientras carga el listado',
    () async {
      final repository = _ConcurrentRegistroRepository();
      final container = ProviderContainer(
        overrides: [
          registroEstadoAnimoRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(() {
        if (!repository.completedPage.isCompleted) {
          repository.completedPage.complete(const []);
        }
        container.dispose();
      });

      final notifier = container.read(registroEstadoDeAnimoProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(registroEstadoDeAnimoProvider).isLoading, isTrue);

      await notifier.cargarRegistrosEstadoDeAnimoById('detail-1');
      expect(notifier.getRegistroEstadoDeAnimoById('detail-1'), isNotNull);

      repository.completedPage.complete(const []);
      await pumpEventQueue();
      expect(container.read(registroEstadoDeAnimoProvider).isLoading, isFalse);
    },
  );

  test(
    'ChatNotifier ordena el historial y conserva todos los mensajes',
    () async {
      final repository = _FakeChatRepository(
        history: ChatHistoryChatIa(
          id: 'chat-1',
          title: 'Chat',
          mensajes: [
            MensajeChatIa(
              id: 'newer',
              text: 'Nuevo',
              createdAt: DateTime.utc(2026, 1, 2),
              role: 'assistant',
              archivos: [],
            ),
            MensajeChatIa(
              id: 'older',
              text: 'Antiguo',
              createdAt: DateTime.utc(2026),
              role: 'user',
              archivos: [
                ArchivoChatIa(
                  fileUri: 'image',
                  mimeType: 'image/png',
                  fileUrl: 'https://example.com/image.png',
                ),
              ],
            ),
          ],
        ),
      );
      final container = _chatContainer(repository);
      addTearDown(container.dispose);

      await container
          .read(chatProvider.notifier)
          .loadPreviousMessages('chat-1');
      final messages = container.read(chatProvider).messages;

      expect(messages.map((message) => message.id), [
        'older-image-0',
        'older',
        'newer',
      ]);
      expect((messages.last as chat.TextMessage).text, 'Nuevo');
    },
  );

  test(
    'ChatNotifier descarta una respuesta atrasada de otra conversación',
    () async {
      final repository = _DelayedChatRepository();
      final container = ProviderContainer(
        overrides: [
          chatIaRepositoryProvider.overrideWithValue(repository),
          userChatIaProvider.overrideWithValue(
            const chat.User(id: 'user-1', name: 'Test'),
          ),
          iaChatIaProvider.overrideWithValue(
            const chat.User(id: 'ia-id', name: 'Mindsave'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(chatProvider.notifier);
      final firstLoad = notifier.loadPreviousMessages('chat-a');
      final secondLoad = notifier.loadPreviousMessages('chat-b');

      repository.complete('chat-b', 'Mensaje B');
      await secondLoad;
      repository.complete('chat-a', 'Mensaje A');
      await firstLoad;

      final messages = container.read(chatProvider).messages;
      expect(messages, hasLength(1));
      expect((messages.single as chat.TextMessage).text, 'Mensaje B');
    },
  );

  test('ChatNotifier finaliza el streaming y actualiza la respuesta', () async {
    final repository = _FakeChatRepository();
    final container = _chatContainer(repository);
    addTearDown(container.dispose);
    final notifier = container.read(chatProvider.notifier);

    await notifier.loadPreviousMessages('chat-1');
    await notifier.addMessage(text: 'Hola');
    await pumpEventQueue();

    final state = container.read(chatProvider);
    expect(state.isGeminiThinking, isFalse);
    expect(state.messages.whereType<chat.TextMessage>().last.text, 'Respuesta');
  });

  test(
    'ChatNotifier conserva la respuesta si el stream falla al cerrarse',
    () async {
      final repository = _FakeChatRepository(
        responseStream: Stream<String>.multi((controller) {
          controller.add('Respuesta completa');
          controller.addError(Exception('El servidor cerró el stream'));
          controller.close();
        }),
      );
      final container = _chatContainer(repository);
      addTearDown(container.dispose);
      final notifier = container.read(chatProvider.notifier);

      await notifier.loadPreviousMessages('chat-1');
      await notifier.addMessage(text: 'Hola');
      await pumpEventQueue();

      final state = container.read(chatProvider);
      expect(state.isGeminiThinking, isFalse);
      expect(state.error, isNull);
      expect(
        state.messages.whereType<chat.TextMessage>().last.text,
        'Respuesta completa',
      );
    },
  );

  test(
    'el streaming actualiza el mensaje sin reemplazar toda la lista',
    () async {
      final repository = _FakeChatRepository(
        responses: const ['R', 'Resp', 'Respuesta'],
      );
      final container = _chatContainer(repository);
      addTearDown(container.dispose);
      final controller = container.read(chatControllerProvider);
      final operations = <chat.ChatOperationType>[];
      final subscription = controller.operationsStream.listen(
        (operation) => operations.add(operation.type),
      );
      addTearDown(subscription.cancel);

      await container
          .read(chatProvider.notifier)
          .loadPreviousMessages('chat-1');
      await container.read(chatProvider.notifier).addMessage(text: 'Hola');
      await pumpEventQueue();

      expect(
        operations.where((type) => type == chat.ChatOperationType.update),
        hasLength(3),
      );
      expect(operations, isNot(contains(chat.ChatOperationType.set)));
      expect((controller.messages.last as chat.TextMessage).text, 'Respuesta');
    },
  );

  testWidgets('el chat renderiza mensajes de imagen', (tester) async {
    final controller = chat.InMemoryChatController(
      messages: [
        chat.ImageMessage(
          id: 'image-1',
          authorId: 'user-1',
          createdAt: DateTime.utc(2026),
          source: 'assets/img/icon.png',
          width: 100,
          height: 100,
        ),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Chat(
            chatController: controller,
            currentUserId: 'user-1',
            builders: externalizacionChatBuilders,
            resolveUser: (id) async => chat.User(id: id, name: 'Test'),
            onMessageSend: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FlyerChatImageMessage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'ChatsListNotifier distingue error de duplicado vs error general',
    () async {
      final dupRepo = _FakeChatRepository(failCreate: true);
      final containerDup = ProviderContainer(
        overrides: [chatIaRepositoryProvider.overrideWithValue(dupRepo)],
      );
      addTearDown(containerDup.dispose);

      await containerDup
          .read(chatListProvider.notifier)
          .addChat(title: 'Duplicado');
      expect(
        containerDup.read(chatListProvider).error,
        'Nombre del chat ya usado',
      );

      final genRepo = _FakeChatRepository(failCreateGeneric: true);
      final containerGen = ProviderContainer(
        overrides: [chatIaRepositoryProvider.overrideWithValue(genRepo)],
      );
      addTearDown(containerGen.dispose);

      await containerGen
          .read(chatListProvider.notifier)
          .addChat(title: 'General Error');
      expect(
        containerGen.read(chatListProvider).error,
        'No se pudo crear el chat. Inténtalo nuevamente.',
      );
    },
  );

  test(
    'ChatsListNotifier agrega el saludo inicial localmente al crear un chat',
    () async {
      final repo = _FakeChatRepository(responses: ['¡Hola! ¿En qué te ayudo?']);
      final container = ProviderContainer(
        overrides: [chatIaRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container
          .read(chatListProvider.notifier)
          .addChat(title: 'Nuevo Chat');
      final state = container.read(chatListProvider);

      expect(state.chats.length, 1);
      expect(state.chats.first.mensajes.length, 2);
      expect(state.chats.first.mensajes[0].text, 'Hola');
      expect(state.chats.first.mensajes[0].role, 'user');
      expect(state.chats.first.mensajes[1].text, '¡Hola! ¿En qué te ayudo?');
      expect(state.chats.first.mensajes[1].role, 'assistant');
    },
  );

  test('ChatsListNotifier ordena los chats por mensaje más reciente', () async {
    final now = DateTime.now();
    final olderChat = ChatHistoryChatIa(
      id: 'old-1',
      title: 'Antiguo',
      mensajes: [
        MensajeChatIa(
          id: 'm-old',
          text: 'Mensaje viejo',
          createdAt: now.subtract(const Duration(hours: 5)),
          role: 'user',
          archivos: const [],
        ),
      ],
    );
    final newerChat = ChatHistoryChatIa(
      id: 'new-1',
      title: 'Reciente',
      mensajes: [
        MensajeChatIa(
          id: 'm-new',
          text: 'Mensaje reciente',
          createdAt: now,
          role: 'user',
          archivos: const [],
        ),
      ],
    );

    final repo = _FakeChatRepository(chatsList: [olderChat, newerChat]);
    final container = ProviderContainer(
      overrides: [chatIaRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    await container.read(chatListProvider.notifier).loadPreviousChats();
    final chats = container.read(chatListProvider).chats;

    expect(chats.first.id, 'new-1');
    expect(chats.last.id, 'old-1');
  });

  test(
    'LocalStorageServiceImpl persiste y lee tipos String, bool, int y double',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = LocalStorageServiceImpl();

      await storage.setKeyValue<String>('stringKey', 'mindsave');
      await storage.setKeyValue<bool>('boolKey', true);
      await storage.setKeyValue<int>('quickMood', 3);
      await storage.setKeyValue<double>('score', 4.5);

      expect(await storage.getValue<String>('stringKey'), 'mindsave');
      expect(await storage.getValue<bool>('boolKey'), isTrue);
      expect(await storage.getValue<int>('quickMood'), 3);
      expect(await storage.getValue<double>('score'), 4.5);

      await storage.removeKey('quickMood');
      expect(await storage.getValue<int>('quickMood'), isNull);
    },
  );

  test(
    'ChatsListNotifier conserva el chat creado aunque falle el stream inicial de IA',
    () async {
      final repo = _FakeChatRepositoryWithFailingStream();
      final container = ProviderContainer(
        overrides: [chatIaRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container
          .read(chatListProvider.notifier)
          .addChat(title: 'Chat Resiliente');
      final state = container.read(chatListProvider);

      expect(state.chats.length, 1);
      expect(state.chats.first.title, 'Chat Resiliente');
      expect(state.chats.first.mensajes.length, 1);
      expect(state.chats.first.mensajes.first.text, 'Hola');
      expect(state.isLoading, isFalse);
    },
  );
}

class _FakeChatRepositoryWithFailingStream
    implements ExternalizacionDeVocesRepository {
  @override
  Future<ChatHistoryChatIa> createNewChat(String title) async {
    return ChatHistoryChatIa(id: 'chat-resilient', title: title, mensajes: []);
  }

  @override
  Future<void> deleteChat(String idChat) async {}

  @override
  Future<List<ChatHistoryChatIa>> getChatsByUser() async => [];

  @override
  Future<ChatHistoryChatIa?> getMessagesFromChat(String idChat) async => null;

  @override
  Stream<String> sendMessageToChat(
    String idChat,
    String prompt, {
    List<XFile> files = const [],
  }) {
    return Stream.error(Exception('Network timeout during stream'));
  }
}

class _FailingRegistroRepository implements RegistroEstadoAnimoRepository {
  @override
  Future<void> editarRegistroEstadoDeAnimoDeHoy(
    RegistroEstadoAnimo registroEstadoAnimo,
  ) async {}

  @override
  Future<void> eliminarRegistroEstadoDeAnimoDeHoy(String id) async {}

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoCompleto({
    int page = 1,
    int limit = 10,
  }) async => throw Exception('offline');

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoPendiente({
    int page = 1,
    int limit = 10,
  }) async => throw Exception('offline');

  @override
  Future<RegistroEstadoAnimo?> getRegistroEstadoDeAnimoById(String id) async =>
      throw Exception('offline');

  @override
  Future<String> saveRegistroEstadoDeAnimo(
    RegistroEstadoAnimo registroEstadoAnimo,
  ) async => 'id';
}

class _ConcurrentRegistroRepository implements RegistroEstadoAnimoRepository {
  final completedPage = Completer<List<RegistroEstadoAnimo>>();

  RegistroEstadoAnimo _record(String id) => RegistroEstadoAnimo(
    id: id,
    fecha: DateTime.utc(2026, 8, 27),
    sucesoTrastornador: 'Registro de prueba',
    grupoEmociones1: GrupoEmociones1(),
    grupoEmociones2: GrupoEmociones2(),
    grupoEmociones3: GrupoEmociones3(),
    grupoEmociones4: GrupoEmociones4(),
    grupoEmociones5: GrupoEmociones5(),
    grupoEmociones6: GrupoEmociones6(),
    grupoEmociones7: GrupoEmociones7(),
    grupoEmociones8: GrupoEmociones8(),
    grupoEmociones9: GrupoEmociones9(),
    grupoEmocionesPersonalizadas: GrupoEmocionesPersonalizadas(),
    listaPensamientos: const [],
  );

  @override
  Future<void> editarRegistroEstadoDeAnimoDeHoy(
    RegistroEstadoAnimo registroEstadoAnimo,
  ) async {}

  @override
  Future<void> eliminarRegistroEstadoDeAnimoDeHoy(String id) async {}

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoCompleto({
    int page = 1,
    int limit = 10,
  }) => completedPage.future;

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoPendiente({
    int page = 1,
    int limit = 10,
  }) async => const [];

  @override
  Future<RegistroEstadoAnimo?> getRegistroEstadoDeAnimoById(String id) async =>
      _record(id);

  @override
  Future<String> saveRegistroEstadoDeAnimo(
    RegistroEstadoAnimo registroEstadoAnimo,
  ) async => 'detail-1';
}

class _DelayedChatRepository implements ExternalizacionDeVocesRepository {
  final _loads = <String, Completer<ChatHistoryChatIa?>>{};

  void complete(String chatId, String message) {
    (_loads[chatId] ??= Completer<ChatHistoryChatIa?>()).complete(
      ChatHistoryChatIa(
        id: chatId,
        title: chatId,
        mensajes: [
          MensajeChatIa(
            id: '$chatId-message',
            text: message,
            createdAt: DateTime.utc(2026),
            role: 'assistant',
            archivos: const [],
          ),
        ],
      ),
    );
  }

  @override
  Future<ChatHistoryChatIa> createNewChat(String title) async {
    return ChatHistoryChatIa(id: 'new-chat', title: title, mensajes: []);
  }

  @override
  Future<void> deleteChat(String idChat) async {}

  @override
  Future<List<ChatHistoryChatIa>> getChatsByUser() async => [];

  @override
  Future<ChatHistoryChatIa?> getMessagesFromChat(String idChat) {
    return (_loads[idChat] ??= Completer<ChatHistoryChatIa?>()).future;
  }

  @override
  Stream<String> sendMessageToChat(
    String idChat,
    String prompt, {
    List<XFile> files = const [],
  }) {
    return const Stream.empty();
  }
}

ProviderContainer _chatContainer(_FakeChatRepository repository) {
  return ProviderContainer(
    overrides: [
      chatIaRepositoryProvider.overrideWithValue(repository),
      userChatIaProvider.overrideWithValue(
        const chat.User(id: 'user-1', name: 'Test'),
      ),
      iaChatIaProvider.overrideWithValue(
        const chat.User(id: 'ia-id', name: 'Mindsave'),
      ),
    ],
  );
}

class _FakeAuthRepository implements AuthRepository {
  static const user = auth.User(
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test',
    password: '',
    token: 'token',
  );

  @override
  Future<auth.User> checkAuthStatus(String token) async => user;

  @override
  Future<auth.User> login(String email, String password) async => user;

  @override
  Future<String?> register(String email, String password, String name) async =>
      null;

  @override
  Future<String?> resetPassword(String email) async => null;

  @override
  Future<String?> resendValidationEmail(String email) async => null;
}

class _FakeLocalStorageService implements LocalStorageService {
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

class _FakeChatRepository implements ExternalizacionDeVocesRepository {
  final ChatHistoryChatIa? history;
  final bool failCreate;
  final bool failCreateGeneric;
  final List<String> responses;
  final Stream<String>? responseStream;
  final List<ChatHistoryChatIa> chatsList;

  _FakeChatRepository({
    this.history,
    this.failCreate = false,
    this.failCreateGeneric = false,
    this.responses = const ['Respuesta'],
    this.responseStream,
    this.chatsList = const [],
  });

  @override
  Future<ChatHistoryChatIa> createNewChat(String title) async {
    if (failCreate) throw StateError('duplicate');
    if (failCreateGeneric) throw Exception('500 Internal Server Error');
    return ChatHistoryChatIa(id: 'chat-1', title: title, mensajes: []);
  }

  @override
  Future<void> deleteChat(String idChat) async {}

  @override
  Future<List<ChatHistoryChatIa>> getChatsByUser() async => chatsList;

  @override
  Future<ChatHistoryChatIa?> getMessagesFromChat(String idChat) async =>
      history;

  @override
  Stream<String> sendMessageToChat(
    String idChat,
    String prompt, {
    List<XFile> files = const [],
  }) {
    return responseStream ?? Stream.fromIterable(responses);
  }
}
