import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsave/registro_estado_animo/domain/datasources/registro_estado_animo_datasource.dart';
import 'package:mindsave/registro_estado_animo/domain/repositories/registro_estado_animo_repository.dart';
import 'package:mindsave/registro_estado_animo/infrastructure/datasources/api_datasource.dart';
import 'package:mindsave/registro_estado_animo/infrastructure/repositories/registro_estado_animo_repository_impl.dart';
import 'package:mindsave/shared/presentation/providers/authenticated_http_client_provider.dart';

final registroEstadoAnimoRepositoryProvider =
    Provider<RegistroEstadoAnimoRepository>((ref) {
      final httpClient = ref.watch(authenticatedHttpClientProvider);
      final RegistroEstadoAnimoDatasource localDatasource =
          RegistroEstadoDeAnimoAPIDatasource(httpClient: httpClient);
      return RegistroEstadoAnimoRepositoryImpl(localDatasource);
    });
