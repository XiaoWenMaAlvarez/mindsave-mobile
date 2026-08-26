import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindsave/externalizacion_de_voces/domain/datasources/externalizacion_de_voces_datasource.dart';
import 'package:mindsave/externalizacion_de_voces/domain/entities/entities.dart';
import 'package:mindsave/shared/infrastructure/http/authenticated_http_client.dart';

class ExternalizacionDeVocesDatasourceImpl
    extends ExternalizacionDeVocesDatasource {
  static final _chatsListCachePattern = RegExp(
    r'/api/chat-ia/get-chats-by-user(?:\?|$)',
  );

  final AuthenticatedHttpClient httpClient;

  Dio get dio => httpClient.dio;

  ExternalizacionDeVocesDatasourceImpl({required this.httpClient});

  Future<void> _invalidateChatCache([String? idChat]) async {
    final invalidations = <Future<void>>[
      httpClient.invalidate(_chatsListCachePattern),
    ];
    if (idChat != null) {
      invalidations.add(
        httpClient.invalidate(
          RegExp(
            '/api/chat-ia/get-messages-from-chat/${RegExp.escape(idChat)}'
            r'(?:\?|$)',
          ),
        ),
      );
    }
    await Future.wait(invalidations);
  }

  @override
  Future<ChatHistoryChatIa> createNewChat(String title) async {
    try {
      final response = await dio.post(
        "/api/chat-ia/new-chat",
        data: {"title": title},
      );

      final result = ChatHistoryChatIa(
        id: response.data["result"],
        title: title,
        mensajes: [],
      );
      await _invalidateChatCache(result.id);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteChat(String idChat) async {
    await dio.delete("/api/chat-ia/delete-chat/$idChat");
    await _invalidateChatCache(idChat);
  }

  @override
  Future<List<ChatHistoryChatIa>> getChatsByUser() async {
    final response = await dio.get("/api/chat-ia/get-chats-by-user");
    final List<Map<String, dynamic>> responseJson =
        List<Map<String, dynamic>>.from(response.data["results"]);

    //TODO: Ordenar chats por mensaje más reciente
    return responseJson
        .map((chatJson) => ChatHistoryChatIa.fromJson(chatJson))
        .toList();
  }

  @override
  Future<ChatHistoryChatIa?> getMessagesFromChat(String idChat) async {
    final response = await dio.get(
      "/api/chat-ia/get-messages-from-chat/$idChat",
    );
    if (response.data == null) return null;
    final chat = ChatHistoryChatIa.fromJson(response.data["result"]);
    return chat;
  }

  @override
  Stream<String> sendMessageToChat(
    String idChat,
    String prompt, {
    List<XFile> files = const [],
  }) async* {
    var requestAccepted = false;
    try {
      final formData = FormData();

      formData.fields.add(MapEntry("prompt", prompt));
      formData.fields.add(MapEntry("chatId", idChat));

      for (XFile file in files) {
        formData.files.add(
          MapEntry(
            "files",
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }

      final response = await dio.post(
        "/api/chat-ia/send-message-to-chat/$idChat",
        data: formData,
        options: Options(responseType: ResponseType.stream),
      );
      requestAccepted = true;
      await _invalidateChatCache(idChat);

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        final chunkString = utf8.decode(chunk, allowMalformed: true);
        buffer += chunkString;
        yield buffer;
      }
    } catch (e) {
      throw Exception("Error en la generación de la respuesta de Gemini");
    } finally {
      if (requestAccepted) {
        await _invalidateChatCache(idChat);
      }
    }
  }
}
