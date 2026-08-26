import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedMenuItemNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int value) => state = value;
}

final selectedMenuItemProvider =
    NotifierProvider<SelectedMenuItemNotifier, int>(
      SelectedMenuItemNotifier.new,
    );
