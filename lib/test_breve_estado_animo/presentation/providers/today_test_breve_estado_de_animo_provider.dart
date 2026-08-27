import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsave/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/test_breve_estado_animo/presentation/providers/providers.dart';

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
    scheduleNextMidnightCheck();
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  Future<void> setTestBreveRealizadoHoy({bool forceRefresh = false}) async {
    final current = state;
    final now = DateTime.now();
    if (!forceRefresh &&
        current != null &&
        _isSameDay(current.fechaCreacion, now)) {
      return;
    }
    _setIsLoading(true);
    try {
      state = await _getTodayTestBreveEstadoDeAnimo();
    } finally {
      _setIsLoading(false);
    }
  }

  void localSetTestBreveRealizadoHoy(TestBreveEstadoDeAnimo nvoTest) {
    state = nvoTest;
    scheduleNextMidnightCheck();
  }

  void eliminarTestBreveRealizadoHoy() {
    state = null;
  }

  void scheduleNextMidnightCheck() {
    _timer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    if (durationUntilMidnight > Duration.zero) {
      _timer = Timer(durationUntilMidnight, () async {
        state = null;
        try {
          state = await _getTodayTestBreveEstadoDeAnimo();
        } catch (_) {
          state = null;
        }
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
