class SentimientosAnsiedadEmocionalTestBreve {
  int angustiado;
  int nervioso;
  int preocupado;
  int asustado;
  int tenso;

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
  static final int scoreMax = 20;

  SentimientosAnsiedadEmocionalTestBreve({
    this.angustiado = 0,
    this.nervioso = 0,
    this.preocupado = 0,
    this.asustado = 0,
    this.tenso = 0,
  }) : assert(
         angustiado >= valorMin &&
             angustiado <= valorMax &&
             nervioso >= valorMin &&
             nervioso <= valorMax &&
             preocupado >= valorMin &&
             preocupado <= valorMax &&
             asustado >= valorMin &&
             asustado <= valorMax &&
             tenso >= valorMin &&
             tenso <= valorMax,
         'Los valores deben estar entre $valorMin y $valorMax',
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

  String get resultDescription {
    if (totalScore <= 1) {
      return "(0-1) Pocos síntomas de ansiedad o ninguno: ésta es la puntuación más baja posible. Parece que ahora mismo no lo acosa prácticamente ninguna ansiedad o preocupación, o ninguna en absoluto.";
    }
    if (totalScore <= 4) {
      return '(2-4) Ansiedad marginal: aunque sólo tiene unos pocos síntomas de ansiedad, las herramientas que se exponen en esta aplicación podrían resultarle útiles.';
    }
    if (totalScore <= 8) {
      return '(5-8) Ansiedad leve: esta puntuación no es especialmente alta, pero la ansiedad puede estar provocando incomodidades o perturbaciones significativas.';
    }
    if (totalScore <= 12) {
      return '(9-12) Ansiedad moderada: ha respondido moderadamente o más en al menos dos ítem. Ésta es decididamente una ansiedad suficiente para provocar perturbaciones, y se puede mejorar mucho.';
    }
    if (totalScore <= 16) {
      return '(13-16) Ansiedad grave: esta puntuación indica unos sentimientos fuertes de ansiedad. Usted puede estar muy incómodo, como mínimo. La buena noticia es que el pronóstico es muy positivo, si usted está dispuesto a aportar algo de valor y de trabajo duro.';
    }
    if (totalScore <= 20) {
      return '(17-20) Ansiedad extrema: parece que lo acosan sentimientos intensos de ansiedad, y probablemente sufre usted mucho. Las herramientas de esta aplicación, además de la terapia profesional, pueden ayudarle muchísimo.';
    }
    return 'Error en el cálculo del resultado de ansiedad emocional';
  }

  factory SentimientosAnsiedadEmocionalTestBreve.fromJson(
    Map<String, dynamic> json,
  ) {
    return SentimientosAnsiedadEmocionalTestBreve(
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

  @override
  String toString() {
    return """
Test de ansiedad emocional (total: $totalScore).
- Angustiado: $angustiado
- Nervioso: $nervioso
- Preocupado: $preocupado
- Asustado o aprensivo: $asustado
- Tenso o con los nervios de punta: $tenso
""";
  }
}
