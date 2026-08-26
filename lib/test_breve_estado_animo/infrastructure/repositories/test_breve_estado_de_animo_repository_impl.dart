import 'package:prueba/test_breve_estado_animo/domain/datasources/test_breve_estado_de_animo_datasource.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/test_breve_estado_de_animo.dart';
import 'package:prueba/test_breve_estado_animo/domain/repositories/test_breve_estado_de_animo_repository.dart';

class TestBreveEstadoDeAnimoRepositoryImpl
    extends TestBreveEstadoDeAnimoRepository {
  final TestBreveEstadoDeAnimoDatasource datasource;

  TestBreveEstadoDeAnimoRepositoryImpl(this.datasource);

  @override
  Future<void> saveTestBreveEstadoDeAnimo(
    TestBreveEstadoDeAnimo nvoTestBreveEstadoDeAnimo,
  ) async {
    await datasource.saveTestBreveEstadoDeAnimo(nvoTestBreveEstadoDeAnimo);
  }

  @override
  Future<List<TestBreveEstadoDeAnimo>> getTestBreveEstadoDeAnimoByYear(
    int year,
  ) async {
    return await datasource.getTestBreveEstadoDeAnimoByYear(year);
  }

  @override
  Future<TestBreveEstadoDeAnimo?> getTodayTestBreveEstadoDeAnimo() async {
    return await datasource.getTodayTestBreveEstadoDeAnimo();
  }

  @override
  Future<void> eliminarTestBreveEstadoDeAnimoDeHoy() async {
    return await datasource.eliminarTestBreveEstadoDeAnimoDeHoy();
  }

  @override
  Future<void> editarTestBreveEstadoDeAnimoDeHoy(
    TestBreveEstadoDeAnimo testBreveEstadoDeAnimo,
  ) async {
    return await datasource.editarTestBreveEstadoDeAnimoDeHoy(
      testBreveEstadoDeAnimo,
    );
  }
}
