import 'package:image_picker/image_picker.dart';
import 'package:mindsave/externalizacion_de_voces/domain/entities/entities.dart';

abstract class ExternalizacionDeVocesRepository {
  Future<ChatHistoryChatIa> createNewChat(String title);

  Future<List<ChatHistoryChatIa>> getChatsByUser();

  Future<ChatHistoryChatIa?> getMessagesFromChat(String idChat);

  Future<void> deleteChat(String idChat);

  Stream<String> sendMessageToChat(
    String idChat,
    String prompt, {
    List<XFile> files = const [],
  });
}
