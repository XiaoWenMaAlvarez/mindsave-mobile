import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

typedef CurrentTime = DateTime Function();
typedef UnauthorizedCallback = FutureOr<void> Function();

class AuthenticatedHttpClient {
  static const defaultCacheTtl = Duration(minutes: 5);

  final Dio dio;
  final MemCacheStore _cacheStore;

  AuthenticatedHttpClient({
    required String baseUrl,
    required String sessionId,
    required String accessToken,
    Duration cacheTtl = defaultCacheTtl,
    CurrentTime? currentTime,
    Dio? dio,
    MemCacheStore? cacheStore,
    UnauthorizedCallback? onUnauthorized,
  }) : dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)),
       _cacheStore = cacheStore ?? MemCacheStore() {
    final cacheOptions = CacheOptions(
      store: _cacheStore,
      policy: CachePolicy.refreshForceCache,
      hitCacheOnNetworkFailure: true,
      keyBuilder: sessionCacheKeyBuilder(sessionId),
    );

    this.dio.options.baseUrl = baseUrl;
    if (accessToken.isEmpty) {
      this.dio.options.headers.remove('Authorization');
    } else {
      this.dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }

    if (onUnauthorized != null) {
      this.dio.interceptors.add(_UnauthorizedInterceptor(onUnauthorized));
    }
    this.dio.interceptors.add(
      _FreshSessionCacheInterceptor(
        cacheOptions: cacheOptions,
        cacheTtl: cacheTtl,
        currentTime: currentTime ?? DateTime.now,
      ),
    );
    this.dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  Future<void> invalidate(
    RegExp pathPattern, {
    Map<String, String?>? queryParameters,
  }) async {
    try {
      await _cacheStore.deleteFromPath(
        pathPattern,
        queryParams: queryParameters,
      );
    } catch (_) {
      // Cache invalidation must not turn a successful mutation into an error.
    }
  }

  Future<void> clear() async {
    try {
      await _cacheStore.clean();
    } catch (_) {
      // Cache is an optimization; a cleanup failure must not block the app.
    }
  }

  Future<void> close() async {
    dio.close(force: true);
    await _cacheStore.close();
  }
}

class _UnauthorizedInterceptor extends Interceptor {
  final UnauthorizedCallback onUnauthorized;
  Future<void>? _notificationInProgress;

  _UnauthorizedInterceptor(this.onUnauthorized);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        await _notifyUnauthorized();
      } catch (_) {
        // Preserve the original HTTP error if session cleanup fails.
      }
    }

    handler.next(err);
  }

  Future<void> _notifyUnauthorized() {
    final activeNotification = _notificationInProgress;
    if (activeNotification != null) return activeNotification;

    late final Future<void> notification;
    notification = Future<void>.sync(onUnauthorized).whenComplete(() {
      if (identical(_notificationInProgress, notification)) {
        _notificationInProgress = null;
      }
    });
    _notificationInProgress = notification;
    return notification;
  }
}

CacheKeyBuilder sessionCacheKeyBuilder(String sessionId) {
  return ({required Uri url, Map<String, String>? headers, Object? body}) {
    return '$sessionId|GET|${normalizeCacheUri(url)}';
  };
}

Uri normalizeCacheUri(Uri uri) {
  final sortedKeys = uri.queryParametersAll.keys.toList()..sort();
  final sortedParameters = <String, dynamic>{};

  for (final key in sortedKeys) {
    final values = [...uri.queryParametersAll[key]!]..sort();
    sortedParameters[key] = values.length == 1 ? values.single : values;
  }

  return uri.replace(
    queryParameters: sortedParameters.isEmpty ? null : sortedParameters,
    fragment: '',
  );
}

class _FreshSessionCacheInterceptor extends Interceptor {
  final CacheOptions cacheOptions;
  final Duration cacheTtl;
  final CurrentTime currentTime;

  const _FreshSessionCacheInterceptor({
    required this.cacheOptions,
    required this.cacheTtl,
    required this.currentTime,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.method.toUpperCase() != 'GET' ||
        options.responseType == ResponseType.stream) {
      handler.next(options);
      return;
    }

    try {
      final key = cacheOptions.keyBuilder(
        url: options.uri,
        headers: options.headers.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
        body: options.data,
      );
      final cachedResponse = await cacheOptions.store!.get(key);

      if (cachedResponse != null &&
          currentTime().toUtc().difference(cachedResponse.responseDate) <
              cacheTtl) {
        final response = await cachedResponse.readContent(
          cacheOptions,
          readHeaders: true,
          readBody: true,
        );
        handler.resolve(response.toResponse(options, fromNetwork: false), true);
        return;
      }
    } catch (_) {
      // If reading cache fails, continue through the network normally.
    }

    handler.next(options);
  }
}
