import 'package:prueba/registro_estado_animo/domain/datasources/registro_estado_animo_datasource.dart';
import 'package:prueba/registro_estado_animo/domain/entities/registro_estado_animo.dart';
import 'package:prueba/registro_estado_animo/domain/repositories/registro_estado_animo_repository.dart';

class RegistroEstadoAnimoRepositoryImpl extends RegistroEstadoAnimoRepository {
  final RegistroEstadoAnimoDatasource datasource;

  RegistroEstadoAnimoRepositoryImpl(this.datasource);

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoPendiente({
    int page = 1,
    int limit = 10,
  }) {
    return datasource.getRegistroEstadoDeAnimoPendiente(
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoCompleto({
    int page = 1,
    int limit = 10,
  }) {
    return datasource.getRegistroEstadoDeAnimoCompleto(
      page: page,
      limit: limit,
    );
  }

  @override
  Future<String> saveRegistroEstadoDeAnimo(
    RegistroEstadoAnimo registroEstadoAnimo,
  ) {
    return datasource.saveRegistroEstadoDeAnimo(registroEstadoAnimo);
  }

  @override
  Future<void> editarRegistroEstadoDeAnimoDeHoy(
    RegistroEstadoAnimo registroEstadoAnimo,
  ) {
    return datasource.editarRegistroEstadoDeAnimoDeHoy(registroEstadoAnimo);
  }

  @override
  Future<void> eliminarRegistroEstadoDeAnimoDeHoy(String id) {
    return datasource.eliminarRegistroEstadoDeAnimoDeHoy(id);
  }

  @override
  Future<RegistroEstadoAnimo?> getRegistroEstadoDeAnimoById(String id) {
    return datasource.getRegistroEstadoDeAnimoById(id);
  }
}
