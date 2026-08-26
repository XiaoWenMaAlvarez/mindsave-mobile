import 'dart:async';

import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba/externalizacion_de_voces/presentation/providers/chats_list_provider.dart';
import 'package:prueba/externalizacion_de_voces/presentation/providers/providers.dart';
import 'package:prueba/home/presentation/widgets/widgets.dart';
import 'package:prueba/shared/presentation/widgets/mindsave_ui.dart';

const externalizacionChatBuilders = Builders(
  imageMessageBuilder: _buildImageMessage,
);

class ExternalizacionVocesChatScreen extends ConsumerWidget {
  final String idChat;

  const ExternalizacionVocesChatScreen({required this.idChat, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final chats = ref.watch(chatListProvider).chats;
    var title = 'Chat';
    for (final chat in chats) {
      if (chat.id == idChat) {
        title = chat.title;
        break;
      }
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text(title)),
      body: _ChatScreen(idChat: idChat),
      endDrawer: SideMenu(scaffoldKey: scaffoldKey),
    );
  }
}

class _ChatScreen extends ConsumerStatefulWidget {
  final String idChat;

  const _ChatScreen({required this.idChat});

  @override
  ConsumerState<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<_ChatScreen> {
  List<XFile> _imagesToSend = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadPreviousMessages(widget.idChat);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final controller = ref.watch(chatControllerProvider);
    final currentUser = ref.watch(userChatIaProvider);
    final geminiUser = ref.watch(iaChatIaProvider);

    ref.listen<String?>(chatProvider.select((state) => state.error), (
      previous,
      next,
    ) {
      if (next == null || next == previous) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(next)));
      ref.read(chatProvider.notifier).clearError();
    });

    if (chatState.isInitialLoading) {
      return const MindsaveLoadingView(
        message: 'Cargando la conversación…',
      );
    }

    return Column(
      children: [
        if (_imagesToSend.isNotEmpty)
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.image_outlined),
              title: Text('${_imagesToSend.length} imagen(es) seleccionada(s)'),
              trailing: IconButton(
                tooltip: 'Quitar imágenes',
                onPressed: () => setState(() => _imagesToSend = []),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        Expanded(
          child: Chat(
            chatController: controller,
            currentUserId: currentUser.id,
            builders: externalizacionChatBuilders,
            resolveUser: (id) async {
              if (id == currentUser.id) return currentUser;
              if (id == geminiUser.id) return geminiUser;
              return User(id: id, name: 'Usuario');
            },
            theme: ChatTheme.fromThemeData(Theme.of(context)),
            onMessageSend: chatState.isGeminiThinking
                ? null
                : (text) {
                    final images = [..._imagesToSend];
                    setState(() => _imagesToSend = []);
                    unawaited(
                      ref
                          .read(chatProvider.notifier)
                          .addMessage(text: text, images: images),
                    );
                  },
            onAttachmentTap: () async {
              final images = await ImagePicker().pickMultiImage(limit: 4);
              if (!mounted) return;
              setState(() => _imagesToSend = images);
            },
          ),
        ),
      ],
    );
  }
}

Widget _buildImageMessage(
  BuildContext context,
  ImageMessage message,
  int index, {
  required bool isSentByMe,
  MessageGroupStatus? groupStatus,
}) {
  return FlyerChatImageMessage(message: message, index: index);
}
