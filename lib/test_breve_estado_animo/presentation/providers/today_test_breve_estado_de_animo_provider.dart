import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:prueba/test_breve_estado_animo/presentation/providers/providers.dart';

typedef GetTodayTestBreveEstadoDeAnimo =
    Future<TestBreveEstadoDeAnimo?> Function();

class TodayTestBreveEstadoDeAnimoNotifier
    extends Notifier<TestBreveEstadoDeAnimo?> {
  Timer? _timer;
  late GetTodayTestBreveEstadoDeAnimo _getTodayTestBreveEstadoDeAnimo;
  late SetIsLoading _setIsLoading;

  @override
  TestBreveEstadoDeAnimo? build() {
    _getTodayTestBreveEstadoDeAnimo = ref
        .watch(testBreveEstadoDeAnimoRepositoryProvider)
        .getTodayTestBreveEstadoDeAnimo;
    _setIsLoading = ref.read(isLoadingProvider.notifier).setLoading;
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  Future<void> setTestBreveRealizadoHoy() async {
    if (state != null) return;
    _setIsLoading(true);
    try {
      state = await _getTodayTestBreveEstadoDeAnimo();
    } finally {
      _setIsLoading(false);
    }
  }

  void localSetTestBreveRealizadoHoy(TestBreveEstadoDeAnimo nvoTest) {
    state = nvoTest;
  }

  void eliminarTestBreveRealizadoHoy() {
    state = null;
  }

  void scheduleNextMidnightCheck() {
    _timer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final durationUntilMidnight = nextMidnight.difference(now);

    if (durationUntilMidnight > Duration.zero) {
      _timer = Timer(durationUntilMidnight, () {
        setTestBreveRealizadoHoy();
        scheduleNextMidnightCheck();
      });
    }
  }
}

final todayTestBreveEstadoDeAnimoProvider =
    NotifierProvider<
      TodayTestBreveEstadoDeAnimoNotifier,
      TestBreveEstadoDeAnimo?
    >(TodayTestBreveEstadoDeAnimoNotifier.new);
