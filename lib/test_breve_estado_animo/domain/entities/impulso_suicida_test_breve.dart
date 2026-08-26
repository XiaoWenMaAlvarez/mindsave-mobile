class ImpulsoSuicidaTestBreve {
  int pensamientosSuicidas;
  int deseosDeMorir;

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
  static final int scoreMax = 8;

  ImpulsoSuicidaTestBreve({
    this.pensamientosSuicidas = 0,
    this.deseosDeMorir = 0,
  }) : assert(
         pensamientosSuicidas >= valorMin &&
             pensamientosSuicidas <= valorMax &&
             deseosDeMorir >= valorMin &&
             deseosDeMorir <= valorMax,
         'Los valores deben estar entre $valorMin y $valorMax',
       );

  int get totalScore {
    return pensamientosSuicidas + deseosDeMorir;
  }

  String get result {
    if (deseosDeMorir >= 1) {
      return 'Debe llamar a un número de emergencias o acudir a un hospital';
    }
    if (pensamientosSuicidas >= 1) {
      return 'Se recomienda acudir a un profesional de la salud';
    }
    if (totalScore == 0) {
      return 'Pocos síntomas de impulso suicida o ninguno';
    }
    return 'Error en el cálculo del resultado de impulso suicida';
  }

  String get resultDescription {
    if (deseosDeMorir >= 1) {
      return '(1- 4) Toda puntuación de 1 o superior en el ítem de deseos de poner fin a la vida puede ser peligrosa, y se impone decididamente el tratamiento profesional. Si tiene algún deseo de quitarse la vida, debe llamar al número de emergencias y pedir tratamiento inmediatamente.';
    }
    if (pensamientosSuicidas >= 1) {
      return '(1-4) Las puntuaciones elevadas en el ítem de pensamientos suicidas no son raras si usted se siente deprimido o desanimado. La mayoría de las personas deprimidas tienen algún pensamiento de suicidio en algún momento. Estos pensamientos no suelen ser peligrosos a no ser que usted tenga planes de llevarlos a la práctica. No obstante, sería prudente que consultara a un profesional de la salud mental si tiene fantasías o impulsos suicidas o si los sentimientos de depresión y de desánimo han durado más de una semana o dos. Su vida es preciosa, y no le interesa jugar a la ruleta rusa con ella.';
    }
    if (totalScore == 0) {
      return '(0) Pocos síntomas de impulso suicida o ninguno';
    }
    return 'Error en el cálculo del resultado de impulso suicida';
  }

  factory ImpulsoSuicidaTestBreve.fromJson(Map<String, dynamic> json) {
    return ImpulsoSuicidaTestBreve(
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

  @override
  String toString() {
    return """
Test de impulsos suicidas (total: $totalScore).
- ¿Tiene algún pensamiento de suicidarse?: $pensamientosSuicidas
- ¿Quisiera poner fin a su vida?: $deseosDeMorir
""";
  }
}
