import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/auth/presentation/providers/auth_provider.dart';
import 'package:prueba/config/constants/environment.dart';
import 'package:prueba/shared/infrastructure/http/authenticated_http_client.dart';

final authenticatedHttpClientProvider = Provider<AuthenticatedHttpClient>((
  ref,
) {
  final session = ref.watch(
    authProvider.select(
      (state) => (
        userId: state.user?.id ?? 'unauthenticated',
        accessToken: state.user?.token ?? '',
      ),
    ),
  );

  final client = AuthenticatedHttpClient(
    baseUrl: Environment.apiUrlBase,
    sessionId: session.userId,
    accessToken: session.accessToken,
    onUnauthorized: () => ref
        .read(authProvider.notifier)
        .logout('Tu sesión expiró. Inicia sesión nuevamente.'),
  );
  ref.onDispose(() => unawaited(client.close()));
  return client;
});
