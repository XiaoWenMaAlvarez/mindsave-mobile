import 'package:prueba/test_breve_estado_animo/domain/entities/test_breve_estado_de_animo.dart';

abstract class TestBreveEstadoDeAnimoRepository {
  //CRUD

  Future<void> saveTestBreveEstadoDeAnimo(
    TestBreveEstadoDeAnimo testBreveEstadoDeAnimo,
  );

  Future<List<TestBreveEstadoDeAnimo>> getTestBreveEstadoDeAnimoByYear(
    int year,
  );

  Future<void> editarTestBreveEstadoDeAnimoDeHoy(
    TestBreveEstadoDeAnimo testBreveEstadoDeAnimo,
  );

  Future<void> eliminarTestBreveEstadoDeAnimoDeHoy();

  Future<TestBreveEstadoDeAnimo?> getTodayTestBreveEstadoDeAnimo();
}
