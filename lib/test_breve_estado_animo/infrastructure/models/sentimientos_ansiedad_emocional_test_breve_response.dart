class SentimientosAnsiedadEmocionalTestBreveResponse {
  final int angustiado;
  final int nervioso;
  final int preocupado;
  final int asustado;
  final int tenso;

  SentimientosAnsiedadEmocionalTestBreveResponse({
    required this.angustiado,
    required this.nervioso,
    required this.preocupado,
    required this.asustado,
    required this.tenso,
  }) : assert(
         angustiado >= 0 &&
             angustiado <= 4 &&
             nervioso >= 0 &&
             nervioso <= 4 &&
             preocupado >= 0 &&
             preocupado <= 4 &&
             asustado >= 0 &&
             asustado <= 4 &&
             tenso >= 0 &&
             tenso <= 4,
         'Los valores deben estar entre 0 y 4',
       );

  int get totalScore {
    return angustiado + nervioso + preocupado + asustado + tenso;
  }

  String get result {
    if (totalScore <= 1) {
      return 'Pocos síntomas de ansiedad o ninguno';
    }
    if (totalScore <= 4) {
      return 'Síntomas de ansiedad marginal';
    }
    if (totalScore <= 8) {
      return 'Síntomas de ansiedad leve';
    }
    if (totalScore <= 12) {
      return 'Síntomas de ansiedad moderada';
    }
    if (totalScore <= 16) {
      return 'Síntomas de ansiedad grave';
    }
    if (totalScore <= 20) {
      return 'Síntomas de ansiedad extrema';
    }
    return 'Error en el cálculo del resultado de ansiedad emocional';
  }

  factory SentimientosAnsiedadEmocionalTestBreveResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return SentimientosAnsiedadEmocionalTestBreveResponse(
      angustiado: json['angustiado'] as int,
      nervioso: json['nervioso'] as int,
      preocupado: json['preocupado'] as int,
      asustado: json['asustado'] as int,
      tenso: json['tenso'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'angustiado': angustiado,
      'nervioso': nervioso,
      'preocupado': preocupado,
      'asustado': asustado,
      'tenso': tenso,
    };
  }
}
