import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsave/auth/presentation/providers/auth_provider.dart';

class GoRouterNotifier extends ChangeNotifier {
  AuthStatus _authStatus;

  GoRouterNotifier(this._authStatus);

  AuthStatus get authStatus => _authStatus;

  set authStatus(AuthStatus value) {
    if (_authStatus == value) return;
    _authStatus = value;
    notifyListeners();
  }
}

final goRouterNotifierProvider = Provider<GoRouterNotifier>((ref) {
  final notifier = GoRouterNotifier(ref.read(authProvider).authStatus);
  ref.listen<AuthState>(authProvider, (previous, next) {
    notifier.authStatus = next.authStatus;
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});
