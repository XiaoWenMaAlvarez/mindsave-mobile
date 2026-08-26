import 'package:flutter_chat_core/flutter_chat_core.dart' as chat;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba/auth/domain/entities/user.dart' as auth;
import 'package:prueba/auth/domain/repositories/auth_repository.dart';
import 'package:prueba/auth/presentation/providers/auth_provider.dart';
import 'package:prueba/externalizacion_de_voces/domain/entities/entities.dart';
import 'package:prueba/externalizacion_de_voces/domain/repositories/externalizacion_de_voces_repository.dart';
import 'package:prueba/externalizacion_de_voces/presentation/providers/chat_ia_repository_provider.dart';
import 'package:prueba/externalizacion_de_voces/presentation/providers/chat_provider.dart';
import 'package:prueba/externalizacion_de_voces/presentation/providers/chats_list_provider.dart';
import 'package:prueba/externalizacion_de_voces/presentation/providers/user_provider.dart';
import 'package:prueba/externalizacion_de_voces/presentation/screens/externalizacion_voces_chat_screen.dart';
import 'package:prueba/home/infrastructure/services/local_storage_service.dart';
import 'package:prueba/home/presentation/providers/selected_menu_item_provider.dart';
import 'package:prueba/test_breve_estado_animo/presentation/providers/is_loading_provider.dart';
import 'package:prueba/test_breve_estado_animo/presentation/providers/selected_year_provider.dart';

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
    'ChatsListNotifier restablece loading cuando falla la creación',
    () async {
      final repository = _FakeChatRepository(failCreate: true);
      final container = ProviderContainer(
        overrides: [chatIaRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container
          .read(chatListProvider.notifier)
          .addChat(title: 'Duplicado');
      final state = container.read(chatListProvider);

      expect(state.isLoading, isFalse);
      expect(state.error, isNotNull);
    },
  );
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
  final List<String> responses;

  _FakeChatRepository({
    this.history,
    this.failCreate = false,
    this.responses = const ['Respuesta'],
  });

  @override
  Future<ChatHistoryChatIa> createNewChat(String title) async {
    if (failCreate) throw StateError('duplicate');
    return ChatHistoryChatIa(id: 'chat-1', title: title, mensajes: []);
  }

  @override
  Future<void> deleteChat(String idChat) async {}

  @override
  Future<List<ChatHistoryChatIa>> getChatsByUser() async => [];

  @override
  Future<ChatHistoryChatIa?> getMessagesFromChat(String idChat) async =>
      history;

  @override
  Stream<String> sendMessageToChat(
    String idChat,
    String prompt, {
    List<XFile> files = const [],
  }) {
    return Stream.fromIterable(responses);
  }
}
