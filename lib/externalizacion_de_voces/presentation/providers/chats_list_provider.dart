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
  late ExternalizacionDeVocesRepository repository;

  @override
  ChatsListState build() {
    repository = ref.watch(chatIaRepositoryProvider);
    return const ChatsListState();
  }

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

  Future<void> addChat({required String title}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newChat = await repository.createNewChat(title);
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
      state = state.copyWith(chats: _sortChats([newChat, ...state.chats]));

      try {
        String greetingResponse = '';
        await for (final chunk in repository.sendMessageToChat(
          newChat.id,
          'Hola',
        )) {
          greetingResponse = chunk;
        }
        if (greetingResponse.isNotEmpty) {
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
          state = state.copyWith(chats: _sortChats([...state.chats]));
        }
      } catch (_) {
        // Si el saludo inicial de la IA falla, el chat ya fue creado y conservado.
      }
    } catch (e) {
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
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteChat({required String idChat}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.deleteChat(idChat);
      state = state.copyWith(
        chats: state.chats.where((chat) => chat.id != idChat).toList(),
      );
    } catch (_) {
      state = state.copyWith(error: 'No se pudo eliminar el chat');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadPreviousChats() async {
    if (state.isInitialLoading) return;
    state = state.copyWith(isInitialLoading: true, error: null);
    try {
      final chats = await repository.getChatsByUser();
      state = state.copyWith(chats: _sortChats(chats));
    } catch (_) {
      state = state.copyWith(error: 'No se pudieron cargar los chats');
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }
}

final chatListProvider = NotifierProvider<ChatsListNotifier, ChatsListState>(
  ChatsListNotifier.new,
);
