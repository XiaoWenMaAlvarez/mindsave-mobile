class DepresionTestBreveResponse {
  final int tristeza;
  final int desesperanza;
  final int bajaAutoestima;
  final int faltaDeValor;
  final int perdidaDeSatisfaccion;

  DepresionTestBreveResponse({
    required this.tristeza,
    required this.desesperanza,
    required this.bajaAutoestima,
    required this.faltaDeValor,
    required this.perdidaDeSatisfaccion,
  }) : assert(
         tristeza >= 0 &&
             tristeza <= 5 &&
             desesperanza >= 0 &&
             desesperanza <= 5 &&
             bajaAutoestima >= 0 &&
             bajaAutoestima <= 5 &&
             faltaDeValor >= 0 &&
             faltaDeValor <= 5 &&
             perdidaDeSatisfaccion >= 0 &&
             perdidaDeSatisfaccion <= 5,
         'Los valores deben estar entre 0 y 5',
       );

  int get totalScore {
    return tristeza +
        desesperanza +
        bajaAutoestima +
        faltaDeValor +
        perdidaDeSatisfaccion;
  }

  String get result {
    if (totalScore <= 1) {
      return 'Pocos síntomas de depresión o ninguno';
    }
    if (totalScore <= 4) {
      return 'Síntomas de depresión marginal';
    }
    if (totalScore <= 8) {
      return 'Síntomas de depresión leve';
    }
    if (totalScore <= 12) {
      return 'Síntomas de depresión moderada';
    }
    if (totalScore <= 16) {
      return 'Síntomas de depresión severa';
    }
    if (totalScore <= 20) {
      return 'Síntomas de depresión extrema';
    }
    return 'Error en el cálculo del resultado de depresión';
  }

  factory DepresionTestBreveResponse.fromJson(Map<String, dynamic> json) {
    return DepresionTestBreveResponse(
      tristeza: json['tristeza'] as int,
      desesperanza: json['desesperanza'] as int,
      bajaAutoestima: json['bajaAutoestima'] as int,
      faltaDeValor: json['faltaDeValor'] as int,
      perdidaDeSatisfaccion: json['perdidaDeSatisfaccion'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tristeza': tristeza,
      'desesperanza': desesperanza,
      'bajaAutoestima': bajaAutoestima,
      'faltaDeValor': faltaDeValor,
      'perdidaDeSatisfaccion': perdidaDeSatisfaccion,
    };
  }
}
