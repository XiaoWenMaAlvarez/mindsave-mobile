import 'package:prueba/test_breve_estado_animo/domain/entities/depresion_test_breve.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/impulso_suicida_test_breve.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/sentimientos_ansiedad_emocional_test_breve.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/sentimientos_ansiedad_fisica_test_breve.dart';

class TestBreveEstadoDeAnimo {
  DateTime fechaCreacion;
  SentimientosAnsiedadEmocionalTestBreve sentimientosAnsiedadEmocionalTestBreve;
  SentimientosAnsiedadFisicaTestBreve sentimientosAnsiedadFisicaTestBreve;
  DepresionTestBreve depresionTestBreve;
  ImpulsoSuicidaTestBreve impulsoSuicidaTestBreve;
  String? notas;

  TestBreveEstadoDeAnimo({
    required this.fechaCreacion,
    required this.sentimientosAnsiedadEmocionalTestBreve,
    required this.sentimientosAnsiedadFisicaTestBreve,
    required this.depresionTestBreve,
    required this.impulsoSuicidaTestBreve,
    this.notas,
  });

  TestBreveEstadoDeAnimo.fromJson(Map<String, dynamic> json)
    : fechaCreacion = DateTime.parse(json['fechaCreacion']),
      sentimientosAnsiedadEmocionalTestBreve =
          SentimientosAnsiedadEmocionalTestBreve.fromJson(
            json['sentimientosAnsiedadEmocionalTestBreve'],
          ),
      sentimientosAnsiedadFisicaTestBreve =
          SentimientosAnsiedadFisicaTestBreve.fromJson(
            json['sentimientosAnsiedadFisicaTestBreve'],
          ),
      depresionTestBreve = DepresionTestBreve.fromJson(
        json['depresionTestBreve'],
      ),
      impulsoSuicidaTestBreve = ImpulsoSuicidaTestBreve.fromJson(
        json['impulsoSuicidaTestBreve'],
      ),
      notas = json['notas'];

  Map<String, dynamic> toJson() {
    return {
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'sentimientosAnsiedadEmocionalTestBreve':
          sentimientosAnsiedadEmocionalTestBreve.toJson(),
      'sentimientosAnsiedadFisicaTestBreve': sentimientosAnsiedadFisicaTestBreve
          .toJson(),
      'depresionTestBreve': depresionTestBreve.toJson(),
      'impulsoSuicidaTestBreve': impulsoSuicidaTestBreve.toJson(),
      'notas': notas,
    };
  }

  @override
  String toString() {
    return """
${sentimientosAnsiedadEmocionalTestBreve.toString()}

${sentimientosAnsiedadFisicaTestBreve.toString()}

${depresionTestBreve.toString()}

${impulsoSuicidaTestBreve.toString()}

Notas: $notas
""";
  }
}
