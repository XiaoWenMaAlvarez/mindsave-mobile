import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/registro_estado_animo/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

class RegistroEstadoAnimoPendingViewStep5Screen extends ConsumerStatefulWidget {
  const RegistroEstadoAnimoPendingViewStep5Screen({
    super.key,
    required this.idRegistroEstadoAnimo,
  });

  final String idRegistroEstadoAnimo;

  @override
  ConsumerState<RegistroEstadoAnimoPendingViewStep5Screen> createState() =>
      _RegistroEstadoAnimoPendingViewStep5ScreenState();
}

class _RegistroEstadoAnimoPendingViewStep5ScreenState
    extends ConsumerState<RegistroEstadoAnimoPendingViewStep5Screen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKeys = <GlobalKey<FormState>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(registroEstadoDeAnimoProvider.notifier)
          .cargarRegistrosEstadoDeAnimoById(widget.idRegistroEstadoAnimo);
    });
  }

  void _ensureFormKeys(int count) {
    while (_formKeys.length < count) {
      _formKeys.add(GlobalKey<FormState>());
    }
    if (_formKeys.length > count) {
      _formKeys.removeRange(count, _formKeys.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registroEstadoDeAnimoProvider);
    final record = ref
        .read(registroEstadoDeAnimoProvider.notifier)
        .getRegistroEstadoDeAnimoById(widget.idRegistroEstadoAnimo);
    if (record != null) _ensureFormKeys(record.listaPensamientos.length);

    return CbtFlowScaffold(
      scaffoldKey: _scaffoldKey,
      currentStep: 5,
      title: 'Reestructuración',
      description:
          'Agrega un pensamiento alternativo y re-evalúa tu creencia en el negativo.',
      body: record == null
          ? const MindsaveLoadingView(
              compact: true,
              message: 'Cargando tu registro…',
            )
          : Column(
              children: [
                for (
                  var index = 0;
                  index < record.listaPensamientos.length;
                  index++
                )
                  CustomFormPensamientoPositivo(
                    key: ValueKey(record.listaPensamientos[index]),
                    title: 'Pensamiento ${index + 1}',
                    pensamiento: record.listaPensamientos[index],
                    formKey: _formKeys[index],
                  ),
              ],
            ),
      nextLabel: 'Continuar',
      isLoading: state.isLoading,
      isContentLoading: record == null,
      onPrevious: record == null ? null : () => _goBack(record),
      onNext: record == null ? null : () => _continue(record),
    );
  }

  Future<void> _goBack(RegistroEstadoAnimo record) async {
    final shouldLeave = await confirmCbtLeave(
      context,
      onSave: () => ref
          .read(registroEstadoDeAnimoProvider.notifier)
          .editarRegistroEstadoDeAnimo(record),
    );
    if (shouldLeave && mounted) {
      context.push('/registroEstadoAnimo/3/${record.id}');
    }
  }

  Future<void> _continue(RegistroEstadoAnimo record) async {
    FocusManager.instance.primaryFocus?.unfocus();
    for (var index = 0; index < _formKeys.length; index++) {
      if (_formKeys[index].currentState?.validate() != true) {
        showCbtMessage(
          context,
          'Revisa el pensamiento ${index + 1} antes de continuar.',
        );
        return;
      }
    }
    await ref
        .read(registroEstadoDeAnimoProvider.notifier)
        .editarRegistroEstadoDeAnimo(record);
    if (!mounted) return;
    context.push('/registroEstadoAnimo/5/${record.id}');
  }
}
