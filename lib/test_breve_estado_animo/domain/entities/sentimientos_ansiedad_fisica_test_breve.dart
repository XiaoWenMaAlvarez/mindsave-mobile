class SentimientosAnsiedadFisicaTestBreve {
  int palpitaciones;
  int sudoracion;
  int temblores;
  int dificultadRespirar;
  int ahogo;
  int dolorPecho;
  int nauseas;
  int mareos;
  int sensacionIrrealidad;
  int inestabilidadHormigueos;

  static final int valorMin = 0;
  static final int valorMax = 4;

  static final List<String> etiquetaPuntuacion = [
    "Nada en absoluto",
    "Algo",
    "Moderadamente",
    "Mucho",
    "Muchísimo",
  ];

  static final int scoreMin = 0;
  static final int scoreMax = 40;

  SentimientosAnsiedadFisicaTestBreve({
    this.palpitaciones = 0,
    this.sudoracion = 0,
    this.temblores = 0,
    this.dificultadRespirar = 0,
    this.ahogo = 0,
    this.dolorPecho = 0,
    this.nauseas = 0,
    this.mareos = 0,
    this.sensacionIrrealidad = 0,
    this.inestabilidadHormigueos = 0,
  }) : assert(
         palpitaciones >= valorMin &&
             palpitaciones <= valorMax &&
             sudoracion >= valorMin &&
             sudoracion <= valorMax &&
             temblores >= valorMin &&
             temblores <= valorMax &&
             dificultadRespirar >= valorMin &&
             dificultadRespirar <= valorMax &&
             ahogo >= valorMin &&
             ahogo <= valorMax &&
             dolorPecho >= valorMin &&
             dolorPecho <= valorMax &&
             nauseas >= valorMin &&
             nauseas <= valorMax &&
             mareos >= valorMin &&
             mareos <= valorMax &&
             sensacionIrrealidad >= valorMin &&
             sensacionIrrealidad <= valorMax &&
             inestabilidadHormigueos >= valorMin &&
             inestabilidadHormigueos <= valorMax,
         'Los valores deben estar entre $valorMin y $valorMax',
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
    if (totalScore <= 40) {
      return 'Síntomas físicos de ansiedad extrema';
    }
    return 'Error en el cálculo de síntomas físicos de ansiedad';
  }

  String get resultDescription {
    if (totalScore <= 2) {
      return '(0-2) Pocos síntomas físicos de ansiedad o ninguno';
    }
    if (totalScore <= 6) {
      return '(3-6) Síntomas físicos de ansiedad marginal';
    }
    if (totalScore <= 10) {
      return '(7-10) Síntomas físicos de ansiedad leve';
    }
    if (totalScore <= 20) {
      return '(11-20) Síntomas físicos de ansiedad moderada';
    }
    if (totalScore <= 30) {
      return '(21-30) Síntomas físicos de ansiedad severa';
    }
    if (totalScore <= 40) {
      return '(31-40) Síntomas físicos de ansiedad extrema';
    }
    return 'Error en el cálculo de síntomas físicos de ansiedad';
  }

  factory SentimientosAnsiedadFisicaTestBreve.fromJson(
    Map<String, dynamic> json,
  ) {
    return SentimientosAnsiedadFisicaTestBreve(
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

  @override
  String toString() {
    return """
Test de ansiedad física (total: $totalScore)
- Palpitaciones, pulso acelerado o taquicardia: $palpitaciones
- Sudores, escalofríos o sofocos: $sudoracion
- Temblores o estremecimientos: $temblores
- Falta de aliento o dificultades para respirar: $dificultadRespirar
- Sensación de ahogo: $ahogo
- Dolor o tensión en el pecho: $dolorPecho
- Estómago revuelto o náuseas: $nauseas
- Sensación de mareo o de que todo da vueltas: $mareos
- Sensación de que usted es irreal o de que el mundo es irreal: $sensacionIrrealidad
- Sensación de insensibilidad o de hormigueos: $inestabilidadHormigueos
""";
  }
}
