class DepresionTestBreve {
  int tristeza;
  int desesperanza;
  int bajaAutoestima;
  int faltaDeValor;
  int perdidaDeSatisfaccion;

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

  DepresionTestBreve({
    this.tristeza = 0,
    this.desesperanza = 0,
    this.bajaAutoestima = 0,
    this.faltaDeValor = 0,
    this.perdidaDeSatisfaccion = 0,
  }) : assert(
         tristeza >= valorMin &&
             tristeza <= valorMax &&
             desesperanza >= valorMin &&
             desesperanza <= valorMax &&
             bajaAutoestima >= valorMin &&
             bajaAutoestima <= valorMax &&
             faltaDeValor >= valorMin &&
             faltaDeValor <= valorMax &&
             perdidaDeSatisfaccion >= valorMin &&
             perdidaDeSatisfaccion <= valorMax,
         'Los valores deben estar entre $valorMin y $valorMax',
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

  String get resultDescription {
    if (totalScore <= 1) {
      return '(0-1) Pocos síntomas de depresión o ninguno: ésta es la mejor puntuación posible. No parece que la depresión sea un problema para usted en estos momentos. Si ha estado deprimido, ésta es la puntuación a la que debe aspirar. Puede tardar algún tiempo en llegar hasta aquí, pero, si persevera, puede hacerlo realidad.';
    }
    if (totalScore <= 4) {
      return '(2-4) Depresión marginal: tiene unos síntomas mínimos de depresión y seguramente no necesite más que una puesta a punto mental. Esta puntuación suele ser indicativa de unos altibajos normales. Con todo, tener una puntuación en este intervalo es como tener unas décimas de fiebre. La fiebre no es alta, pero no tiene usted tanta energía y motivación como quisiera. Además, si se permite que una depresión marginal se prolongue, suele ir a peor. Si bien esta aplicación se centra principalmente en la ansiedad, muchas de las técnicas pueden ser también muy útiles para la depresión.';
    }
    if (totalScore <= 8) {
      return '(5-8) Depresión leve: tiene varios síntomas leves de depresión o un par de síntomas más fuertes. Si bien este grado de depresión es sólo leve, es más que suficiente para despojarle de su autoestima y de su alegría de vivir la vida.';
    }
    if (totalScore <= 12) {
      return '(9-12) Depresión moderada: éste es un nivel significativo de depresión. Muchas personas tienen puntuaciones en este intervalo durante meses e incluso durante años seguidos. Si bien el pronóstico de recuperación es muy positivo, lo triste es que muchas personas deprimidas no se dan cuenta de ello o no lo creen. Sienten que son verdaderamente personas anormales o inferiores y creen que simplemente no están destinadas a sentirse jamás felices o realizadas. Espero que no caiga nunca en este esquema mental porque funcionaría a modo de profecía autocumplidora. Cuando usted se rinde, nada cambia. Entonces, llega a la conclusión de que la situación es verdaderamente desesperada. Estoy convencido de que todas las personas que padecen depresión pueden recuperarse y conocer de nuevo la alegría y la autoestima.';
    }
    if (totalScore <= 16) {
      return '(13-16) Depresión grave: las personas que tienen puntuaciones en este intervalo suelen sentirse terriblemente abatidas, desanimadas y sin valor, y les parece que nada las satisface ni les vale la pena. Este grado de sufrimiento puede resultar abrumador, y difícil de entender por los demás. Cuando usted intenta explicar a sus amigos o a su familia cómo se siente, ellos quizá le digan que se anime y que mire el lado bueno de las cosas. Naturalmente, los consejos superficiales de esta clase suelen empeorar las cosas porque usted se siente rechazado y cree que no le tienen en cuenta. En realidad, el pronóstico de recuperación de la depresión grave es excelente, aunque usted no lo sienta así ahora mismo.';
    }
    if (totalScore <= 20) {
      return '(17-20) Depresión extrema: este grado de depresión indica un sufrimiento casi increíble, pero el pronóstico de mejora y recuperación sigue siendo muy positivo. Si bien las técnicas de autoayuda pueden resultar muy útiles, también puede ser preciso un tratamiento profesional. Es muy semejante a estar perdido en el bosque. Usted se siente asustado porque está oscureciendo y hace frío y no sabe cómo encontrar el camino de vuelta a su casa. En muchos casos, un buen guía al que usted aprecie y en el que confíe podrá enseñarle el camino por el que se pondrá a salvo.';
    }
    return 'Error en el cálculo del resultado de depresión';
  }

  factory DepresionTestBreve.fromJson(Map<String, dynamic> json) {
    return DepresionTestBreve(
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

  @override
  String toString() {
    return """
Test de depresión (total: $totalScore).
- Triste o decaído: $tristeza
- Desanimado o desesperanzado: $desesperanza
- Autoestima baja: $bajaAutoestima
- Sensación de no valer o de ser inadecuado: $faltaDeValor
- Pérdida de placer o de satisfacción con la vida: $perdidaDeSatisfaccion
""";
  }
}
