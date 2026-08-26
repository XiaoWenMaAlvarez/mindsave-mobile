import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';

class RegistroEstadoAnimo {
  String id;
  DateTime fecha;
  String sucesoTrastornador;
  GrupoEmociones1 grupoEmociones1;
  GrupoEmociones2 grupoEmociones2;
  GrupoEmociones3 grupoEmociones3;
  GrupoEmociones4 grupoEmociones4;
  GrupoEmociones5 grupoEmociones5;
  GrupoEmociones6 grupoEmociones6;
  GrupoEmociones7 grupoEmociones7;
  GrupoEmociones8 grupoEmociones8;
  GrupoEmociones9 grupoEmociones9;
  GrupoEmocionesPersonalizadas grupoEmocionesPersonalizadas;
  List<Pensamiento> listaPensamientos;

  bool get isPending {
    bool isPendingPensamientos = listaPensamientos.any(
      (Pensamiento pensamiento) => pensamiento.isPending,
    );
    bool isPendingEmociones =
        grupoEmociones1.isPending ||
        grupoEmociones2.isPending ||
        grupoEmociones3.isPending ||
        grupoEmociones4.isPending ||
        grupoEmociones5.isPending ||
        grupoEmociones6.isPending ||
        grupoEmociones7.isPending ||
        grupoEmociones8.isPending ||
        grupoEmociones9.isPending ||
        grupoEmocionesPersonalizadas.isPending;
    return isPendingPensamientos || isPendingEmociones;
  }

  String? get isValid {
    if (sucesoTrastornador.trim() == "") return "El suceso no debe estar vacío";
    if (grupoEmociones1.isIncomplete != null) {
      return grupoEmociones1.isIncomplete;
    }
    if (grupoEmociones2.isIncomplete != null) {
      return grupoEmociones2.isIncomplete;
    }
    if (grupoEmociones3.isIncomplete != null) {
      return grupoEmociones3.isIncomplete;
    }
    if (grupoEmociones4.isIncomplete != null) {
      return grupoEmociones4.isIncomplete;
    }
    if (grupoEmociones5.isIncomplete != null) {
      return grupoEmociones5.isIncomplete;
    }
    if (grupoEmociones6.isIncomplete != null) {
      return grupoEmociones6.isIncomplete;
    }
    if (grupoEmociones7.isIncomplete != null) {
      return grupoEmociones7.isIncomplete;
    }
    if (grupoEmociones8.isIncomplete != null) {
      return grupoEmociones8.isIncomplete;
    }
    if (grupoEmociones9.isIncomplete != null) {
      return grupoEmociones9.isIncomplete;
    }
    if (grupoEmocionesPersonalizadas.isIncomplete != null) {
      return grupoEmocionesPersonalizadas.isIncomplete;
    }

    if (listaPensamientos.isEmpty) {
      return "Debe agregar por lo menos un pensamiento";
    }
    if (listaPensamientos.any(
      (Pensamiento pensamiento) => pensamiento.porcentajeCreenciaAntes == 0,
    )) {
      Pensamiento pensamiento = listaPensamientos.firstWhere(
        (Pensamiento pensamiento) => pensamiento.porcentajeCreenciaAntes == 0,
      );
      if (pensamiento.pensamientoNegativo.length > 10) {
        return 'La creencia del pensamiento "${pensamiento.pensamientoNegativo.substring(0, 10)}..." debe estar entre 1 y 100';
      } else {
        return 'La creencia del pensamiento "${pensamiento.pensamientoNegativo}" debe estar entre 1 y 100';
      }
    }
    return null;
  }

  RegistroEstadoAnimo({
    required this.id,
    required this.fecha,
    required this.sucesoTrastornador,
    required this.grupoEmociones1,
    required this.grupoEmociones2,
    required this.grupoEmociones3,
    required this.grupoEmociones4,
    required this.grupoEmociones5,
    required this.grupoEmociones6,
    required this.grupoEmociones7,
    required this.grupoEmociones8,
    required this.grupoEmociones9,
    required this.grupoEmocionesPersonalizadas,
    required this.listaPensamientos,
  });

  RegistroEstadoAnimo.fromJson(Map<String, dynamic> json)
    : id = json["id"],
      fecha = DateTime.parse(json['fecha']),
      sucesoTrastornador = json["sucesoTrastornador"],
      grupoEmociones1 = GrupoEmociones1.fromJson(json["grupoEmociones1"]),
      grupoEmociones2 = GrupoEmociones2.fromJson(json["grupoEmociones2"]),
      grupoEmociones3 = GrupoEmociones3.fromJson(json["grupoEmociones3"]),
      grupoEmociones4 = GrupoEmociones4.fromJson(json["grupoEmociones4"]),
      grupoEmociones5 = GrupoEmociones5.fromJson(json["grupoEmociones5"]),
      grupoEmociones6 = GrupoEmociones6.fromJson(json["grupoEmociones6"]),
      grupoEmociones7 = GrupoEmociones7.fromJson(json["grupoEmociones7"]),
      grupoEmociones8 = GrupoEmociones8.fromJson(json["grupoEmociones8"]),
      grupoEmociones9 = GrupoEmociones9.fromJson(json["grupoEmociones9"]),
      grupoEmocionesPersonalizadas = GrupoEmocionesPersonalizadas.fromJson(
        json["grupoEmocionesPersonalizadas"],
      ),
      listaPensamientos = List<Pensamiento>.from(
        json["pensamientos"].map(
          (pensamientoJson) => Pensamiento.fromJson(pensamientoJson),
        ),
      );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'fecha': fecha.toIso8601String(),
      'sucesoTrastornador': sucesoTrastornador,
      "grupoEmociones1": grupoEmociones1.toJson(),
      "grupoEmociones2": grupoEmociones2.toJson(),
      "grupoEmociones3": grupoEmociones3.toJson(),
      "grupoEmociones4": grupoEmociones4.toJson(),
      "grupoEmociones5": grupoEmociones5.toJson(),
      "grupoEmociones6": grupoEmociones6.toJson(),
      "grupoEmociones7": grupoEmociones7.toJson(),
      "grupoEmociones8": grupoEmociones8.toJson(),
      "grupoEmociones9": grupoEmociones9.toJson(),
      "grupoEmocionesPersonalizadas": grupoEmocionesPersonalizadas.toJson(),
      'pensamientos': List<Map<String, dynamic>>.from(
        listaPensamientos.map(
          (Pensamiento pensamiento) => pensamiento.toJson(),
        ),
      ),
    };
  }

  @override
  String toString() {
    return """
Registro de Estado de Ánimo:
ID: $id
Fecha: $fecha
Suceso trastornador: $sucesoTrastornador
Grupo de emociones 1: ${grupoEmociones1.toString()}
Grupo de emociones 2: ${grupoEmociones2.toString()}
Grupo de emociones 3: ${grupoEmociones3.toString()}
Grupo de emociones 4: ${grupoEmociones4.toString()}
Grupo de emociones 5: ${grupoEmociones5.toString()}
Grupo de emociones 6: ${grupoEmociones6.toString()}
Grupo de emociones 7: ${grupoEmociones7.toString()}
Grupo de emociones 8: ${grupoEmociones8.toString()}
Grupo de emociones 9: ${grupoEmociones9.toString()}
Grupo de emociones personalizadas: ${grupoEmocionesPersonalizadas.toString()}
Lista de pensamientos: ${listaPensamientos.map((Pensamiento pensamiento) => pensamiento.toString())}
""";
  }
}
