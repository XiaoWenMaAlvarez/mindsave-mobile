import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/externalizacion_de_voces/domain/entities/entities.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/providers/chats_list_provider.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/widgets/widgets.dart';
import 'package:mindsave/home/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

void _showNewChatDialog(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class ExternalizacionVocesInitialScreen extends ConsumerStatefulWidget {
  const ExternalizacionVocesInitialScreen({super.key});

  @override
  ConsumerState<ExternalizacionVocesInitialScreen> createState() =>
      _ExternalizacionVocesInitialScreenState();
}

class _ExternalizacionVocesInitialScreenState
    extends ConsumerState<ExternalizacionVocesInitialScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      body: _ExternalizacionVocesBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showNewChatDialog(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo chat'),
      ),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: 0),
      endDrawer: SideMenu(scaffoldKey: _scaffoldKey),
    );
  }

  Future<dynamic> showNewChatDialog(BuildContext context, WidgetRef ref) {
    return showDialog(
      context: context,
      builder: (context) {
        String newChatTitle = "";
        return AlertDialog(
          title: const Text('Título del chat'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Debe ser único'),
            onChanged: (value) => newChatTitle = value,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (newChatTitle.trim().isEmpty) {
                  return _showNewChatDialog(
                    context,
                    "El nombre del chat no puede estar vacío",
                  );
                }
                context.pop();
                ref
                    .read(chatListProvider.notifier)
                    .addChat(title: newChatTitle.trim());
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }
}

class _ExternalizacionVocesBody extends StatelessWidget {
  const _ExternalizacionVocesBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MindsavePageIntro(
                  eyebrow: 'Espacio de apoyo',
                  title: 'Externaliza tus pensamientos',
                  description:
                      'Pon en palabras lo que te preocupa y toma distancia en una conversación guiada.',
                ),
                SizedBox(height: 24),
                _InitialScreen(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialScreen extends ConsumerStatefulWidget {
  const _InitialScreen();

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<_InitialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(chatListProvider.notifier).loadPreviousChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(chatListProvider.select((state) => state.error), (
      previous,
      next,
    ) {
      if (next == null || next.isEmpty) return;
      _showNewChatDialog(context, next);
      ref.read(chatListProvider.notifier).clearError();
    });

    final chatListState = ref.watch(chatListProvider);
    final chatList = chatListState.chats;
    final isInitialLoading = chatListState.isInitialLoading;
    final isLoading = chatListState.isLoading;

    if (isInitialLoading && chatList.isEmpty) {
      return const MindsaveLoadingView(message: 'Cargando tus conversaciones…');
    }

    if (chatList.isEmpty) {
      final theme = Theme.of(context);
      return MindsaveSectionCard(
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 42,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              'Aún no hay conversaciones',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Toca “Nuevo chat” cuando quieras comenzar.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        if (isLoading) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 10),
        ] else ...[
          const SizedBox(height: 10),
        ],
        ...chatList.map(
          (chat) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ListTileChat(chat: chat),
          ),
        ),
      ],
    );
  }
}

class _ListTileChat extends ConsumerWidget {
  const _ListTileChat({required this.chat});

  final ChatHistoryChatIa chat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MensajeChatIa? lastMessage;

    if (chat.mensajes.isNotEmpty) {
      lastMessage = chat.mensajes.reduce(
        (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
      );
    }

    final theme = Theme.of(context);
    return MindsaveSectionCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        minTileHeight: 76,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.forum_outlined),
        ),
        title: Text(chat.title),
        subtitle: Text.rich(
          TextSpan(
            text: lastMessage == null
                ? ''
                : lastMessage.role == 'user'
                ? 'Tú: '
                : 'Mindsave: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
            children: [
              TextSpan(
                text: lastMessage == null ? 'Sin mensajes' : lastMessage.text,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        trailing: const Icon(Icons.arrow_forward_rounded),
        onTap: () async {
          await context.push('/externalizacionVoces/chat/${chat.id}');
          if (!context.mounted) return;
          ref.read(chatListProvider.notifier).loadPreviousChats();
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Eliminar chat'),
              content: const Text(
                '¿Está seguro de que desea eliminar este chat?',
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(chatListProvider.notifier)
                        .deleteChat(idChat: chat.id);
                    if (context.mounted) context.pop();
                  },
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
