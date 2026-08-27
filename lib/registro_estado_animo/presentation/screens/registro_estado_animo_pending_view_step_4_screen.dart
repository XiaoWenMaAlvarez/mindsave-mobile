import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/registro_estado_animo/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

class RegistroEstadoAnimoPendingViewStep4Screen extends ConsumerStatefulWidget {
  const RegistroEstadoAnimoPendingViewStep4Screen({
    super.key,
    required this.idRegistroEstadoAnimo,
  });

  final String idRegistroEstadoAnimo;

  @override
  ConsumerState<RegistroEstadoAnimoPendingViewStep4Screen> createState() =>
      _RegistroEstadoAnimoPendingViewStep4ScreenState();
}

class _RegistroEstadoAnimoPendingViewStep4ScreenState
    extends ConsumerState<RegistroEstadoAnimoPendingViewStep4Screen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RegistroEstadoAnimo? _originalSnapshot;

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
    if (record != null) {
      _originalSnapshot ??= RegistroEstadoAnimo.fromJson(record.toJson());
    }

    return CbtFlowScaffold(
      scaffoldKey: _scaffoldKey,
      currentStep: 4,
      title: 'Distorsiones cognitivas',
      description:
          'Identifica las distorsiones presentes en cada pensamiento negativo.',
      body: record == null
          ? (state.isLoading
                ? const MindsaveLoadingView(
                    compact: true,
                    message: 'Cargando tu registro…',
                  )
                : const CbtRecordNotFoundView())
          : _StepFourContent(record: record),
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
      onDiscard: () {
        if (_originalSnapshot != null) {
          ref
              .read(registroEstadoDeAnimoProvider.notifier)
              .restaurarRegistroEstadoDeAnimo(_originalSnapshot!);
        }
      },
    );
    if (shouldLeave && mounted) {
      context.push('/registroEstadoAnimo/6/${record.id}');
    }
  }

  Future<void> _continue(RegistroEstadoAnimo record) async {
    await ref
        .read(registroEstadoDeAnimoProvider.notifier)
        .editarRegistroEstadoDeAnimo(record);
    if (!mounted) return;
    context.push('/registroEstadoAnimo/4/${record.id}');
  }
}

class _StepFourContent extends StatelessWidget {
  const _StepFourContent({required this.record});

  final RegistroEstadoAnimo record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < record.listaPensamientos.length; index++)
          CustomCheckBoxGroupDistorsiones(
            title: 'Pensamiento ${index + 1}',
            pensamiento: record.listaPensamientos[index],
          ),
        const SizedBox(height: 4),
        MindsaveSectionCard(
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            leading: Icon(
              Icons.psychology_alt_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('¿Qué significa cada distorsión?'),
            subtitle: const Text('Consulta la guía cuando la necesites'),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            children: [
              for (
                var index = 0;
                index < Pensamiento.listaDistorsiones.length;
                index++
              ) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${index + 1}. ${Pensamiento.listaDistorsiones[index]}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(Pensamiento.detalleListaDistorsiones[index]),
                ),
                if (index < Pensamiento.listaDistorsiones.length - 1)
                  const Divider(height: 24),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
