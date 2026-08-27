import 'package:image_picker/image_picker.dart';
import 'package:mindsave/externalizacion_de_voces/domain/datasources/externalizacion_de_voces_datasource.dart';
import 'package:mindsave/externalizacion_de_voces/domain/entities/entities.dart';
import 'package:mindsave/externalizacion_de_voces/domain/repositories/externalizacion_de_voces_repository.dart';

class ExternalizacionDeVocesRepositoryImpl
    extends ExternalizacionDeVocesRepository {
  final ExternalizacionDeVocesDatasource datasource;

  ExternalizacionDeVocesRepositoryImpl(this.datasource);

  @override
  Future<ChatHistoryChatIa> createNewChat(String title) {
    return datasource.createNewChat(title);
  }

  @override
  Future<void> deleteChat(String idChat) {
    return datasource.deleteChat(idChat);
  }

  @override
  Future<List<ChatHistoryChatIa>> getChatsByUser() {
    return datasource.getChatsByUser();
  }

  @override
  Future<ChatHistoryChatIa?> getMessagesFromChat(
    String idChat, {
    bool forceRefresh = false,
  }) {
    return datasource.getMessagesFromChat(idChat, forceRefresh: forceRefresh);
  }

  @override
  Stream<String> sendMessageToChat(
    String idChat,
    String prompt, {
    List<XFile> files = const [],
  }) {
    return datasource.sendMessageToChat(idChat, prompt, files: files);
  }
}
