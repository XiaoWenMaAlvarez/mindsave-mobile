import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindsave/externalizacion_de_voces/domain/entities/entities.dart';
import 'package:mindsave/externalizacion_de_voces/domain/repositories/externalizacion_de_voces_repository.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/providers/chat_ia_repository_provider.dart';
import 'package:mindsave/externalizacion_de_voces/presentation/screens/externalizacion_voces_initial_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('protege los accesos a WidgetRef que ocurren de forma diferida', () {
    final source = File(
      'lib/externalizacion_de_voces/presentation/screens/'
      'externalizacion_voces_initial_screen.dart',
    ).readAsStringSync();

    expect(
      RegExp(
        r'addPostFrameCallback[\s\S]*if \(!mounted\) return;[\s\S]*'
        r'ref\.read\(chatListProvider\.notifier\)\.loadPreviousChats\(\);',
      ).hasMatch(source),
      isTrue,
    );
    expect(
      RegExp(
        r'await context\.push[\s\S]*if \(!context\.mounted\) return;[\s\S]*'
        r'ref\.read\(chatListProvider\.notifier\)\.loadPreviousChats\(\);',
      ).hasMatch(source),
      isTrue,
    );
  });

  testWidgets(
    'no usa WidgetRef si la pantalla se desmonta antes de la carga inicial',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = _InitialScreenChatRepository();

      tester.binding.addPostFrameCallback((_) {
        tester.binding.attachRootWidget(
          tester.binding.wrapWithDefaultView(const SizedBox.shrink()),
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [chatIaRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: ExternalizacionVocesInitialScreen()),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'no usa WidgetRef si el router desmonta la lista mientras espera el chat',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = _InitialScreenChatRepository();
      final router = GoRouter(
        initialLocation: '/externalizacionVoces/0',
        routes: [
          GoRoute(
            path: '/externalizacionVoces/0',
            builder: (context, state) =>
                const ExternalizacionVocesInitialScreen(),
          ),
          GoRoute(
            path: '/externalizacionVoces/chat/:idChat',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Detalle del chat'))),
          ),
          GoRoute(
            path: '/replacement',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Pantalla sustituta'))),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [chatIaRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chat de prueba'));
      await tester.pumpAndSettle();
      expect(find.text('Detalle del chat'), findsOneWidget);

      router.go('/replacement');
      await tester.pumpAndSettle();

      expect(find.text('Pantalla sustituta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _InitialScreenChatRepository implements ExternalizacionDeVocesRepository {
  @override
  Future<ChatHistoryChatIa> createNewChat(String title) async {
    return ChatHistoryChatIa(id: 'chat-1', title: title, mensajes: []);
  }

  @override
  Future<void> deleteChat(String idChat) async {}

  @override
  Future<List<ChatHistoryChatIa>> getChatsByUser() async {
    return [
      ChatHistoryChatIa(id: 'chat-1', title: 'Chat de prueba', mensajes: []),
    ];
  }

  @override
  Future<ChatHistoryChatIa?> getMessagesFromChat(
    String idChat, {
    bool forceRefresh = false,
  }) async => null;

  @override
  Stream<String> sendMessageToChat(
    String idChat,
    String prompt, {
    List<XFile> files = const [],
  }) {
    return const Stream.empty();
  }
}
