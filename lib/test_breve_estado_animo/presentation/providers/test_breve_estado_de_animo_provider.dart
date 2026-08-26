import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
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
    return [];
  }

  Future<void> loadTestBreveEstadoDeAnimoByYear(int year) async {
    if (state.isNotEmpty &&
        state.any((test) => test.fechaCreacion.year == year)) {
      return;
    }
    _setIsLoading(true);
    try {
      final List<TestBreveEstadoDeAnimo> newTestsBreveEstadoDeAnimo =
          await _fetchTestBreveEstadoDeAnimoByYear(year);
      state = [...state, ...newTestsBreveEstadoDeAnimo];
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

      if (state.isNotEmpty) {
        if (state.first.fechaCreacion.year == DateTime.now().year) {
          state = [...state, nvoTestBreveEstadoDeAnimo];
        }
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

      if (state.isNotEmpty) {
        if (state.first.fechaCreacion.year == DateTime.now().year) {
          state = state.where((TestBreveEstadoDeAnimo testBreveEstadoDeAnimo) {
            return !(testBreveEstadoDeAnimo.fechaCreacion.year ==
                    DateTime.now().year &&
                testBreveEstadoDeAnimo.fechaCreacion.month ==
                    DateTime.now().month &&
                testBreveEstadoDeAnimo.fechaCreacion.day == DateTime.now().day);
          }).toList();
        }
      }
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

      if (state.isNotEmpty) {
        if (state.first.fechaCreacion.year == DateTime.now().year) {
          state = state.where((TestBreveEstadoDeAnimo testBreveEstadoDeAnimo) {
            return !(testBreveEstadoDeAnimo.fechaCreacion.year ==
                    DateTime.now().year &&
                testBreveEstadoDeAnimo.fechaCreacion.month ==
                    DateTime.now().month &&
                testBreveEstadoDeAnimo.fechaCreacion.day == DateTime.now().day);
          }).toList();

          state = [...state, nvoTestBreveEstadoDeAnimo];
        }
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
