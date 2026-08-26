class ImpulsoSuicidaTestBreveResponse {
  final int pensamientosSuicidas;
  final int deseosDeMorir;

  ImpulsoSuicidaTestBreveResponse({
    required this.pensamientosSuicidas,
    required this.deseosDeMorir,
  }) : assert(
         pensamientosSuicidas >= 0 &&
             pensamientosSuicidas <= 5 &&
             deseosDeMorir >= 0 &&
             deseosDeMorir <= 5,
         'Los valores deben estar entre 0 y 5',
       );

  int get totalScore {
    return pensamientosSuicidas + deseosDeMorir;
  }

  String get result {
    if (deseosDeMorir >= 1) {
      return 'Debe llamar a un número de emergencias o acudir a un hospital.';
    }
    if (pensamientosSuicidas >= 1) {
      return 'Se recomienda acudir a un profesional de la salud.';
    }
    if (totalScore == 0) {
      return 'Pocos síntomas de impulso suicida o ninguno.';
    }
    return 'Error en el cálculo del resultado de impulso suicida.';
  }

  factory ImpulsoSuicidaTestBreveResponse.fromJson(Map<String, dynamic> json) {
    return ImpulsoSuicidaTestBreveResponse(
      pensamientosSuicidas: json['pensamientosSuicidas'] as int,
      deseosDeMorir: json['deseosDeMorir'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pensamientosSuicidas': pensamientosSuicidas,
      'deseosDeMorir': deseosDeMorir,
    };
  }
}
