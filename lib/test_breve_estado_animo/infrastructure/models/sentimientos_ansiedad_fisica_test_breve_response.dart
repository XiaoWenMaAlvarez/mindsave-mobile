class SentimientosAnsiedadFisicaTestBreveResponse {
  final int palpitaciones;
  final int sudoracion;
  final int temblores;
  final int dificultadRespirar;
  final int ahogo;
  final int dolorPecho;
  final int nauseas;
  final int mareos;
  final int sensacionIrrealidad;
  final int inestabilidadHormigueos;

  SentimientosAnsiedadFisicaTestBreveResponse({
    required this.palpitaciones,
    required this.sudoracion,
    required this.temblores,
    required this.dificultadRespirar,
    required this.ahogo,
    required this.dolorPecho,
    required this.nauseas,
    required this.mareos,
    required this.sensacionIrrealidad,
    required this.inestabilidadHormigueos,
  }) : assert(
         palpitaciones >= 0 &&
             palpitaciones <= 5 &&
             sudoracion >= 0 &&
             sudoracion <= 5 &&
             temblores >= 0 &&
             temblores <= 5 &&
             dificultadRespirar >= 0 &&
             dificultadRespirar <= 5 &&
             ahogo >= 0 &&
             ahogo <= 5 &&
             dolorPecho >= 0 &&
             dolorPecho <= 5 &&
             nauseas >= 0 &&
             nauseas <= 5 &&
             mareos >= 0 &&
             mareos <= 5 &&
             sensacionIrrealidad >= 0 &&
             sensacionIrrealidad <= 5 &&
             inestabilidadHormigueos >= 0 &&
             inestabilidadHormigueos <= 5,
         'Los valores deben estar entre 0 y 5',
       );

  int get totalScore {
    return palpitaciones +
        sudoracion +
        temblores +
        dificultadRespirar +
        ahogo +
        dolorPecho +
        nauseas +
        mareos +
        sensacionIrrealidad +
        inestabilidadHormigueos;
  }

  String get result {
    if (totalScore <= 2) {
      return 'Pocos síntomas físicos de ansiedad o ninguno';
    }
    if (totalScore <= 6) {
      return 'Síntomas físicos de ansiedad marginal';
    }
    if (totalScore <= 10) {
      return 'Síntomas físicos de ansiedad leve';
    }
    if (totalScore <= 20) {
      return 'Síntomas físicos de ansiedad moderada';
    }
    if (totalScore <= 30) {
      return 'Síntomas físicos de ansiedad severa';
    }
    if (totalScore <= 30) {
      return 'Síntomas físicos de ansiedad extrema';
    }
    return 'Error en el cálculo de síntomas físicos de ansiedad';
  }

  factory SentimientosAnsiedadFisicaTestBreveResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return SentimientosAnsiedadFisicaTestBreveResponse(
      palpitaciones: json['palpitaciones'] as int,
      sudoracion: json['sudoracion'] as int,
      temblores: json['temblores'] as int,
      dificultadRespirar: json['dificultadRespirar'] as int,
      ahogo: json['ahogo'] as int,
      dolorPecho: json['dolorPecho'] as int,
      nauseas: json['nauseas'] as int,
      mareos: json['mareos'] as int,
      sensacionIrrealidad: json['sensacionIrrealidad'] as int,
      inestabilidadHormigueos: json['inestabilidadHormigueos'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'palpitaciones': palpitaciones,
      'sudoracion': sudoracion,
      'temblores': temblores,
      'dificultadRespirar': dificultadRespirar,
      'ahogo': ahogo,
      'dolorPecho': dolorPecho,
      'nauseas': nauseas,
      'mareos': mareos,
      'sensacionIrrealidad': sensacionIrrealidad,
      'inestabilidadHormigueos': inestabilidadHormigueos,
    };
  }
}
