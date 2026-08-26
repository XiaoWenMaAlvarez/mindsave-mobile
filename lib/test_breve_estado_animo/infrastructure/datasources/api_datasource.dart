import 'package:dio/dio.dart';

import 'package:prueba/shared/infrastructure/http/authenticated_http_client.dart';
import 'package:prueba/test_breve_estado_animo/domain/datasources/test_breve_estado_de_animo_datasource.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/test_breve_estado_de_animo.dart';
import 'package:prueba/test_breve_estado_animo/infrastructure/models/models.dart';
import '../mappers/test_breve_estado_de_animo_mapper.dart';

class TestBreveEstadoDeAnimoAPIDatasource
    extends TestBreveEstadoDeAnimoDatasource {
  static final _readCachePattern = RegExp(
    r'/api/test-breve-estado-de-animo/by-(?:year|date)/',
  );

  final AuthenticatedHttpClient httpClient;

  Dio get dio => httpClient.dio;

  TestBreveEstadoDeAnimoAPIDatasource({required this.httpClient});

  TestBreveEstadoDeAnimo _fromJsonToEntity(Map<String, dynamic> json) {
    TestBreveEstadoDeAnimoResponse testBreveEstadoDeAnimoResponse =
        TestBreveEstadoDeAnimoResponse.fromJson(json);
    TestBreveEstadoDeAnimo testBreveEstadoDeAnimoEntity =
        TestBreveEstadoDeAnimoMapper.testBreveEstadoDeAnimoResponseToEntity(
          testBreveEstadoDeAnimoResponse,
        );
    return testBreveEstadoDeAnimoEntity;
  }

  Map<String, dynamic> _fromEntityToJson(
    TestBreveEstadoDeAnimo testBreveEstadoDeAnimoEntity,
  ) {
    TestBreveEstadoDeAnimoResponse testBreveResponse =
        TestBreveEstadoDeAnimoMapper.testBreveEstadoDeAnimoEntityToResponse(
          testBreveEstadoDeAnimoEntity,
        );
    Map<String, dynamic> testBreveResponseJSON = testBreveResponse.toJson();
    return testBreveResponseJSON;
  }

  @override
  Future<void> saveTestBreveEstadoDeAnimo(
    TestBreveEstadoDeAnimo nvoTestBreveEstadoDeAnimo,
  ) async {
    Map<String, dynamic> nvoTestBreveJson = _fromEntityToJson(
      nvoTestBreveEstadoDeAnimo,
    );

    final response = await dio.post(
      "/api/test-breve-estado-de-animo/",
      data: {...nvoTestBreveJson},
    );

    if (response.statusCode != 201) {
      throw Exception("Error al guardar el test breve estado de ánimo");
    }

    await httpClient.invalidate(_readCachePattern);
    return;
  }

  @override
  Future<List<TestBreveEstadoDeAnimo>> getTestBreveEstadoDeAnimoByYear(
    int year,
  ) async {
    final response = await dio.get(
      "/api/test-breve-estado-de-animo/by-year/$year",
    );

    final List<Map<String, dynamic>> testsBreveEstadoDeAnimoResponseJson =
        List<Map<String, dynamic>>.from(response.data);

    final List<TestBreveEstadoDeAnimo> testsBreveEstadoDeAnimoEntities =
        testsBreveEstadoDeAnimoResponseJson
            .map(
              (Map<String, dynamic> testBreveResponse) =>
                  _fromJsonToEntity(testBreveResponse),
            )
            .toList();

    return testsBreveEstadoDeAnimoEntities;
  }

  @override
  Future<TestBreveEstadoDeAnimo?> getTodayTestBreveEstadoDeAnimo() async {
    final today = DateTime.now();
    final year = today.year;
    final month = today.month;
    final day = today.day;
    final response = await dio.get(
      "/api/test-breve-estado-de-animo/by-date/$year/$month/$day",
    );
    if (response.data == null) return null;
    return _fromJsonToEntity(response.data);
  }

  @override
  Future<void> editarTestBreveEstadoDeAnimoDeHoy(
    TestBreveEstadoDeAnimo testBreveEstadoDeAnimo,
  ) async {
    Map<String, dynamic> nvoTestBreveJson = _fromEntityToJson(
      testBreveEstadoDeAnimo,
    );

    final response = await dio.put(
      "/api/test-breve-estado-de-animo/",
      data: {...nvoTestBreveJson},
    );

    if (response.statusCode != 200) {
      throw Exception("Error al editar el test breve estado de ánimo");
    }

    await httpClient.invalidate(_readCachePattern);
    return;
  }

  @override
  Future<void> eliminarTestBreveEstadoDeAnimoDeHoy() async {
    final today = DateTime.now();
    final year = today.year;
    final month = today.month;
    final day = today.day;
    await dio.delete("/api/test-breve-estado-de-animo/$year/$month/$day");
    await httpClient.invalidate(_readCachePattern);
    return;
  }
}
