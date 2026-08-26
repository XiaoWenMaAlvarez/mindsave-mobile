import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prueba/registro_estado_animo/domain/datasources/registro_estado_animo_datasource.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';

import 'package:flutter/foundation.dart';

void logJson(Map<String, dynamic> json) {
  const encoder = JsonEncoder.withIndent('  ');
  final pretty = encoder.convert(json);
  debugPrint(pretty, wrapWidth: 1024);
}

class RegistroEstadoDeAnimoLocalDatasource
    extends RegistroEstadoAnimoDatasource {
  late Future<SharedPreferences> preferencesStore;

  Future<SharedPreferences> initSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  RegistroEstadoDeAnimoLocalDatasource() {
    preferencesStore = initSharedPreferences();
  }

  @override
  Future<String> saveRegistroEstadoDeAnimo(
    RegistroEstadoAnimo registroEstadoAnimo,
  ) async {
    final localStorage = await preferencesStore;
    List<String> listaRegistrosEstadoAnimoCodificados =
        localStorage.getStringList("registrosEstadosAnimo") ?? [];

    registroEstadoAnimo.id = await _getNewId();
    Map<String, dynamic> registroEstadoAnimoJson = registroEstadoAnimo.toJson();
    logJson(registroEstadoAnimoJson);
    String registroEstadoAnimoCodificado = jsonEncode(registroEstadoAnimoJson);

    listaRegistrosEstadoAnimoCodificados.add(registroEstadoAnimoCodificado);
    localStorage.setStringList(
      "registrosEstadosAnimo",
      listaRegistrosEstadoAnimoCodificados,
    );
    return registroEstadoAnimo.id;
  }

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoPendiente({
    int page = 1,
    int limit = 10,
  }) async {
    final localStorage = await preferencesStore;
    List<String> listaRegistrosEstadoAnimoCodificados =
        localStorage.getStringList("registrosEstadosAnimo") ?? [];

    List<Map<String, dynamic>> listaRegistrosEstadoAnimoJson = List.from(
      listaRegistrosEstadoAnimoCodificados.map(
        (String registroCodificado) => jsonDecode(registroCodificado),
      ),
    );

    List<RegistroEstadoAnimo> listaRegistrosEstadoAnimo = List.from(
      listaRegistrosEstadoAnimoJson.map(
        (Map<String, dynamic> registroJson) =>
            RegistroEstadoAnimo.fromJson(registroJson),
      ),
    );

    return listaRegistrosEstadoAnimo
        .where((reg) => reg.grupoEmociones1.porcentajeCreenciaDespues == null)
        .skip(page * limit - limit)
        .take(limit)
        .toList();
  }

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoCompleto({
    int page = 1,
    int limit = 10,
  }) async {
    final localStorage = await preferencesStore;
    List<String> listaRegistrosEstadoAnimoCodificados =
        localStorage.getStringList("registrosEstadosAnimo") ?? [];

    List<Map<String, dynamic>> listaRegistrosEstadoAnimoJson = List.from(
      listaRegistrosEstadoAnimoCodificados.map(
        (String registroCodificado) => jsonDecode(registroCodificado),
      ),
    );

    List<RegistroEstadoAnimo> listaRegistrosEstadoAnimo = List.from(
      listaRegistrosEstadoAnimoJson.map(
        (Map<String, dynamic> registroJson) =>
            RegistroEstadoAnimo.fromJson(registroJson),
      ),
    );

    return listaRegistrosEstadoAnimo
        .where((reg) => reg.grupoEmociones1.porcentajeCreenciaDespues != null)
        .skip(page * limit - limit)
        .take(limit)
        .toList();
  }

  @override
  Future<void> editarRegistroEstadoDeAnimoDeHoy(
    RegistroEstadoAnimo nvoRegistroEstadoAnimo,
  ) async {
    final localStorage = await preferencesStore;
    List<String> listaRegistrosEstadoAnimoCodificados =
        localStorage.getStringList("registrosEstadosAnimo") ?? [];

    List<Map<String, dynamic>> listaRegistrosEstadoAnimoJson = List.from(
      listaRegistrosEstadoAnimoCodificados.map(
        (String registroCodificado) => jsonDecode(registroCodificado),
      ),
    );

    List<RegistroEstadoAnimo> listaRegistrosEstadoAnimo = List.from(
      listaRegistrosEstadoAnimoJson.map(
        (Map<String, dynamic> registroJson) =>
            RegistroEstadoAnimo.fromJson(registroJson),
      ),
    );

    listaRegistrosEstadoAnimo = listaRegistrosEstadoAnimo.map((
      RegistroEstadoAnimo registroEstadoAnimo,
    ) {
      if (registroEstadoAnimo.id != nvoRegistroEstadoAnimo.id) {
        return registroEstadoAnimo;
      }
      return nvoRegistroEstadoAnimo;
    }).toList();

    listaRegistrosEstadoAnimoJson = List.from(
      listaRegistrosEstadoAnimo.map(
        (RegistroEstadoAnimo registroEstadoAnimo) =>
            registroEstadoAnimo.toJson(),
      ),
    );

    listaRegistrosEstadoAnimoCodificados = List.from(
      listaRegistrosEstadoAnimoJson.map(
        (Map<String, dynamic> registroJson) => jsonEncode(registroJson),
      ),
    );

    await localStorage.setStringList(
      "registrosEstadosAnimo",
      listaRegistrosEstadoAnimoCodificados,
    );

    return;
  }

  @override
  Future<void> eliminarRegistroEstadoDeAnimoDeHoy(String id) async {
    final localStorage = await preferencesStore;
    List<String> listaRegistrosEstadoAnimoCodificados =
        localStorage.getStringList("registrosEstadosAnimo") ?? [];

    List<Map<String, dynamic>> listaRegistrosEstadoAnimoJson = List.from(
      listaRegistrosEstadoAnimoCodificados.map(
        (String registroCodificado) => jsonDecode(registroCodificado),
      ),
    );

    List<RegistroEstadoAnimo> listaRegistrosEstadoAnimo = List.from(
      listaRegistrosEstadoAnimoJson.map(
        (Map<String, dynamic> registroJson) =>
            RegistroEstadoAnimo.fromJson(registroJson),
      ),
    );

    listaRegistrosEstadoAnimo.removeWhere(
      (RegistroEstadoAnimo registroEstadoAnimo) => registroEstadoAnimo.id == id,
    );

    listaRegistrosEstadoAnimoJson = List.from(
      listaRegistrosEstadoAnimo.map(
        (RegistroEstadoAnimo registroEstadoAnimo) =>
            registroEstadoAnimo.toJson(),
      ),
    );

    listaRegistrosEstadoAnimoCodificados = List.from(
      listaRegistrosEstadoAnimoJson.map(
        (Map<String, dynamic> registroJson) => jsonEncode(registroJson),
      ),
    );

    localStorage.setStringList(
      "registrosEstadosAnimo",
      listaRegistrosEstadoAnimoCodificados,
    );

    return;
  }

  Future<String> _getNewId() async {
    final localStorage = await preferencesStore;
    List<String> listaRegistrosEstadoAnimoCodificados =
        localStorage.getStringList("registrosEstadosAnimo") ?? [];

    if (listaRegistrosEstadoAnimoCodificados.isEmpty) return "1";

    Map<String, dynamic> lastRecord = jsonDecode(
      listaRegistrosEstadoAnimoCodificados.last,
    );

    String lastId = lastRecord["id"];

    final newId = int.parse(lastId) + 1;

    return newId.toString();
  }

  @override
  Future<RegistroEstadoAnimo?> getRegistroEstadoDeAnimoById(String id) async {
    final localStorage = await preferencesStore;
    List<String> listaRegistrosEstadoAnimoCodificados =
        localStorage.getStringList("registrosEstadosAnimo") ?? [];

    List<Map<String, dynamic>> listaRegistrosEstadoAnimoJson = List.from(
      listaRegistrosEstadoAnimoCodificados.map(
        (String registroCodificado) => jsonDecode(registroCodificado),
      ),
    );

    List<RegistroEstadoAnimo> listaRegistrosEstadoAnimo = List.from(
      listaRegistrosEstadoAnimoJson.map(
        (Map<String, dynamic> registroJson) =>
            RegistroEstadoAnimo.fromJson(registroJson),
      ),
    );

    if (listaRegistrosEstadoAnimo.any((RegistroEstadoAnimo r) => r.id == id)) {
      return listaRegistrosEstadoAnimo.firstWhere(
        (RegistroEstadoAnimo r) => r.id == id,
      );
    }
    return null;
  }
}
