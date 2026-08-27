import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsave/auth/infrastructure/datasources/auth_datasource_impl.dart';
import 'package:mindsave/auth/infrastructure/errors/auth_errors.dart';

void main() {
  dotenv.loadFromString(envString: 'API_URL_BASE=https://api.example.com');

  test('reenvía la validación al endpoint con el email indicado', () async {
    final adapter = _RecordingAuthAdapter();
    final datasource = AuthDatasourceImpl();
    datasource.dio.httpClientAdapter = adapter;

    final error = await datasource.resendValidationEmail('test@example.com');

    expect(error, isNull);
    expect(adapter.request?.method, 'POST');
    expect(
      adapter.request?.uri.toString(),
      'https://api.example.com/api/auth/resend-validation-email',
    );
    expect(adapter.request?.data, {'email': 'test@example.com'});
  });

  test(
    'detecta fallos de conexion de red y connectionError correctamente',
    () async {
      final datasource = AuthDatasourceImpl();
      datasource.dio.httpClientAdapter = _ErrorAuthAdapter(
        DioExceptionType.connectionError,
      );

      expect(
        () => datasource.login('test@example.com', '123456'),
        throwsA(isA<ConnectionTimeout>()),
      );

      final regError = await datasource.register(
        'test@example.com',
        '123456',
        'User',
      );
      expect(regError, 'Conexión perdida');

      final resetError = await datasource.resetPassword('test@example.com');
      expect(resetError, 'Conexión perdida');

      final resendError = await datasource.resendValidationEmail(
        'test@example.com',
      );
      expect(resendError, 'Conexión perdida');
    },
  );
}

class _ErrorAuthAdapter implements HttpClientAdapter {
  final DioExceptionType exceptionType;

  _ErrorAuthAdapter(this.exceptionType);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(requestOptions: options, type: exceptionType);
  }

  @override
  void close({bool force = false}) {}
}

class _RecordingAuthAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({'success': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
