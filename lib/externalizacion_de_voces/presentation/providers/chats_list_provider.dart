import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/externalizacion_de_voces/domain/entities/entities.dart';
import 'package:prueba/externalizacion_de_voces/domain/repositories/externalizacion_de_voces_repository.dart';
import 'package:prueba/externalizacion_de_voces/presentation/providers/chat_ia_repository_provider.dart';

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

  Future<void> addChat({required String title}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newChat = await repository.createNewChat(title);
      await for (final _ in repository.sendMessageToChat(newChat.id, 'Hola')) {}
      state = state.copyWith(chats: [newChat, ...state.chats]);
    } catch (_) {
      state = state.copyWith(error: 'Nombre del chat ya usado');
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
      state = state.copyWith(chats: chats);
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
