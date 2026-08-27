import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/registro_estado_animo/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

class RegistroEstadoAnimoPendingViewStep6Screen extends ConsumerStatefulWidget {
  const RegistroEstadoAnimoPendingViewStep6Screen({
    super.key,
    required this.idRegistroEstadoAnimo,
  });

  final String idRegistroEstadoAnimo;

  @override
  ConsumerState<RegistroEstadoAnimoPendingViewStep6Screen> createState() =>
      _RegistroEstadoAnimoPendingViewStep6ScreenState();
}

class _RegistroEstadoAnimoPendingViewStep6ScreenState
    extends ConsumerState<RegistroEstadoAnimoPendingViewStep6Screen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKeys = <GlobalKey<FormState>>[];
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
    final groups = record == null
        ? const <CbtEmotionGroupData>[]
        : cbtEmotionGroups(record).where((data) => data.hasSelection).toList();
    _ensureFormKeys(groups.length);
    if (record != null) {
      _originalSnapshot ??= RegistroEstadoAnimo.fromJson(record.toJson());
    }

    return CbtFlowScaffold(
      scaffoldKey: _scaffoldKey,
      currentStep: 6,
      title: 'Revisión emocional',
      description:
          'Re-evalúa la intensidad de tus emociones después del ejercicio.',
      body: record == null
          ? (state.isLoading
                ? const MindsaveLoadingView(
                    compact: true,
                    message: 'Cargando tu registro…',
                  )
                : const CbtRecordNotFoundView())
          : _StepSixContent(
              groups: groups,
              formKeys: _formKeys,
              onChanged: () => setState(() {}),
            ),
      nextLabel: 'Guardar registro',
      nextIcon: Icons.check_rounded,
      isLoading: state.isLoading,
      isContentLoading: record == null,
      onPrevious: record == null ? null : () => _goBack(record),
      onNext: record == null ? null : () => _finish(record, groups),
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
      context.push('/registroEstadoAnimo/4/${record.id}');
    }
  }

  Future<void> _finish(
    RegistroEstadoAnimo record,
    List<CbtEmotionGroupData> selectedGroups,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    for (var index = 0; index < _formKeys.length; index++) {
      if (_formKeys[index].currentState?.validate() != true) {
        showCbtMessage(
          context,
          'Revisa la intensidad de ${selectedGroups[index].title}.',
        );
        return;
      }
    }

    for (final data in cbtEmotionGroups(record)) {
      if (!data.hasSelection) data.group.porcentajeCreenciaDespues = 0;
    }
    await ref
        .read(registroEstadoDeAnimoProvider.notifier)
        .editarRegistroEstadoDeAnimo(record);
    if (!mounted) return;
    showCbtMessage(context, 'Registro completado y guardado.');
    context.push('/registroEstadoAnimo/7/${record.id}');
  }
}

class _StepSixContent extends StatelessWidget {
  const _StepSixContent({
    required this.groups,
    required this.formKeys,
    required this.onChanged,
  });

  final List<CbtEmotionGroupData> groups;
  final List<GlobalKey<FormState>> formKeys;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final success = theme.brightness == Brightness.dark
        ? const Color(0xFF73D99A)
        : const Color(0xFF247A4A);
    final complete =
        groups.isNotEmpty &&
        groups.every((data) => data.group.porcentajeCreenciaDespues != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (groups.isEmpty)
          const MindsaveSectionCard(
            child: Text(
              'No hay emociones seleccionadas para revisar. Vuelve al paso 2 para añadirlas.',
            ),
          )
        else
          for (var index = 0; index < groups.length; index++)
            CustomGrupoEmocionesReevaluacion(
              key: ValueKey(groups[index].group),
              title: groups[index].title,
              emoji: groups[index].emoji,
              grupoEmociones: groups[index].group,
              formKey: formKeys[index],
              onChanged: onChanged,
            ),
        const SizedBox(height: 4),
        MindsaveSectionCard(
          color: complete ? success.withAlpha(20) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (complete ? success : colors.primary).withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  complete ? Icons.check_rounded : Icons.info_outline_rounded,
                  color: complete ? success : colors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complete
                          ? 'Ejercicio completado'
                          : 'Completa la revisión',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complete
                          ? 'Has revisado todas las emociones. Guarda el registro para ver tu progreso.'
                          : 'Indica cómo se siente cada emoción ahora para cerrar el ejercicio.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
