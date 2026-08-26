import 'package:prueba/externalizacion_de_voces/domain/entities/mensaje_chat_ia.dart';

class ChatHistoryChatIa {
  String id;
  String title;
  List<MensajeChatIa> mensajes;

  ChatHistoryChatIa({
    required this.id,
    required this.title,
    required this.mensajes,
  });

  factory ChatHistoryChatIa.fromJson(Map<String, dynamic> json) {
    return ChatHistoryChatIa(
      id: json['id'],
      title: json['title'],
      mensajes: List<MensajeChatIa>.from(
        json["mensajes"].map((mensaje) => MensajeChatIa.fromJson(mensaje)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      "mensajes": List<Map<String, dynamic>>.from(
        mensajes.map((mensaje) => mensaje.toJson()),
      ),
    };
  }
}
