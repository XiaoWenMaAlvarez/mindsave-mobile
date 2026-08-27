import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/registro_estado_animo/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

class RegistroEstadoAnimoPendingViewStep1To3Screen
    extends ConsumerStatefulWidget {
  const RegistroEstadoAnimoPendingViewStep1To3Screen({
    super.key,
    required this.idRegistroEstadoAnimo,
  });

  final String idRegistroEstadoAnimo;

  @override
  ConsumerState<RegistroEstadoAnimoPendingViewStep1To3Screen> createState() =>
      _RegistroEstadoAnimoPendingViewStep1To3ScreenState();
}

class _RegistroEstadoAnimoPendingViewStep1To3ScreenState
    extends ConsumerState<RegistroEstadoAnimoPendingViewStep1To3Screen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());
  int _currentStep = 0;

  static const _stepTitles = [
    '¿Qué ocurrió?',
    'Ponle nombre a lo que sentiste',
    'Observa tus pensamientos',
  ];

  static const _stepDescriptions = [
    'Describe brevemente la situación que alteró tu ánimo. No necesitas escribir todos los detalles.',
    'Selecciona las emociones que aparecieron y estima su intensidad en ese momento.',
    'Anota las ideas automáticas que surgieron y cuánto creíste en cada una.',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(registroEstadoDeAnimoProvider.notifier)
          .cargarRegistrosEstadoDeAnimoById(widget.idRegistroEstadoAnimo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registroEstadoDeAnimoProvider);
    final record = ref
        .read(registroEstadoDeAnimoProvider.notifier)
        .getRegistroEstadoDeAnimoById(widget.idRegistroEstadoAnimo);

    return CbtFlowScaffold(
      scaffoldKey: _scaffoldKey,
      currentStep: _currentStep + 1,
      title: _stepTitles[_currentStep],
      description: _stepDescriptions[_currentStep],
      body: record == null
          ? (state.isLoading
                ? const MindsaveLoadingView(
                    compact: true,
                    message: 'Cargando tu registro…',
                  )
                : const CbtRecordNotFoundView())
          : MindsaveSectionCard(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey(_currentStep),
                  child: _buildCurrentStep(record),
                ),
              ),
            ),
      nextLabel: _currentStep == 2 ? 'Guardar y continuar' : 'Continuar',
      nextIcon: _currentStep == 2
          ? Icons.check_rounded
          : Icons.arrow_forward_rounded,
      isLoading: state.isLoading,
      isContentLoading: record == null,
      onPrevious: _currentStep == 0
          ? null
          : () => setState(() => _currentStep--),
      onNext: record == null ? null : () => _continue(record),
      footer: record == null
          ? null
          : Center(
              child: TextButton.icon(
                onPressed: state.isLoading
                    ? null
                    : () => _confirmDelete(record),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar registro'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentStep(RegistroEstadoAnimo record) {
    return switch (_currentStep) {
      0 => RegistroEstadoAnimoPaso1(record, _formKeys[0]),
      1 => RegistroEstadoAnimoPaso2(record, _formKeys[1]),
      _ => RegistroEstadoAnimoPaso3(record, _formKeys[2]),
    };
  }

  Future<void> _continue(RegistroEstadoAnimo record) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKeys[_currentStep].currentState?.validate() != true) {
      showCbtMessage(
        context,
        'Revisa los campos señalados antes de continuar.',
      );
      return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }
    final validationMessage = record.isValid;
    if (validationMessage != null) {
      showCbtMessage(context, validationMessage);
      return;
    }

    await ref
        .read(registroEstadoDeAnimoProvider.notifier)
        .editarRegistroEstadoDeAnimo(record);
    if (!mounted) return;
    context.push('/registroEstadoAnimo/3/${record.id}');
  }

  Future<void> _confirmDelete(RegistroEstadoAnimo record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar este registro?'),
        content: const Text(
          'Esta acción es permanente y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Conservar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(registroEstadoDeAnimoProvider.notifier)
        .eliminarRegistroEstadoDeAnimo(record.id);
    if (!mounted) return;
    showCbtMessage(context, 'Registro eliminado.');
    context.push('/registros');
  }
}
