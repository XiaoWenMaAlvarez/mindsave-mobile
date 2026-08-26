import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/externalizacion_de_voces/domain/repositories/externalizacion_de_voces_repository.dart';
import 'package:prueba/externalizacion_de_voces/infrastructure/datasources/externalizacion_de_voces_datasource_impl.dart';
import 'package:prueba/externalizacion_de_voces/infrastructure/repositories/externalizacion_de_voces_repository_impl.dart';
import 'package:prueba/shared/presentation/providers/authenticated_http_client_provider.dart';

final chatIaRepositoryProvider = Provider<ExternalizacionDeVocesRepository>((
  ref,
) {
  final httpClient = ref.watch(authenticatedHttpClientProvider);
  final ExternalizacionDeVocesDatasourceImpl
  externalizacionDeVocesDatasourceImpl = ExternalizacionDeVocesDatasourceImpl(
    httpClient: httpClient,
  );
  return ExternalizacionDeVocesRepositoryImpl(
    externalizacionDeVocesDatasourceImpl,
  );
});
