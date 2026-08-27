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
  final Set<int> _loadingYears = {};
  int _generation = 0;

  @override
  List<TestBreveEstadoDeAnimo> build() {
    _generation++;
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
    _loadingYears.clear();
    return [];
  }

  bool _isCurrent(int generation) => ref.mounted && generation == _generation;

  bool _isSameDate(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  Future<String?> loadTestBreveEstadoDeAnimoByYear(int year) async {
    if (_loadedYears.contains(year) || _loadingYears.contains(year)) {
      return null;
    }
    final generation = _generation;
    final fetch = _fetchTestBreveEstadoDeAnimoByYear;
    _loadingYears.add(year);
    _setIsLoading(true);
    try {
      final List<TestBreveEstadoDeAnimo> newTestsBreveEstadoDeAnimo =
          await fetch(year);
      if (!_isCurrent(generation)) return null;
      _loadedYears.add(year);
      state = [
        ...state.where((test) => test.fechaCreacion.toLocal().year != year),
        ...newTestsBreveEstadoDeAnimo,
      ];
      return null;
    } catch (_) {
      return _isCurrent(generation)
          ? 'No se pudo cargar el seguimiento. Inténtalo nuevamente.'
          : null;
    } finally {
      if (_isCurrent(generation)) {
        _loadingYears.remove(year);
      }
      _setIsLoading(false);
    }
  }

  Future<String> guardarTestBreveEstadoDeAnimo(
    TestBreveEstadoDeAnimo nvoTestBreveEstadoDeAnimo,
  ) async {
    final generation = _generation;
    final save = _saveTestBreveEstadoDeAnimo;
    try {
      _setIsLoading(true);
      await save(nvoTestBreveEstadoDeAnimo);
      if (!_isCurrent(generation)) {
        return 'La sesión cambió durante el guardado';
      }

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
    final generation = _generation;
    final delete = _deleteTodayTestBreveEstadoDeAnimo;
    _setIsLoading(true);
    try {
      await delete();
      if (!_isCurrent(generation)) return;
      final now = DateTime.now();
      state = state.where((t) => !_isSameDate(t.fechaCreacion, now)).toList();
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> sobrescribirTestBreveEstadoDeAnimoDeHoy(
    TestBreveEstadoDeAnimo nvoTestBreveEstadoDeAnimo,
  ) async {
    final generation = _generation;
    final edit = _editarTestBreveEstadoDeAnimoDeHoy;
    _setIsLoading(true);
    try {
      await edit(nvoTestBreveEstadoDeAnimo);
      if (!_isCurrent(generation)) return;
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
