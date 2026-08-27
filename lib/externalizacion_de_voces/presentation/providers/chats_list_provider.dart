import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsave/externalizacion_de_voces/domain/entities/entities.dart';
import 'package:mindsave/externalizacion_de_voces/domain/repositories/externalizacion_de_voces_repository.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/providers/chat_ia_repository_provider.dart';

class ChatsListState {
  static const Object _notSet = Object();

  final List<ChatHistoryChatIa> chats;
  final bool isInitialLoading;
  final bool isLoading;
  final String? error;

  const ChatsListState({
    this.chats = const [],
    this.isInitialLoading = false,
    this.isLoading = false,
    this.error,
  });

  ChatsListState copyWith({
    List<ChatHistoryChatIa>? chats,
    bool? isInitialLoading,
    bool? isLoading,
    Object? error = _notSet,
  }) {
    return ChatsListState(
      chats: chats ?? this.chats,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _notSet) ? this.error : error as String?,
    );
  }
}

class ChatsListNotifier extends Notifier<ChatsListState> {
  static const _initialMessagesMaxAttempts = 30;
  static const _initialMessagesRetryDelay = Duration(milliseconds: 500);

  late ExternalizacionDeVocesRepository repository;
  int _generation = 0;

  @override
  ChatsListState build() {
    _generation++;
    repository = ref.watch(chatIaRepositoryProvider);
    return const ChatsListState();
  }

  bool _isCurrent(int generation) => ref.mounted && generation == _generation;

  void clearError() => state = state.copyWith(error: null);

  List<ChatHistoryChatIa> _sortChats(List<ChatHistoryChatIa> list) {
    final copy = [...list];
    copy.sort((a, b) {
      final aDate = a.mensajes.isNotEmpty
          ? a.mensajes
                .map((m) => m.createdAt)
                .reduce((x, y) => x.isAfter(y) ? x : y)
          : DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.mensajes.isNotEmpty
          ? b.mensajes
                .map((m) => m.createdAt)
                .reduce((x, y) => x.isAfter(y) ? x : y)
          : DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return copy;
  }

  Future<List<MensajeChatIa>?> _waitForInitialMessages({
    required String chatId,
    required int generation,
    required ExternalizacionDeVocesRepository activeRepository,
  }) async {
    for (var attempt = 0; attempt < _initialMessagesMaxAttempts; attempt++) {
      if (!_isCurrent(generation)) return null;
      try {
        final chat = await activeRepository.getMessagesFromChat(
          chatId,
          forceRefresh: true,
        );
        if (!_isCurrent(generation)) return null;
        final messages = [...?chat?.mensajes]
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final hasAssistantGreeting = messages.any(
          (message) =>
              message.role == 'assistant' && message.text.trim().isNotEmpty,
        );
        if (hasAssistantGreeting) return messages;
      } catch (_) {
        return null;
      }

      if (attempt + 1 < _initialMessagesMaxAttempts) {
        await Future<void>.delayed(_initialMessagesRetryDelay);
      }
    }
    return null;
  }

  Future<void> addChat({required String title}) async {
    if (state.isLoading) return;
    final generation = _generation;
    final activeRepository = repository;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newChat = await activeRepository.createNewChat(title);
      if (!_isCurrent(generation)) return;
      final now = DateTime.now();
      newChat.mensajes = [
        MensajeChatIa(
          id: '${newChat.id}-user-greeting',
          text: 'Hola',
          createdAt: now,
          role: 'user',
          archivos: const [],
        ),
      ];

      String greetingResponse = '';
      var greetingStreamCompleted = false;
      try {
        await for (final chunk in activeRepository.sendMessageToChat(
          newChat.id,
          'Hola',
        )) {
          if (!_isCurrent(generation)) return;
          greetingResponse = chunk;
        }
        greetingStreamCompleted = true;
        if (!_isCurrent(generation)) return;
      } catch (_) {
        // El backend puede completar el saludo aunque el stream se cierre antes.
      }

      List<MensajeChatIa>? persistedMessages;
      if (!greetingStreamCompleted || greetingResponse.trim().isEmpty) {
        persistedMessages = await _waitForInitialMessages(
          chatId: newChat.id,
          generation: generation,
          activeRepository: activeRepository,
        );
      }
      if (!_isCurrent(generation)) return;

      if (persistedMessages != null) {
        newChat.mensajes = persistedMessages;
      } else if (greetingResponse.trim().isNotEmpty) {
        newChat.mensajes = [
          ...newChat.mensajes,
          MensajeChatIa(
            id: '${newChat.id}-assistant-greeting',
            text: greetingResponse,
            createdAt: DateTime.now().add(const Duration(milliseconds: 100)),
            role: 'assistant',
            archivos: const [],
          ),
        ];
      }

      state = state.copyWith(chats: _sortChats([newChat, ...state.chats]));
    } catch (e) {
      if (!_isCurrent(generation)) return;
      if (e is DioException) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 409) {
          state = state.copyWith(error: 'Nombre del chat ya usado');
          return;
        }
      } else if (e is StateError && e.message.contains('duplicate')) {
        state = state.copyWith(error: 'Nombre del chat ya usado');
        return;
      } else if (e.toString().contains('duplicate') ||
          e.toString().contains('409') ||
          e.toString().contains('ya usado')) {
        state = state.copyWith(error: 'Nombre del chat ya usado');
        return;
      }
      state = state.copyWith(
        error: 'No se pudo crear el chat. Inténtalo nuevamente.',
      );
    } finally {
      if (_isCurrent(generation)) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> deleteChat({required String idChat}) async {
    if (state.isLoading) return;
    final generation = _generation;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.deleteChat(idChat);
      if (!_isCurrent(generation)) return;
      state = state.copyWith(
        chats: state.chats.where((chat) => chat.id != idChat).toList(),
      );
    } catch (_) {
      if (_isCurrent(generation)) {
        state = state.copyWith(error: 'No se pudo eliminar el chat');
      }
    } finally {
      if (_isCurrent(generation)) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> loadPreviousChats() async {
    if (state.isInitialLoading) return;
    final generation = _generation;
    state = state.copyWith(isInitialLoading: true, error: null);
    try {
      final chats = await repository.getChatsByUser();
      if (!_isCurrent(generation)) return;
      state = state.copyWith(chats: _sortChats(chats));
    } catch (_) {
      if (_isCurrent(generation)) {
        state = state.copyWith(error: 'No se pudieron cargar los chats');
      }
    } finally {
      if (_isCurrent(generation)) {
        state = state.copyWith(isInitialLoading: false);
      }
    }
  }
}

final chatListProvider = NotifierProvider<ChatsListNotifier, ChatsListState>(
  ChatsListNotifier.new,
);
