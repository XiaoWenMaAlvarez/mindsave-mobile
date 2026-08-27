import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsave/test_breve_estado_animo/domain/entities/entities.dart';
import 'providers.dart';

typedef GetTestBreveEstadoDeAnimoByYearCallback =
    Future<List<TestBreveEstadoDeAnimo>> Function(int year);
typedef SaveTestBreveEstadoDeAnimo =
    Future<void> Function(TestBreveEstadoDeAnimo nvoTestBreveEstadoDeAnimo);
typedef DeleteTodayTestBreveEstadoDeAnimo = Future<void> Function();
typedef EditarTestBreveEstadoDeAnimoDeHoy =
    Future<void> Function(TestBreveEstadoDeAnimo nvoTestBreveEstadoDeAnimo);

class TestBreveEstadoDeAnimoNotifier
    extends Notifier<List<TestBreveEstadoDeAnimo>> {
  late GetTestBreveEstadoDeAnimoByYearCallback
  _fetchTestBreveEstadoDeAnimoByYear;
  late SaveTestBreveEstadoDeAnimo _saveTestBreveEstadoDeAnimo;
  late DeleteTodayTestBreveEstadoDeAnimo _deleteTodayTestBreveEstadoDeAnimo;
  late EditarTestBreveEstadoDeAnimoDeHoy _editarTestBreveEstadoDeAnimoDeHoy;
  late SetIsLoading _setIsLoading;
  final Set<int> _loadedYears = {};

  @override
  List<TestBreveEstadoDeAnimo> build() {
    final repository = ref.watch(testBreveEstadoDeAnimoRepositoryProvider);
    _fetchTestBreveEstadoDeAnimoByYear =
        repository.getTestBreveEstadoDeAnimoByYear;
    _saveTestBreveEstadoDeAnimo = repository.saveTestBreveEstadoDeAnimo;
    _deleteTodayTestBreveEstadoDeAnimo =
        repository.eliminarTestBreveEstadoDeAnimoDeHoy;
    _editarTestBreveEstadoDeAnimoDeHoy =
        repository.editarTestBreveEstadoDeAnimoDeHoy;
    _setIsLoading = ref.read(isLoadingProvider.notifier).setLoading;
    _loadedYears.clear();
    return [];
  }

  bool _isSameDate(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  Future<void> loadTestBreveEstadoDeAnimoByYear(int year) async {
    if (_loadedYears.contains(year)) {
      return;
    }
    _setIsLoading(true);
    try {
      final List<TestBreveEstadoDeAnimo> newTestsBreveEstadoDeAnimo =
          await _fetchTestBreveEstadoDeAnimoByYear(year);
      _loadedYears.add(year);
      state = [
        ...state.where((test) => test.fechaCreacion.toLocal().year != year),
        ...newTestsBreveEstadoDeAnimo,
      ];
    } finally {
      _setIsLoading(false);
    }
  }

  Future<String> guardarTestBreveEstadoDeAnimo(
    TestBreveEstadoDeAnimo nvoTestBreveEstadoDeAnimo,
  ) async {
    try {
      _setIsLoading(true);
      await _saveTestBreveEstadoDeAnimo(nvoTestBreveEstadoDeAnimo);

      final nvoYear = nvoTestBreveEstadoDeAnimo.fechaCreacion.toLocal().year;
      if (_loadedYears.contains(nvoYear)) {
        state = [
          ...state.where(
            (t) => !_isSameDate(
              t.fechaCreacion,
              nvoTestBreveEstadoDeAnimo.fechaCreacion,
            ),
          ),
          nvoTestBreveEstadoDeAnimo,
        ];
      }
      return "OK";
    } catch (e) {
      return e.toString();
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> eliminarTestBreveEstadoDeAnimoDeHoy() async {
    _setIsLoading(true);
    try {
      await _deleteTodayTestBreveEstadoDeAnimo();
      final now = DateTime.now();
      state = state.where((t) => !_isSameDate(t.fechaCreacion, now)).toList();
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> sobrescribirTestBreveEstadoDeAnimoDeHoy(
    TestBreveEstadoDeAnimo nvoTestBreveEstadoDeAnimo,
  ) async {
    _setIsLoading(true);
    try {
      await _editarTestBreveEstadoDeAnimoDeHoy(nvoTestBreveEstadoDeAnimo);
      final nvoYear = nvoTestBreveEstadoDeAnimo.fechaCreacion.toLocal().year;
      if (_loadedYears.contains(nvoYear)) {
        state = [
          ...state.where(
            (t) => !_isSameDate(
              t.fechaCreacion,
              nvoTestBreveEstadoDeAnimo.fechaCreacion,
            ),
          ),
          nvoTestBreveEstadoDeAnimo,
        ];
      }
    } finally {
      _setIsLoading(false);
    }
  }
}

final testBreveEstadoDeAnimoProvider =
    NotifierProvider<
      TestBreveEstadoDeAnimoNotifier,
      List<TestBreveEstadoDeAnimo>
    >(TestBreveEstadoDeAnimoNotifier.new);
