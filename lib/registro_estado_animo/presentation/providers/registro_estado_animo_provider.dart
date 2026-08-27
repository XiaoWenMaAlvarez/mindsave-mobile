import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'registro_estado_animo_repository_provider.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/domain/repositories/registro_estado_animo_repository.dart';

const _unchangedRegistroError = Object();

class RegistroEstadoAnimoState {
  final bool isLastPendientePage;
  final int limitPendiente;
  final int pagePendiente;
  final bool isLastCompletoPage;
  final int limitCompleto;
  final int pageCompleto;
  final bool isLoading;
  final String? pendientesError;
  final String? completosError;
  final String? recordError;
  final List<RegistroEstadoAnimo> registros;

  RegistroEstadoAnimoState({
    this.isLastPendientePage = false,
    this.limitPendiente = 10,
    this.pagePendiente = 1,
    this.isLastCompletoPage = false,
    this.limitCompleto = 10,
    this.pageCompleto = 1,
    this.isLoading = false,
    this.pendientesError,
    this.completosError,
    this.recordError,
    this.registros = const [],
  });

  RegistroEstadoAnimoState copyWith({
    bool? isLastPendientePage,
    int? limitPendiente,
    int? pagePendiente,
    bool? isLastCompletoPage,
    int? limitCompleto,
    int? pageCompleto,
    bool? isLoading,
    Object? pendientesError = _unchangedRegistroError,
    Object? completosError = _unchangedRegistroError,
    Object? recordError = _unchangedRegistroError,
    List<RegistroEstadoAnimo>? registros,
  }) => RegistroEstadoAnimoState(
    isLastPendientePage: isLastPendientePage ?? this.isLastPendientePage,
    limitPendiente: limitPendiente ?? this.limitPendiente,
    pagePendiente: pagePendiente ?? this.pagePendiente,
    isLastCompletoPage: isLastCompletoPage ?? this.isLastCompletoPage,
    limitCompleto: limitCompleto ?? this.limitCompleto,
    pageCompleto: pageCompleto ?? this.pageCompleto,
    isLoading: isLoading ?? this.isLoading,
    pendientesError: identical(pendientesError, _unchangedRegistroError)
        ? this.pendientesError
        : pendientesError as String?,
    completosError: identical(completosError, _unchangedRegistroError)
        ? this.completosError
        : completosError as String?,
    recordError: identical(recordError, _unchangedRegistroError)
        ? this.recordError
        : recordError as String?,
    registros: registros ?? this.registros,
  );
}

class RegistroEstadoDeAnimoNotifier extends Notifier<RegistroEstadoAnimoState> {
  late RegistroEstadoAnimoRepository registroEstadoAnimoRepository;
  int _generation = 0;
  int _activeOperations = 0;
  bool _loadingPendientes = false;
  bool _loadingCompletos = false;
  bool _isMutating = false;
  final Set<String> _loadingRecordIds = {};

  @override
  RegistroEstadoAnimoState build() {
    _generation++;
    _activeOperations = 0;
    _loadingPendientes = false;
    _loadingCompletos = false;
    _isMutating = false;
    _loadingRecordIds.clear();
    registroEstadoAnimoRepository = ref.watch(
      registroEstadoAnimoRepositoryProvider,
    );
    unawaited(Future<void>.microtask(_initialLoading));
    return RegistroEstadoAnimoState();
  }

  bool _isCurrent(int generation) => ref.mounted && generation == _generation;

  void _beginOperation() {
    _activeOperations++;
    state = state.copyWith(isLoading: true);
  }

  void _finishOperation(int generation) {
    if (!_isCurrent(generation)) return;
    if (_activeOperations > 0) _activeOperations--;
    state = state.copyWith(isLoading: _activeOperations > 0);
  }

  Future<void> _initialLoading() async {
    if (!ref.mounted) return;
    await loadNextCompletosPage();
    if (!ref.mounted) return;
    await loadNextPendientesPage();
  }

  Future<void> refreshRegistros() async {
    if (!ref.mounted) return;
    state = state.copyWith(
      pagePendiente: 1,
      isLastPendientePage: false,
      pageCompleto: 1,
      isLastCompletoPage: false,
      pendientesError: null,
      completosError: null,
      recordError: null,
      registros: const [],
    );
    await loadNextCompletosPage();
    if (!ref.mounted) return;
    await loadNextPendientesPage();
  }

  List<RegistroEstadoAnimo> _mergeRegistros(
    List<RegistroEstadoAnimo> current,
    List<RegistroEstadoAnimo> incoming,
  ) {
    final merged = <String, RegistroEstadoAnimo>{};
    for (final reg in current) {
      if (reg.id.isNotEmpty) {
        merged[reg.id] = reg;
      }
    }
    for (final reg in incoming) {
      if (reg.id.isNotEmpty) {
        merged[reg.id] = reg;
      }
    }
    return merged.values.toList();
  }

  Future<void> loadNextPendientesPage() async {
    if (!ref.mounted) return;
    if (_loadingPendientes) return;
    if (state.isLastPendientePage) return;

    final generation = _generation;
    final repository = registroEstadoAnimoRepository;
    final page = state.pagePendiente;
    final limit = state.limitPendiente;
    _loadingPendientes = true;
    state = state.copyWith(pendientesError: null);
    _beginOperation();
    try {
      final List<RegistroEstadoAnimo> newRegistros = await repository
          .getRegistroEstadoDeAnimoPendiente(page: page, limit: limit);
      if (!_isCurrent(generation)) return;
      if (newRegistros.isEmpty) {
        state = state.copyWith(isLastPendientePage: true);
        return;
      }

      state = state.copyWith(
        isLastPendientePage: newRegistros.length < limit,
        pagePendiente: page + 1,
        registros: _mergeRegistros(state.registros, newRegistros),
      );
    } catch (_) {
      if (_isCurrent(generation)) {
        state = state.copyWith(
          pendientesError: 'No se pudieron cargar los registros pendientes.',
        );
      }
    } finally {
      if (_isCurrent(generation)) {
        _loadingPendientes = false;
        _finishOperation(generation);
      }
    }
  }

  Future<void> loadNextCompletosPage() async {
    if (!ref.mounted) return;
    if (_loadingCompletos) return;
    if (state.isLastCompletoPage) return;

    final generation = _generation;
    final repository = registroEstadoAnimoRepository;
    final page = state.pageCompleto;
    final limit = state.limitCompleto;
    _loadingCompletos = true;
    state = state.copyWith(completosError: null);
    _beginOperation();
    try {
      final List<RegistroEstadoAnimo> newRegistros = await repository
          .getRegistroEstadoDeAnimoCompleto(page: page, limit: limit);
      if (!_isCurrent(generation)) return;
      if (newRegistros.isEmpty) {
        state = state.copyWith(isLastCompletoPage: true);
        return;
      }

      state = state.copyWith(
        isLastCompletoPage: newRegistros.length < limit,
        pageCompleto: page + 1,
        registros: _mergeRegistros(state.registros, newRegistros),
      );
    } catch (_) {
      if (_isCurrent(generation)) {
        state = state.copyWith(
          completosError: 'No se pudieron cargar los registros completados.',
        );
      }
    } finally {
      if (_isCurrent(generation)) {
        _loadingCompletos = false;
        _finishOperation(generation);
      }
    }
  }

  Future<void> cargarRegistrosEstadoDeAnimoById(String id) async {
    if (!ref.mounted) return;
    final bool isRegistroCargado = state.registros.any(
      (RegistroEstadoAnimo reg) => reg.id == id,
    );
    if (isRegistroCargado) return;

    if (_loadingRecordIds.contains(id)) return;

    final generation = _generation;
    final repository = registroEstadoAnimoRepository;
    _loadingRecordIds.add(id);
    try {
      state = state.copyWith(recordError: null);
      _beginOperation();
      final RegistroEstadoAnimo? registroEstadoAnimoBuscado = await repository
          .getRegistroEstadoDeAnimoById(id);
      if (!_isCurrent(generation)) return;
      if (registroEstadoAnimoBuscado != null) {
        state = state.copyWith(
          registros: _mergeRegistros(state.registros, [
            registroEstadoAnimoBuscado,
          ]),
        );
      }
    } catch (_) {
      if (_isCurrent(generation)) {
        state = state.copyWith(
          recordError: 'No se pudo cargar el registro. Comprueba tu conexión.',
        );
      }
    } finally {
      if (_isCurrent(generation)) {
        _loadingRecordIds.remove(id);
        _finishOperation(generation);
      }
    }

    return;
  }

  //Se asume que el registro ya está cargado en el state
  RegistroEstadoAnimo? getRegistroEstadoDeAnimoById(String id) {
    if (state.registros.any((RegistroEstadoAnimo reg) => reg.id == id)) {
      return state.registros.firstWhere(
        (RegistroEstadoAnimo reg) => reg.id == id,
      );
    }

    return null;
  }

  Future<void> guardarRegistroEstadoDeAnimo(
    RegistroEstadoAnimo nvoRegistroEstadoAnimo,
  ) async {
    if (_isMutating) return;
    final generation = _generation;
    final repository = registroEstadoAnimoRepository;
    _isMutating = true;
    _beginOperation();
    try {
      nvoRegistroEstadoAnimo.id = await repository.saveRegistroEstadoDeAnimo(
        nvoRegistroEstadoAnimo,
      );
      if (!_isCurrent(generation)) return;
      state = state.copyWith(
        registros: _mergeRegistros(state.registros, [nvoRegistroEstadoAnimo]),
      );
    } finally {
      if (_isCurrent(generation)) {
        _isMutating = false;
        _finishOperation(generation);
      }
    }
  }

  Future<void> eliminarRegistroEstadoDeAnimo(String id) async {
    if (_isMutating) return;
    final generation = _generation;
    final repository = registroEstadoAnimoRepository;
    _isMutating = true;
    _beginOperation();
    try {
      await repository.eliminarRegistroEstadoDeAnimoDeHoy(id);
      if (!_isCurrent(generation)) return;
      if (state.registros.isNotEmpty) {
        state = state.copyWith(
          registros: state.registros
              .where(
                (RegistroEstadoAnimo registroEstadoAnimo) =>
                    registroEstadoAnimo.id != id,
              )
              .toList(),
        );
      }
    } finally {
      if (_isCurrent(generation)) {
        _isMutating = false;
        _finishOperation(generation);
      }
    }
  }

  Future<void> editarRegistroEstadoDeAnimo(
    RegistroEstadoAnimo nvoRegistroEstadoAnimo,
  ) async {
    if (_isMutating) return;
    final generation = _generation;
    final repository = registroEstadoAnimoRepository;
    _isMutating = true;
    _beginOperation();
    try {
      await repository.editarRegistroEstadoDeAnimoDeHoy(nvoRegistroEstadoAnimo);
      if (!_isCurrent(generation)) return;
      state = state.copyWith(
        registros: state.registros.map((registroEstadoAnimo) {
          if (registroEstadoAnimo.id == nvoRegistroEstadoAnimo.id) {
            return nvoRegistroEstadoAnimo;
          }
          return registroEstadoAnimo;
        }).toList(),
      );
    } finally {
      if (_isCurrent(generation)) {
        _isMutating = false;
        _finishOperation(generation);
      }
    }
  }

  void restaurarRegistroEstadoDeAnimo(RegistroEstadoAnimo snapshot) {
    final restored = RegistroEstadoAnimo.fromJson(snapshot.toJson());
    state = state.copyWith(
      registros: state.registros.map((registroEstadoAnimo) {
        if (registroEstadoAnimo.id == snapshot.id) {
          return restored;
        }
        return registroEstadoAnimo;
      }).toList(),
    );
  }
}

final registroEstadoDeAnimoProvider =
    NotifierProvider<RegistroEstadoDeAnimoNotifier, RegistroEstadoAnimoState>(
      RegistroEstadoDeAnimoNotifier.new,
    );
