import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedYearNotifier extends Notifier<int> {
  @override
  int build() => DateTime.now().year;

  void select(int value) => state = value;
}

final selectedYearProvider = NotifierProvider<SelectedYearNotifier, int>(
  SelectedYearNotifier.new,
);
