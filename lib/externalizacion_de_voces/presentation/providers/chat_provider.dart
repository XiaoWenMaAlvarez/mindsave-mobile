import 'dart:async';

import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba/externalizacion_de_voces/domain/repositories/externalizacion_de_voces_repository.dart';
import 'package:prueba/externalizacion_de_voces/presentation/providers/chat_ia_repository_provider.dart';
import 'package:prueba/externalizacion_de_voces/presentation/providers/user_provider.dart';

class ChatState {
  static const Object _notSet = Object();

  final List<Message> messages;
  final bool isInitialLoading;
  final bool isGeminiThinking;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isInitialLoading = false,
    this.isGeminiThinking = false,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isInitialLoading,
    bool? isGeminiThinking,
    Object? error = _notSet,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isGeminiThinking: isGeminiThinking ?? this.isGeminiThinking,
      error: identical(error, _notSet) ? this.error : error as String?,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  late User geminiUser;
  late User chatUser;
  late ExternalizacionDeVocesRepository repository;

  StreamSubscription<String>? _responseSubscription;
  String _chatId = '';
  int _localId = 0;

  @override
  ChatState build() {
    chatUser = ref.watch(userChatIaProvider);
    geminiUser = ref.watch(iaChatIaProvider);
    repository = ref.watch(chatIaRepositoryProvider);
    ref.onDispose(() => _responseSubscription?.cancel());
    return const ChatState();
  }

  String _nextId(String prefix) {
    _localId++;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$_localId';
  }

  void clearError() => state = state.copyWith(error: null);

  Future<void> addMessage({
    required String text,
    List<XFile> images = const [],
  }) async {
    final trimmedText = text.trim();
    if (state.isGeminiThinking || (trimmedText.isEmpty && images.isEmpty)) {
      return;
    }

    state = state.copyWith(isGeminiThinking: true, error: null);
    try {
      final newMessages = <Message>[];
      for (final image in images) {
        newMessages.add(
          ImageMessage(
            id: _nextId('local-image'),
            authorId: chatUser.id,
            createdAt: DateTime.now().toUtc(),
            source: image.path,
            size: await image.length(),
          ),
        );
      }
      if (trimmedText.isNotEmpty) {
        newMessages.add(
          TextMessage(
            id: _nextId('local-text'),
            authorId: chatUser.id,
            text: trimmedText,
            createdAt: DateTime.now().toUtc(),
          ),
        );
      }

      final responseId = _nextId('gemini-response');
      newMessages.add(
        TextMessage(
          id: responseId,
          authorId: geminiUser.id,
          text: 'Mindsave está pensando ...',
          createdAt: DateTime.now().toUtc(),
        ),
      );
      state = state.copyWith(messages: [...state.messages, ...newMessages]);

      await _responseSubscription?.cancel();
      _responseSubscription = repository
          .sendMessageToChat(_chatId, trimmedText, files: images)
          .listen(
            (response) => _updateResponse(responseId, response),
            onError: (Object _) {
              _replaceResponse(
                responseId,
                'No se pudo generar una respuesta. Inténtalo nuevamente.',
              );
              state = state.copyWith(
                isGeminiThinking: false,
                error: 'No se pudo enviar el mensaje',
              );
            },
            onDone: () {
              state = state.copyWith(isGeminiThinking: false);
            },
          );
    } catch (_) {
      state = state.copyWith(
        isGeminiThinking: false,
        error: 'No se pudo enviar el mensaje',
      );
    }
  }

  void _updateResponse(String responseId, String response) {
    if (response.isEmpty) return;
    _replaceResponse(responseId, response);
  }

  void _replaceResponse(String responseId, String text) {
    final index = state.messages.indexWhere(
      (message) => message.id == responseId,
    );
    if (index == -1) return;
    final current = state.messages[index];
    if (current is! TextMessage) return;

    final messages = [...state.messages];
    messages[index] = current.copyWith(text: text);
    state = state.copyWith(messages: messages);
  }

  Future<void> loadPreviousMessages(String chatId) async {
    if (state.isInitialLoading && _chatId == chatId) return;
    _chatId = chatId;
    await _responseSubscription?.cancel();
    _responseSubscription = null;
    state = const ChatState(isInitialLoading: true);

    try {
      final response = await repository.getMessagesFromChat(chatId);
      final history = [...?response?.mensajes]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final messages = <Message>[];

      for (final message in history) {
        final authorId = message.role == 'user' ? chatUser.id : geminiUser.id;
        for (var index = 0; index < message.archivos.length; index++) {
          final file = message.archivos[index];
          if (file.mimeType.startsWith('image')) {
            messages.add(
              ImageMessage(
                id: '${message.id}-image-$index',
                authorId: authorId,
                createdAt: message.createdAt.toUtc(),
                source: file.fileUrl,
              ),
            );
          }
        }
        if (message.text.isNotEmpty) {
          messages.add(
            TextMessage(
              id: message.id,
              authorId: authorId,
              text: message.text,
              createdAt: message.createdAt.toUtc(),
            ),
          );
        }
      }

      state = ChatState(messages: messages);
    } catch (_) {
      state = const ChatState(error: 'No se pudieron cargar los mensajes');
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

final chatControllerProvider = Provider<InMemoryChatController>((ref) {
  final controller = InMemoryChatController();
  ref.listen<List<Message>>(
    chatProvider.select((state) => state.messages),
    (previous, next) => unawaited(_syncMessages(controller, next)),
    fireImmediately: true,
  );
  ref.onDispose(controller.dispose);
  return controller;
});

Future<void> _syncMessages(
  InMemoryChatController controller,
  List<Message> next,
) async {
  final current = controller.messages;
  final commonLength = current.length < next.length
      ? current.length
      : next.length;
  final commonIdsMatch = List.generate(
    commonLength,
    (index) => current[index].id == next[index].id,
  ).every((matches) => matches);

  if (commonIdsMatch && next.length >= current.length) {
    for (var index = 0; index < current.length; index++) {
      if (current[index] != next[index]) {
        await controller.updateMessage(current[index], next[index]);
      }
    }

    if (next.length > current.length) {
      await controller.insertAllMessages(
        next.sublist(current.length),
        animated: current.isNotEmpty,
      );
    }
    return;
  }

  // Reordenamientos, eliminaciones y cambios de conversación son poco
  // frecuentes. Se reemplazan sin animación para no superponer widgets con
  // la misma clave mientras Flutter retira los elementos de la lista anterior.
  await controller.setMessages(next, animated: false);
}
