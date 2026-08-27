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
  int _generation = 0;

  @override
  TestBreveEstadoDeAnimo? build() {
    _generation++;
    _getTodayTestBreveEstadoDeAnimo = ref
        .watch(testBreveEstadoDeAnimoRepositoryProvider)
        .getTodayTestBreveEstadoDeAnimo;
    _setIsLoading = ref.read(isLoadingProvider.notifier).setLoading;
    ref.onDispose(() => _timer?.cancel());
    scheduleNextMidnightCheck();
    return null;
  }

  bool _isCurrent(int generation) => ref.mounted && generation == _generation;

  bool _isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  Future<String?> setTestBreveRealizadoHoy({bool forceRefresh = false}) async {
    final current = state;
    final now = DateTime.now();
    if (!forceRefresh &&
        current != null &&
        _isSameDay(current.fechaCreacion, now)) {
      return null;
    }
    final generation = _generation;
    final getToday = _getTodayTestBreveEstadoDeAnimo;
    _setIsLoading(true);
    try {
      final result = await getToday();
      if (!_isCurrent(generation)) return null;
      state = result;
      return null;
    } catch (_) {
      return _isCurrent(generation)
          ? 'No se pudo consultar la evaluación de hoy. Inténtalo nuevamente.'
          : null;
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
      final generation = _generation;
      final getToday = _getTodayTestBreveEstadoDeAnimo;
      _timer = Timer(durationUntilMidnight, () async {
        if (!_isCurrent(generation)) return;
        state = null;
        try {
          final result = await getToday();
          if (!_isCurrent(generation)) return;
          state = result;
        } catch (_) {
          if (_isCurrent(generation)) state = null;
        }
        if (_isCurrent(generation)) scheduleNextMidnightCheck();
      });
    }
  }
}

final todayTestBreveEstadoDeAnimoProvider =
    NotifierProvider<
      TodayTestBreveEstadoDeAnimoNotifier,
      TestBreveEstadoDeAnimo?
    >(TodayTestBreveEstadoDeAnimoNotifier.new);
