import 'package:mindsave/externalizacion_de_voces/domain/entities/archivo_chat_ia.dart';

class MensajeChatIa {
  String id;
  String text;
  DateTime createdAt;
  String role;
  List<ArchivoChatIa> archivos;

  MensajeChatIa({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.role,
    required this.archivos,
  });

  factory MensajeChatIa.fromJson(Map<String, dynamic> json) {
    return MensajeChatIa(
      id: json['id'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      role: json["role"],
      archivos: List<ArchivoChatIa>.from(
        json["archivos"].map((archivo) => ArchivoChatIa.fromJson(archivo)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'role': role,
      "archivos": List<Map<String, dynamic>>.from(
        archivos.map((archivo) => archivo.toJson()),
      ),
    };
  }
}
