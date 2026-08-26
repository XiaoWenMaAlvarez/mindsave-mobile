class Pensamiento {
  String pensamientoNegativo;
  int porcentajeCreenciaAntes;
  int? porcentajeCreenciaDespues;
  List<bool> distorsion;
  String? pensamientoPositivo;
  int? porcentajeCreenciaPositivo;

  static List<String> listaDistorsiones = [
    "Pensamiento todo o nada",
    "Generalización excesiva",
    "Filtro mental",
    "Descartar lo positivo",
    "Saltar a conclusiones (lectura del pensamiento o adivinación del porvenir)",
    "Magnificación o minimización",
    "Razonamiento emocional",
    'Afirmaciones del tipo "debería"',
    "Poner etiquetas",
    "Inculpación (autoinculpación o inculpación de los demás)",
  ];

  static List<String> detalleListaDistorsiones = [
    "Usted considera las cosas en categorías absolutas, o blanco o negro.",
    "Toma un hecho negativo aislado por una pauta interminable de derrotas: «Esto pasa siempre».",
    "Usted da vueltas a lo negativo y pasa por alto lo positivo.",
    "Se empeña en que sus cualidades positivas no cuentan.",
    "Usted salta a conclusiones que no se justifican con los hechos, da por supuesto que la gente reacciona negativamente ante usted o predice que las cosas saldrán mal.",
    "Usted hincha las cosas desproporcionadamente o bien empequeñece su importancia.",
    "Razona en función de cómo se siente, diciéndose, por ejemplo: «Me siento idiota, así que debo serlo de verdad».",
    "Utiliza verbos del tipo «Debería», «No debería », «Tendría que» y «No tendría que».",
    "En vez de decirse: «He cometido un error», dice: «Soy un idiota » o «Soy un perdedor».",
    "En vez de detectar la causa de un problema, usted asigna culpabilidades. Se culpa a sí mismo de algo que no fue responsabilidad suya o culpa a los demás, negando el papel de usted mismo en el problema.",
  ];

  bool get isPending {
    return pensamientoPositivo == null ||
        porcentajeCreenciaDespues == null ||
        porcentajeCreenciaPositivo == null;
  }

  Pensamiento({
    required this.pensamientoNegativo,
    required this.porcentajeCreenciaAntes,
  }) : distorsion = [for (int i = 0; i < listaDistorsiones.length; i++) false];

  Pensamiento.fromMapper({
    required this.pensamientoNegativo,
    required this.distorsion,
    required this.porcentajeCreenciaAntes,
    required this.porcentajeCreenciaDespues,
    required this.pensamientoPositivo,
    required this.porcentajeCreenciaPositivo,
  });

  Pensamiento.fromJson(Map<String, dynamic> json)
    : pensamientoNegativo = json["pensamientoNegativo"],
      porcentajeCreenciaAntes = json["porcentajeCreenciaAntes"],
      porcentajeCreenciaDespues = json["porcentajeCreenciaDespues"],
      distorsion = List<bool>.from(json["distorsion"]),
      pensamientoPositivo = json["pensamientoPositivo"],
      porcentajeCreenciaPositivo = json["porcentajeCreenciaPositivo"];

  Map<String, dynamic> toJson() {
    return {
      'pensamientoNegativo': pensamientoNegativo,
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
      'pensamientoPositivo': pensamientoPositivo,
      'porcentajeCreenciaPositivo': porcentajeCreenciaPositivo,
      'distorsion': distorsion,
    };
  }

  String get _identificarDistorsiones {
    String resultado = "";
    for (int i = 0; i < distorsion.length; i++) {
      if (distorsion[i]) {
        resultado +=
            "${listaDistorsiones[i]} - ${detalleListaDistorsiones[i]}\n";
      }
    }
    return resultado;
  }

  @override
  String toString() {
    return """
Pensamiento.
Pensamiento negativo: $pensamientoNegativo
Porcentaje de creencia del pensamiento negativo (antes): $porcentajeCreenciaAntes
Porcentaje de creencia del pensamiento negativo (después): $porcentajeCreenciaDespues
Distorsiones identificadas: $_identificarDistorsiones
Pensamiento positivo: $pensamientoPositivo
Porcentaje de creencia del pensamiento positivo: $porcentajeCreenciaPositivo
""";
  }
}
