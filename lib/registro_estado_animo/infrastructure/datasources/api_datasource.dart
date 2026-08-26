import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mindsave/registro_estado_animo/domain/datasources/registro_estado_animo_datasource.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/shared/infrastructure/http/authenticated_http_client.dart';

import 'package:flutter/foundation.dart';

void logJson(Map<String, dynamic> json) {
  const encoder = JsonEncoder.withIndent('  ');
  final pretty = encoder.convert(json);
  debugPrint(pretty, wrapWidth: 1024);
}

class RegistroEstadoDeAnimoAPIDatasource extends RegistroEstadoAnimoDatasource {
  static final _readCachePattern = RegExp(r'/api/registro-estado-de-animo/');

  final AuthenticatedHttpClient httpClient;

  Dio get dio => httpClient.dio;

  RegistroEstadoDeAnimoAPIDatasource({required this.httpClient});

  @override
  Future<String> saveRegistroEstadoDeAnimo(
    RegistroEstadoAnimo registroEstadoAnimo,
  ) async {
    Map<String, dynamic> registroEstadoAnimoJson = registroEstadoAnimo.toJson();
    logJson(registroEstadoAnimoJson);

    final response = await dio.post(
      "/api/registro-estado-de-animo/",
      data: {...registroEstadoAnimoJson},
    );

    if (response.statusCode != 201) {
      throw Exception("Error al guardar el registro de estado de ánimo");
    }

    await httpClient.invalidate(_readCachePattern);
    return response.data["id"];
  }

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoCompleto({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await dio.get(
      "/api/registro-estado-de-animo/completos/?page=$page&limit=$limit",
    );
    if (response.data == null) return [];
    if (response.data["results"] == null) return [];

    List<Map<String, dynamic>> resultsJson = List<Map<String, dynamic>>.from(
      response.data["results"],
    );

    final List<RegistroEstadoAnimo> results = List<RegistroEstadoAnimo>.from(
      resultsJson.map(
        (Map<String, dynamic> json) => RegistroEstadoAnimo.fromJson(json),
      ),
    );

    return results;
  }

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoPendiente({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await dio.get(
      "/api/registro-estado-de-animo/pendientes/?page=$page&limit=$limit",
    );
    if (response.data == null) return [];
    if (response.data["results"] == null) return [];

    List<Map<String, dynamic>> resultsJson = List<Map<String, dynamic>>.from(
      response.data["results"],
    );

    final List<RegistroEstadoAnimo> results = List<RegistroEstadoAnimo>.from(
      resultsJson.map(
        (Map<String, dynamic> json) => RegistroEstadoAnimo.fromJson(json),
      ),
    );

    return results;
  }

  @override
  Future<void> editarRegistroEstadoDeAnimoDeHoy(
    RegistroEstadoAnimo nvoRegistroEstadoAnimo,
  ) async {
    Map<String, dynamic> nvoRegistroJson = nvoRegistroEstadoAnimo.toJson();

    final response = await dio.put(
      "/api/registro-estado-de-animo/",
      data: {...nvoRegistroJson},
    );

    if (response.statusCode != 200) {
      throw Exception("Error al editar el test breve estado de ánimo");
    }

    await httpClient.invalidate(_readCachePattern);
    return;
  }

  @override
  Future<void> eliminarRegistroEstadoDeAnimoDeHoy(String id) async {
    await dio.delete("/api/registro-estado-de-animo/$id");
    await httpClient.invalidate(_readCachePattern);
    return;
  }

  @override
  Future<RegistroEstadoAnimo?> getRegistroEstadoDeAnimoById(String id) async {
    final response = await dio.get("/api/registro-estado-de-animo/$id");
    if (response.data == null) return null;
    return RegistroEstadoAnimo.fromJson(response.data);
  }
}
