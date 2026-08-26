import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) => state = value;
}

final isLoadingProvider = NotifierProvider<IsLoadingNotifier, bool>(
  IsLoadingNotifier.new,
);

typedef SetIsLoading = void Function(bool value);
