import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';

abstract class RegistroEstadoAnimoDatasource {
  Future<String> saveRegistroEstadoDeAnimo(
    RegistroEstadoAnimo registroEstadoAnimo,
  );

  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoCompleto({
    int page = 1,
    int limit = 10,
  });

  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoPendiente({
    int page = 1,
    int limit = 10,
  });

  Future<RegistroEstadoAnimo?> getRegistroEstadoDeAnimoById(String id);

  Future<void> editarRegistroEstadoDeAnimoDeHoy(
    RegistroEstadoAnimo registroEstadoAnimo,
  );

  Future<void> eliminarRegistroEstadoDeAnimoDeHoy(String id);
}
