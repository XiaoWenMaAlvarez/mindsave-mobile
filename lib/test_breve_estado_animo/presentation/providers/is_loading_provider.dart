import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsLoadingNotifier extends Notifier<bool> {
  int _activeOperations = 0;

  @override
  bool build() => false;

  void setLoading(bool value) {
    if (value) {
      _activeOperations++;
    } else if (_activeOperations > 0) {
      _activeOperations--;
    }
    state = _activeOperations > 0;
  }
}

final isLoadingProvider = NotifierProvider<IsLoadingNotifier, bool>(
  IsLoadingNotifier.new,
);

typedef SetIsLoading = void Function(bool value);
