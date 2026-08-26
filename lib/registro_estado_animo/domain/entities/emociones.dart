abstract class Emociones {
  List<String> get listaEmociones;
  List<bool> get seleccionEmociones;
  int? get porcentajeCreenciaAntes;
  int? get porcentajeCreenciaDespues;
  String? get isIncomplete;
  bool get isPending;
  set porcentajeCreenciaAntes(int? value);
  set porcentajeCreenciaDespues(int? value);
  Map<String, dynamic> toJson();
}

class GrupoEmociones1 extends Emociones {
  @override
  List<String> listaEmociones = [
    "Triste",
    "Melancólico",
    "Deprimido",
    "Decaído",
    "Infeliz",
  ];
  @override
  List<bool> seleccionEmociones;
  bool triste;
  bool melancolico;
  bool deprimido;
  bool decaido;
  bool infeliz;
  @override
  int? porcentajeCreenciaAntes;
  @override
  int? porcentajeCreenciaDespues;

  GrupoEmociones1({
    List<bool>? seleccionEmociones,
    this.triste = false,
    this.melancolico = false,
    this.deprimido = false,
    this.decaido = false,
    this.infeliz = false,
    this.porcentajeCreenciaAntes,
    this.porcentajeCreenciaDespues,
  }) : seleccionEmociones =
           seleccionEmociones ?? [false, false, false, false, false];

  @override
  String? get isIncomplete {
    if (porcentajeCreenciaAntes == null ||
        porcentajeCreenciaAntes! < 0 ||
        porcentajeCreenciaAntes! > 100) {
      return "Error en el porcentaje de intensidad del grupo de emociones 1";
    }
    if (porcentajeCreenciaAntes == 0 &&
        seleccionEmociones.any((bool seleccion) => seleccion == true)) {
      return "Grupo de emociones 1: Se seleccionó al menos una emoción pero se indicó un 0 en el % de intensidad";
    }
    if (seleccionEmociones.every((bool seleccion) => seleccion == false) &&
        porcentajeCreenciaAntes! > 0) {
      return "Grupo de emociones 1: No se seleccionó ninguna emoción pero se indicó un % mayor a 0 en la intensidad";
    }
    return null;
  }

  @override
  bool get isPending {
    return porcentajeCreenciaDespues == null;
  }

  factory GrupoEmociones1.fromJson(Map<String, dynamic> json) {
    return GrupoEmociones1(
      seleccionEmociones: [
        json['triste'],
        json['melancolico'],
        json['deprimido'],
        json['decaido'],
        json['infeliz'],
      ],
      triste: json['triste'],
      melancolico: json['melancolico'],
      deprimido: json['deprimido'],
      decaido: json['decaido'],
      infeliz: json['infeliz'],
      porcentajeCreenciaAntes: json['porcentajeCreenciaAntes'],
      porcentajeCreenciaDespues: json['porcentajeCreenciaDespues'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "triste": seleccionEmociones[0],
      "melancolico": seleccionEmociones[1],
      "deprimido": seleccionEmociones[2],
      "decaido": seleccionEmociones[3],
      "infeliz": seleccionEmociones[4],
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
    };
  }

  @override
  String toString() {
    return """
Grupo de emociones 1.
Lista de emociones: ${triste ? "Triste" : ""} ${melancolico ? "Melancólico" : ""} ${deprimido ? "Deprimido" : ""} ${decaido ? "Decaído}" : ""} ${infeliz ? "Infeliz" : ""}
Porcentaje de creencia (antes): $porcentajeCreenciaAntes
Porcentaje de creencia (después): $porcentajeCreenciaDespues
""";
  }
}

class GrupoEmociones2 extends Emociones {
  @override
  List<String> listaEmociones = [
    "Angustiado",
    "Preocupado",
    "Con pánico",
    "Nervioso",
    "Asustado",
  ];
  @override
  List<bool> seleccionEmociones;
  bool angustiado;
  bool preocupado;
  bool conPanico;
  bool nervioso;
  bool asustado;
  @override
  int? porcentajeCreenciaAntes;
  @override
  int? porcentajeCreenciaDespues;

  GrupoEmociones2({
    List<bool>? seleccionEmociones,
    this.angustiado = false,
    this.preocupado = false,
    this.conPanico = false,
    this.nervioso = false,
    this.asustado = false,
    this.porcentajeCreenciaAntes,
    this.porcentajeCreenciaDespues,
  }) : seleccionEmociones =
           seleccionEmociones ?? [false, false, false, false, false];

  @override
  String? get isIncomplete {
    if (porcentajeCreenciaAntes == null ||
        porcentajeCreenciaAntes! < 0 ||
        porcentajeCreenciaAntes! > 100) {
      return "Error en el porcentaje de intensidad del grupo de emociones 2";
    }
    if (porcentajeCreenciaAntes == 0 &&
        seleccionEmociones.any((bool seleccion) => seleccion == true)) {
      return "Grupo de emociones 2: Se seleccionó al menos una emoción pero se indicó un 0 en el % de intensidad";
    }
    if (seleccionEmociones.every((bool seleccion) => seleccion == false) &&
        porcentajeCreenciaAntes! > 0) {
      return "Grupo de emociones 2: No se seleccionó ninguna emoción pero se indicó un % mayor a 0 en la intensidad";
    }
    return null;
  }

  @override
  bool get isPending {
    return porcentajeCreenciaDespues == null;
  }

  factory GrupoEmociones2.fromJson(Map<String, dynamic> json) {
    return GrupoEmociones2(
      seleccionEmociones: [
        json['angustiado'],
        json['preocupado'],
        json['conPanico'],
        json['nervioso'],
        json['asustado'],
      ],
      angustiado: json['angustiado'],
      preocupado: json['preocupado'],
      conPanico: json['conPanico'],
      nervioso: json['nervioso'],
      asustado: json['asustado'],
      porcentajeCreenciaAntes: json['porcentajeCreenciaAntes'],
      porcentajeCreenciaDespues: json['porcentajeCreenciaDespues'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "angustiado": seleccionEmociones[0],
      "preocupado": seleccionEmociones[1],
      "conPanico": seleccionEmociones[2],
      "nervioso": seleccionEmociones[3],
      "asustado": seleccionEmociones[4],
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
    };
  }

  @override
  String toString() {
    return """
Grupo de emociones 1.
Lista de emociones: ${angustiado ? "Angustiado" : ""} ${preocupado ? "Preocupado" : ""} ${conPanico ? "Con pánico" : ""} ${nervioso ? "Nervioso" : ""} ${asustado ? "Asustado" : ""}
Porcentaje de creencia (antes): $porcentajeCreenciaAntes
Porcentaje de creencia (después): $porcentajeCreenciaDespues
""";
  }
}

class GrupoEmociones3 extends Emociones {
  @override
  List<String> listaEmociones = [
    "Culpable",
    "Con remordimiento",
    "Malo",
    "Avergonzado",
  ];
  @override
  List<bool> seleccionEmociones;
  bool culpable;
  bool conRemordimiento;
  bool malo;
  bool avergonzado;
  @override
  int? porcentajeCreenciaAntes;
  @override
  int? porcentajeCreenciaDespues;

  GrupoEmociones3({
    List<bool>? seleccionEmociones,
    this.culpable = false,
    this.conRemordimiento = false,
    this.malo = false,
    this.avergonzado = false,
    this.porcentajeCreenciaAntes,
    this.porcentajeCreenciaDespues,
  }) : seleccionEmociones = seleccionEmociones ?? [false, false, false, false];

  @override
  String? get isIncomplete {
    if (porcentajeCreenciaAntes == null ||
        porcentajeCreenciaAntes! < 0 ||
        porcentajeCreenciaAntes! > 100) {
      return "Error en el porcentaje de intensidad del grupo de emociones 3";
    }
    if (porcentajeCreenciaAntes == 0 &&
        seleccionEmociones.any((bool seleccion) => seleccion == true)) {
      return "Grupo de emociones 3: Se seleccionó al menos una emoción pero se indicó un 0 en el % de intensidad";
    }
    if (seleccionEmociones.every((bool seleccion) => seleccion == false) &&
        porcentajeCreenciaAntes! > 0) {
      return "Grupo de emociones 3: No se seleccionó ninguna emoción pero se indicó un % mayor a 0 en la intensidad";
    }
    return null;
  }

  @override
  bool get isPending {
    return porcentajeCreenciaDespues == null;
  }

  factory GrupoEmociones3.fromJson(Map<String, dynamic> json) {
    return GrupoEmociones3(
      seleccionEmociones: [
        json['culpable'],
        json['conRemordimiento'],
        json['malo'],
        json['avergonzado'],
      ],
      culpable: json['culpable'],
      conRemordimiento: json['conRemordimiento'],
      malo: json['malo'],
      avergonzado: json['avergonzado'],
      porcentajeCreenciaAntes: json['porcentajeCreenciaAntes'],
      porcentajeCreenciaDespues: json['porcentajeCreenciaDespues'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "culpable": seleccionEmociones[0],
      "conRemordimiento": seleccionEmociones[1],
      "malo": seleccionEmociones[2],
      "avergonzado": seleccionEmociones[3],
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
    };
  }

  @override
  String toString() {
    return """
Grupo de emociones 3.
Lista de emociones: ${culpable ? "Culpable" : ""} ${conRemordimiento ? "Con remordimiento" : ""} ${malo ? "Malo" : ""} ${avergonzado ? "Avergonzado" : ""}
Porcentaje de creencia (antes): $porcentajeCreenciaAntes
Porcentaje de creencia (después): $porcentajeCreenciaDespues
""";
  }
}

class GrupoEmociones4 extends Emociones {
  @override
  List<String> listaEmociones = [
    "Inferior",
    "Sin valor",
    "Inadecuado",
    "Deficiente",
    "Incompetente",
  ];
  @override
  List<bool> seleccionEmociones;
  bool inferior;
  bool sinValor;
  bool inadecuado;
  bool deficiente;
  bool incompetente;
  @override
  int? porcentajeCreenciaAntes;
  @override
  int? porcentajeCreenciaDespues;

  GrupoEmociones4({
    List<bool>? seleccionEmociones,
    this.inferior = false,
    this.sinValor = false,
    this.inadecuado = false,
    this.deficiente = false,
    this.incompetente = false,
    this.porcentajeCreenciaAntes,
    this.porcentajeCreenciaDespues,
  }) : seleccionEmociones =
           seleccionEmociones ?? [false, false, false, false, false];

  @override
  String? get isIncomplete {
    if (porcentajeCreenciaAntes == null ||
        porcentajeCreenciaAntes! < 0 ||
        porcentajeCreenciaAntes! > 100) {
      return "Error en el porcentaje de intensidad del grupo de emociones 4";
    }
    if (porcentajeCreenciaAntes == 0 &&
        seleccionEmociones.any((bool seleccion) => seleccion == true)) {
      return "Grupo de emociones 4: Se seleccionó al menos una emoción pero se indicó un 0 en el % de intensidad";
    }
    if (seleccionEmociones.every((bool seleccion) => seleccion == false) &&
        porcentajeCreenciaAntes! > 0) {
      return "Grupo de emociones 4: No se seleccionó ninguna emoción pero se indicó un % mayor a 0 en la intensidad";
    }
    return null;
  }

  @override
  bool get isPending {
    return porcentajeCreenciaDespues == null;
  }

  factory GrupoEmociones4.fromJson(Map<String, dynamic> json) {
    return GrupoEmociones4(
      seleccionEmociones: [
        json['inferior'],
        json['sinValor'],
        json['inadecuado'],
        json['deficiente'],
        json['incompetente'],
      ],
      inferior: json['inferior'],
      sinValor: json['sinValor'],
      inadecuado: json['inadecuado'],
      deficiente: json['deficiente'],
      incompetente: json['incompetente'],
      porcentajeCreenciaAntes: json['porcentajeCreenciaAntes'],
      porcentajeCreenciaDespues: json['porcentajeCreenciaDespues'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "inferior": seleccionEmociones[0],
      "sinValor": seleccionEmociones[1],
      "inadecuado": seleccionEmociones[2],
      "deficiente": seleccionEmociones[3],
      "incompetente": seleccionEmociones[4],
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
    };
  }

  @override
  String toString() {
    return """
Grupo de emociones 4.
Lista de emociones: ${inferior ? "Inferior" : ""} ${sinValor ? "Sin valor" : ""} ${inadecuado ? "Inadecuado" : ""} ${deficiente ? "Deficiente" : ""} ${incompetente ? "Incompetente" : ""}
Porcentaje de creencia (antes): $porcentajeCreenciaAntes
Porcentaje de creencia (después): $porcentajeCreenciaDespues
""";
  }
}

class GrupoEmociones5 extends Emociones {
  @override
  List<String> listaEmociones = [
    "Solitario",
    "No querido",
    "No deseado",
    "Rechazado",
    "Solo",
    "Abandonado",
  ];
  @override
  List<bool> seleccionEmociones;
  bool solitario;
  bool noQuerido;
  bool noDeseado;
  bool rechazado;
  bool solo;
  bool abandonado;
  @override
  int? porcentajeCreenciaAntes;
  @override
  int? porcentajeCreenciaDespues;

  GrupoEmociones5({
    List<bool>? seleccionEmociones,
    this.solitario = false,
    this.noQuerido = false,
    this.noDeseado = false,
    this.rechazado = false,
    this.solo = false,
    this.abandonado = false,
    this.porcentajeCreenciaAntes,
    this.porcentajeCreenciaDespues,
  }) : seleccionEmociones =
           seleccionEmociones ?? [false, false, false, false, false, false];

  @override
  String? get isIncomplete {
    if (porcentajeCreenciaAntes == null ||
        porcentajeCreenciaAntes! < 0 ||
        porcentajeCreenciaAntes! > 100) {
      return "Error en el porcentaje de intensidad del grupo de emociones 5";
    }
    if (porcentajeCreenciaAntes == 0 &&
        seleccionEmociones.any((bool seleccion) => seleccion == true)) {
      return "Grupo de emociones 5: Se seleccionó al menos una emoción pero se indicó un 0 en el % de intensidad";
    }
    if (seleccionEmociones.every((bool seleccion) => seleccion == false) &&
        porcentajeCreenciaAntes! > 0) {
      return "Grupo de emociones 5: No se seleccionó ninguna emoción pero se indicó un % mayor a 0 en la intensidad";
    }
    return null;
  }

  @override
  bool get isPending {
    return porcentajeCreenciaDespues == null;
  }

  factory GrupoEmociones5.fromJson(Map<String, dynamic> json) {
    return GrupoEmociones5(
      seleccionEmociones: [
        json['solitario'],
        json['noQuerido'],
        json['noDeseado'],
        json['rechazado'],
        json['solo'],
        json['abandonado'],
      ],
      solitario: json['solitario'],
      noQuerido: json['noQuerido'],
      noDeseado: json['noDeseado'],
      rechazado: json['rechazado'],
      solo: json['solo'],
      abandonado: json['abandonado'],
      porcentajeCreenciaAntes: json['porcentajeCreenciaAntes'],
      porcentajeCreenciaDespues: json['porcentajeCreenciaDespues'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "solitario": seleccionEmociones[0],
      "noQuerido": seleccionEmociones[1],
      "noDeseado": seleccionEmociones[2],
      "rechazado": seleccionEmociones[3],
      "solo": seleccionEmociones[4],
      "abandonado": seleccionEmociones[5],
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
    };
  }

  @override
  String toString() {
    return """
Grupo de emociones 5.
Lista de emociones: ${solitario ? "Solitario" : ""} ${noQuerido ? "No querido" : ""} ${noDeseado ? "No deseado" : ""} ${rechazado ? "Rechazado" : ""} ${solo ? "Solo" : ""} ${abandonado ? "Abandonado" : ""}
Porcentaje de creencia (antes): $porcentajeCreenciaAntes
Porcentaje de creencia (después): $porcentajeCreenciaDespues
""";
  }
}

class GrupoEmociones6 extends Emociones {
  @override
  List<String> listaEmociones = ["Turbado", "Tonto", "Humillado", "Apurado"];
  @override
  List<bool> seleccionEmociones;
  bool turbado;
  bool tonto;
  bool humillado;
  bool apurado;
  @override
  int? porcentajeCreenciaAntes;
  @override
  int? porcentajeCreenciaDespues;

  GrupoEmociones6({
    List<bool>? seleccionEmociones,
    this.turbado = false,
    this.tonto = false,
    this.humillado = false,
    this.apurado = false,
    this.porcentajeCreenciaAntes,
    this.porcentajeCreenciaDespues,
  }) : seleccionEmociones = seleccionEmociones ?? [false, false, false, false];

  @override
  String? get isIncomplete {
    if (porcentajeCreenciaAntes == null ||
        porcentajeCreenciaAntes! < 0 ||
        porcentajeCreenciaAntes! > 100) {
      return "Error en el porcentaje de intensidad del grupo de emociones 6";
    }
    if (porcentajeCreenciaAntes == 0 &&
        seleccionEmociones.any((bool seleccion) => seleccion == true)) {
      return "Grupo de emociones 6: Se seleccionó al menos una emoción pero se indicó un 0 en el % de intensidad";
    }
    if (seleccionEmociones.every((bool seleccion) => seleccion == false) &&
        porcentajeCreenciaAntes! > 0) {
      return "Grupo de emociones 6: No se seleccionó ninguna emoción pero se indicó un % mayor a 0 en la intensidad";
    }
    return null;
  }

  @override
  bool get isPending {
    return porcentajeCreenciaDespues == null;
  }

  factory GrupoEmociones6.fromJson(Map<String, dynamic> json) {
    return GrupoEmociones6(
      seleccionEmociones: [
        json['turbado'],
        json['tonto'],
        json['humillado'],
        json['apurado'],
      ],
      turbado: json['turbado'],
      tonto: json['tonto'],
      humillado: json['humillado'],
      apurado: json['apurado'],
      porcentajeCreenciaAntes: json['porcentajeCreenciaAntes'],
      porcentajeCreenciaDespues: json['porcentajeCreenciaDespues'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "turbado": seleccionEmociones[0],
      "tonto": seleccionEmociones[1],
      "humillado": seleccionEmociones[2],
      "apurado": seleccionEmociones[3],
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
    };
  }

  @override
  String toString() {
    return """
Grupo de emociones 6.
Lista de emociones: ${turbado ? "Turbado" : ""} ${tonto ? "Tonto" : ""} ${humillado ? "Humillado" : ""} ${apurado ? "Apurado" : ""}
Porcentaje de creencia (antes): $porcentajeCreenciaAntes
Porcentaje de creencia (después): $porcentajeCreenciaDespues
""";
  }
}

class GrupoEmociones7 extends Emociones {
  @override
  List<String> listaEmociones = [
    "Desesperanzado",
    "Desanimado",
    "Pesimista",
    "Descorazonado",
  ];
  @override
  List<bool> seleccionEmociones;
  bool desesperanzado;
  bool desanimado;
  bool pesimista;
  bool descorazonado;
  @override
  int? porcentajeCreenciaAntes;
  @override
  int? porcentajeCreenciaDespues;

  GrupoEmociones7({
    List<bool>? seleccionEmociones,
    this.desesperanzado = false,
    this.desanimado = false,
    this.pesimista = false,
    this.descorazonado = false,
    this.porcentajeCreenciaAntes,
    this.porcentajeCreenciaDespues,
  }) : seleccionEmociones = seleccionEmociones ?? [false, false, false, false];

  @override
  String? get isIncomplete {
    if (porcentajeCreenciaAntes == null ||
        porcentajeCreenciaAntes! < 0 ||
        porcentajeCreenciaAntes! > 100) {
      return "Error en el porcentaje de intensidad del grupo de emociones 7";
    }
    if (porcentajeCreenciaAntes == 0 &&
        seleccionEmociones.any((bool seleccion) => seleccion == true)) {
      return "Grupo de emociones 7: Se seleccionó al menos una emoción pero se indicó un 0 en el % de intensidad";
    }
    if (seleccionEmociones.every((bool seleccion) => seleccion == false) &&
        porcentajeCreenciaAntes! > 0) {
      return "Grupo de emociones 7: No se seleccionó ninguna emoción pero se indicó un % mayor a 0 en la intensidad";
    }
    return null;
  }

  @override
  bool get isPending {
    return porcentajeCreenciaDespues == null;
  }

  factory GrupoEmociones7.fromJson(Map<String, dynamic> json) {
    return GrupoEmociones7(
      seleccionEmociones: [
        json['desesperanzado'],
        json['desanimado'],
        json['pesimista'],
        json['descorazonado'],
      ],
      desesperanzado: json['desesperanzado'],
      desanimado: json['desanimado'],
      pesimista: json['pesimista'],
      descorazonado: json['descorazonado'],
      porcentajeCreenciaAntes: json['porcentajeCreenciaAntes'],
      porcentajeCreenciaDespues: json['porcentajeCreenciaDespues'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "desesperanzado": seleccionEmociones[0],
      "desanimado": seleccionEmociones[1],
      "pesimista": seleccionEmociones[2],
      "descorazonado": seleccionEmociones[3],
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
    };
  }

  @override
  String toString() {
    return """
Grupo de emociones 7.
Lista de emociones: ${desesperanzado ? "Desesperanzado" : ""} ${desanimado ? "Desanimado" : ""} ${pesimista ? "Pesimista" : ""} ${descorazonado ? "Descorazonado" : ""}
Porcentaje de creencia (antes): $porcentajeCreenciaAntes
Porcentaje de creencia (después): $porcentajeCreenciaDespues
""";
  }
}

class GrupoEmociones8 extends Emociones {
  @override
  List<String> listaEmociones = [
    "Frustrado",
    "Atascado",
    "Chasqueado",
    "Derrotado",
  ];
  @override
  List<bool> seleccionEmociones;
  bool frustrado;
  bool atascado;
  bool chasqueado;
  bool derrotado;
  @override
  int? porcentajeCreenciaAntes;
  @override
  int? porcentajeCreenciaDespues;

  GrupoEmociones8({
    List<bool>? seleccionEmociones,
    this.frustrado = false,
    this.atascado = false,
    this.chasqueado = false,
    this.derrotado = false,
    this.porcentajeCreenciaAntes,
    this.porcentajeCreenciaDespues,
  }) : seleccionEmociones = seleccionEmociones ?? [false, false, false, false];

  @override
  String? get isIncomplete {
    if (porcentajeCreenciaAntes == null ||
        porcentajeCreenciaAntes! < 0 ||
        porcentajeCreenciaAntes! > 100) {
      return "Error en el porcentaje de intensidad del grupo de emociones 8";
    }
    if (porcentajeCreenciaAntes == 0 &&
        seleccionEmociones.any((bool seleccion) => seleccion == true)) {
      return "Grupo de emociones 8: Se seleccionó al menos una emoción pero se indicó un 0 en el % de intensidad";
    }
    if (seleccionEmociones.every((bool seleccion) => seleccion == false) &&
        porcentajeCreenciaAntes! > 0) {
      return "Grupo de emociones 8: No se seleccionó ninguna emoción pero se indicó un % mayor a 0 en la intensidad";
    }
    return null;
  }

  @override
  bool get isPending {
    return porcentajeCreenciaDespues == null;
  }

  factory GrupoEmociones8.fromJson(Map<String, dynamic> json) {
    return GrupoEmociones8(
      seleccionEmociones: [
        json['frustrado'],
        json['atascado'],
        json['chasqueado'],
        json['derrotado'],
      ],
      frustrado: json['frustrado'],
      atascado: json['atascado'],
      chasqueado: json['chasqueado'],
      derrotado: json['derrotado'],
      porcentajeCreenciaAntes: json['porcentajeCreenciaAntes'],
      porcentajeCreenciaDespues: json['porcentajeCreenciaDespues'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "frustrado": seleccionEmociones[0],
      "atascado": seleccionEmociones[1],
      "chasqueado": seleccionEmociones[2],
      "derrotado": seleccionEmociones[3],
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
    };
  }

  @override
  String toString() {
    return """
Grupo de emociones 8.
Lista de emociones: ${frustrado ? "Frustrado" : ""} ${atascado ? "Atascado" : ""} ${chasqueado ? "Chasqueado" : ""} ${derrotado ? "Derrotado" : ""}
Porcentaje de creencia (antes): $porcentajeCreenciaAntes
Porcentaje de creencia (después): $porcentajeCreenciaDespues
""";
  }
}

class GrupoEmociones9 extends Emociones {
  @override
  List<String> listaEmociones = [
    "Airado",
    "Enfadado",
    "Resentido",
    "Molesto",
    "Irritado",
    "Trastornado",
    "Furioso",
  ];
  @override
  List<bool> seleccionEmociones;
  bool airado;
  bool enfadado;
  bool resentido;
  bool molesto;
  bool irritado;
  bool trastornado;
  bool furioso;
  @override
  int? porcentajeCreenciaAntes;
  @override
  int? porcentajeCreenciaDespues;

  GrupoEmociones9({
    List<bool>? seleccionEmociones,
    this.airado = false,
    this.enfadado = false,
    this.resentido = false,
    this.molesto = false,
    this.irritado = false,
    this.trastornado = false,
    this.furioso = false,
    this.porcentajeCreenciaAntes,
    this.porcentajeCreenciaDespues,
  }) : seleccionEmociones =
           seleccionEmociones ??
           [false, false, false, false, false, false, false];

  @override
  String? get isIncomplete {
    if (porcentajeCreenciaAntes == null ||
        porcentajeCreenciaAntes! < 0 ||
        porcentajeCreenciaAntes! > 100) {
      return "Error en el porcentaje de intensidad del grupo de emociones 9";
    }
    if (porcentajeCreenciaAntes == 0 &&
        seleccionEmociones.any((bool seleccion) => seleccion == true)) {
      return "Grupo de emociones 9: Se seleccionó al menos una emoción pero se indicó un 0 en el % de intensidad";
    }
    if (seleccionEmociones.every((bool seleccion) => seleccion == false) &&
        porcentajeCreenciaAntes! > 0) {
      return "Grupo de emociones 9: No se seleccionó ninguna emoción pero se indicó un % mayor a 0 en la intensidad";
    }
    return null;
  }

  @override
  bool get isPending {
    return porcentajeCreenciaDespues == null;
  }

  factory GrupoEmociones9.fromJson(Map<String, dynamic> json) {
    return GrupoEmociones9(
      seleccionEmociones: [
        json['airado'],
        json['enfadado'],
        json['resentido'],
        json['molesto'],
        json['irritado'],
        json['trastornado'],
        json['furioso'],
      ],
      airado: json['airado'],
      enfadado: json['enfadado'],
      resentido: json['resentido'],
      molesto: json['molesto'],
      irritado: json['irritado'],
      trastornado: json['trastornado'],
      furioso: json['furioso'],
      porcentajeCreenciaAntes: json['porcentajeCreenciaAntes'],
      porcentajeCreenciaDespues: json['porcentajeCreenciaDespues'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "airado": seleccionEmociones[0],
      "enfadado": seleccionEmociones[1],
      "resentido": seleccionEmociones[2],
      "molesto": seleccionEmociones[3],
      "irritado": seleccionEmociones[4],
      "trastornado": seleccionEmociones[5],
      "furioso": seleccionEmociones[6],
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
    };
  }

  @override
  String toString() {
    return """
Grupo de emociones 9.
Lista de emociones: ${airado ? "Airado" : ""} ${enfadado ? "Enfadado" : ""} ${resentido ? "Resentido" : ""} ${molesto ? "Molesto" : ""} ${irritado ? "Irritado" : ""} ${trastornado ? "Trastornado" : ""} ${furioso ? "Furioso" : ""}
Porcentaje de creencia (antes): $porcentajeCreenciaAntes
Porcentaje de creencia (después): $porcentajeCreenciaDespues
""";
  }
}

class GrupoEmocionesPersonalizadas extends Emociones {
  @override
  List<String> listaEmociones;
  @override
  List<bool> seleccionEmociones;
  @override
  int? porcentajeCreenciaAntes;
  @override
  int? porcentajeCreenciaDespues;

  GrupoEmocionesPersonalizadas({
    List<String>? listaEmociones,
    List<bool>? seleccionEmociones,
    int? porcentajeCreenciaAntes,
    this.porcentajeCreenciaDespues,
  }) : listaEmociones = listaEmociones ?? [],
       seleccionEmociones = seleccionEmociones ?? [],
       porcentajeCreenciaAntes = porcentajeCreenciaAntes ?? 0;

  @override
  String? get isIncomplete {
    if (listaEmociones.isNotEmpty &&
        (porcentajeCreenciaAntes == null ||
            porcentajeCreenciaAntes! < 0 ||
            porcentajeCreenciaAntes! > 100)) {
      return "Error en el porcentaje de creencia del grupo de emociones personalizadas";
    }
    if (listaEmociones.isNotEmpty && porcentajeCreenciaAntes == 0) {
      return "Grupo de emociones personalizadas: Se seleccionó al menos una emoción pero se indicó un 0 en el % de intensidad";
    }
    if (listaEmociones.isEmpty && (porcentajeCreenciaAntes != 0)) {
      return "Grupo de emociones 10: No se seleccionó ninguna emoción pero se indicó un % de intensidad";
    }
    return null;
  }

  @override
  bool get isPending {
    return porcentajeCreenciaDespues == null;
  }

  factory GrupoEmocionesPersonalizadas.fromJson(Map<String, dynamic> json) {
    return GrupoEmocionesPersonalizadas(
      listaEmociones: List<String>.from(json['listaEmociones']),
      seleccionEmociones: List<bool>.from([
        ...json['listaEmociones'].map((x) => true),
      ]),
      porcentajeCreenciaAntes: json['porcentajeCreenciaAntes'],
      porcentajeCreenciaDespues: json['porcentajeCreenciaDespues'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "listaEmociones": listaEmociones,
      'porcentajeCreenciaAntes': porcentajeCreenciaAntes,
      'porcentajeCreenciaDespues': porcentajeCreenciaDespues,
    };
  }

  @override
  String toString() {
    return """
Grupo de emociones personalizadas.
Lista de emociones: ${listaEmociones.join(", ")}
Porcentaje de creencia (antes): $porcentajeCreenciaAntes
Porcentaje de creencia (después): $porcentajeCreenciaDespues
""";
  }
}
