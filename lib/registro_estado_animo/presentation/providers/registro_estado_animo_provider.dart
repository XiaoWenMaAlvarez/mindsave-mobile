import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'registro_estado_animo_repository_provider.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/domain/repositories/registro_estado_animo_repository.dart';

class RegistroEstadoAnimoState {
  final bool isLastPendientePage;
  final int limitPendiente;
  final int pagePendiente;
  final bool isLastCompletoPage;
  final int limitCompleto;
  final int pageCompleto;
  final bool isLoading;
  final List<RegistroEstadoAnimo> registros;

  RegistroEstadoAnimoState({
    this.isLastPendientePage = false,
    this.limitPendiente = 10,
    this.pagePendiente = 1,
    this.isLastCompletoPage = false,
    this.limitCompleto = 10,
    this.pageCompleto = 1,
    this.isLoading = false,
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
    List<RegistroEstadoAnimo>? registros,
  }) => RegistroEstadoAnimoState(
    isLastPendientePage: isLastPendientePage ?? this.isLastPendientePage,
    limitPendiente: limitPendiente ?? this.limitPendiente,
    pagePendiente: pagePendiente ?? this.pagePendiente,
    isLastCompletoPage: isLastCompletoPage ?? this.isLastCompletoPage,
    limitCompleto: limitCompleto ?? this.limitCompleto,
    pageCompleto: pageCompleto ?? this.pageCompleto,
    isLoading: isLoading ?? this.isLoading,
    registros: registros ?? this.registros,
  );
}

class RegistroEstadoDeAnimoNotifier extends Notifier<RegistroEstadoAnimoState> {
  late RegistroEstadoAnimoRepository registroEstadoAnimoRepository;

  @override
  RegistroEstadoAnimoState build() {
    registroEstadoAnimoRepository = ref.watch(
      registroEstadoAnimoRepositoryProvider,
    );
    unawaited(Future<void>.microtask(_initialLoading));
    return RegistroEstadoAnimoState();
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
    if (state.isLoading) return;
    if (state.isLastPendientePage) return;

    state = state.copyWith(isLoading: true);
    try {
      final List<RegistroEstadoAnimo> newRegistros =
          await registroEstadoAnimoRepository.getRegistroEstadoDeAnimoPendiente(
            page: state.pagePendiente,
            limit: state.limitPendiente,
          );
      if (!ref.mounted) return;
      if (newRegistros.isEmpty) {
        state = state.copyWith(isLastPendientePage: true);
        return;
      }

      state = state.copyWith(
        isLastPendientePage: newRegistros.length < state.limitPendiente,
        pagePendiente: state.pagePendiente + 1,
        registros: _mergeRegistros(state.registros, newRegistros),
      );
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> loadNextCompletosPage() async {
    if (!ref.mounted) return;
    if (state.isLoading) return;
    if (state.isLastCompletoPage) return;

    state = state.copyWith(isLoading: true);
    try {
      final List<RegistroEstadoAnimo> newRegistros =
          await registroEstadoAnimoRepository.getRegistroEstadoDeAnimoCompleto(
            page: state.pageCompleto,
            limit: state.limitCompleto,
          );
      if (!ref.mounted) return;
      if (newRegistros.isEmpty) {
        state = state.copyWith(isLastCompletoPage: true);
        return;
      }

      state = state.copyWith(
        isLastCompletoPage: newRegistros.length < state.limitCompleto,
        pageCompleto: state.pageCompleto + 1,
        registros: _mergeRegistros(state.registros, newRegistros),
      );
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> cargarRegistrosEstadoDeAnimoById(String id) async {
    if (!ref.mounted) return;
    final bool isRegistroCargado = state.registros.any(
      (RegistroEstadoAnimo reg) => reg.id == id,
    );
    if (isRegistroCargado) return;

    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true);
      final RegistroEstadoAnimo? registroEstadoAnimoBuscado =
          await registroEstadoAnimoRepository.getRegistroEstadoDeAnimoById(id);
      if (!ref.mounted) return;
      if (registroEstadoAnimoBuscado != null) {
        state = state.copyWith(
          registros: _mergeRegistros(state.registros, [
            registroEstadoAnimoBuscado,
          ]),
        );
      }
    } catch (e) {
      return;
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false);
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
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      nvoRegistroEstadoAnimo.id = await registroEstadoAnimoRepository
          .saveRegistroEstadoDeAnimo(nvoRegistroEstadoAnimo);
      state = state.copyWith(
        registros: _mergeRegistros(state.registros, [nvoRegistroEstadoAnimo]),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> eliminarRegistroEstadoDeAnimo(String id) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      await registroEstadoAnimoRepository.eliminarRegistroEstadoDeAnimoDeHoy(
        id,
      );
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
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> editarRegistroEstadoDeAnimo(
    RegistroEstadoAnimo nvoRegistroEstadoAnimo,
  ) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      await registroEstadoAnimoRepository.editarRegistroEstadoDeAnimoDeHoy(
        nvoRegistroEstadoAnimo,
      );
      state = state.copyWith(
        registros: state.registros.map((registroEstadoAnimo) {
          if (registroEstadoAnimo.id == nvoRegistroEstadoAnimo.id) {
            return nvoRegistroEstadoAnimo;
          }
          return registroEstadoAnimo;
        }).toList(),
      );
    } finally {
      state = state.copyWith(isLoading: false);
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
