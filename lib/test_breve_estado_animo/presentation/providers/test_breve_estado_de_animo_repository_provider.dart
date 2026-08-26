import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/shared/presentation/providers/authenticated_http_client_provider.dart';
import 'package:prueba/test_breve_estado_animo/domain/datasources/test_breve_estado_de_animo_datasource.dart';
import 'package:prueba/test_breve_estado_animo/domain/repositories/test_breve_estado_de_animo_repository.dart';
import 'package:prueba/test_breve_estado_animo/infrastructure/repositories/test_breve_estado_de_animo_repository_impl.dart';
import '../../infrastructure/datasources/api_datasource.dart';

final testBreveEstadoDeAnimoRepositoryProvider =
    Provider<TestBreveEstadoDeAnimoRepository>((ref) {
      final httpClient = ref.watch(authenticatedHttpClientProvider);
      final TestBreveEstadoDeAnimoDatasource localDatasource =
          TestBreveEstadoDeAnimoAPIDatasource(httpClient: httpClient);
      return TestBreveEstadoDeAnimoRepositoryImpl(localDatasource);
    });
