import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/home/presentation/widgets/widgets.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/presentation/widgets/custom_bottom_navigation.dart';

const cbtStepLabels = <String>[
  'Contexto',
  'Emociones',
  'Pensamientos',
  'Distorsiones',
  'Reestructura',
  'Revisión',
];

class CbtFlowScaffold extends StatelessWidget {
  const CbtFlowScaffold({
    super.key,
    required this.scaffoldKey,
    required this.currentStep,
    required this.title,
    required this.description,
    required this.body,
    required this.nextLabel,
    required this.onNext,
    this.onPrevious,
    this.footer,
    this.isLoading = false,
    this.isContentLoading = false,
    this.nextIcon = Icons.arrow_forward_rounded,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final int currentStep;
  final String title;
  final String description;
  final Widget body;
  final String nextLabel;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Widget? footer;
  final bool isLoading;
  final bool isContentLoading;
  final IconData nextIcon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      endDrawer: SideMenu(scaffoldKey: scaffoldKey),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
      body: SafeArea(
        top: false,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CbtStepHeader(
                      currentStep: currentStep,
                      title: title,
                      description: description,
                    ),
                    const SizedBox(height: 22),
                    body,
                    const SizedBox(height: 22),
                    if (!isContentLoading)
                      Row(
                        children: [
                          if (onPrevious != null) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isLoading ? null : onPrevious,
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('Atrás'),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            flex: onPrevious == null ? 1 : 2,
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : onNext,
                              icon: isLoading
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(nextIcon),
                              label: Text(nextLabel),
                            ),
                          ),
                        ],
                      ),
                    if (footer != null) ...[
                      const SizedBox(height: 12),
                      footer!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CbtStepHeader extends StatelessWidget {
  const CbtStepHeader({
    super.key,
    required this.currentStep,
    required this.title,
    required this.description,
  });

  final int currentStep;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Paso $currentStep de 6: ${cbtStepLabels[currentStep - 1]}',
          child: ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < cbtStepLabels.length; index++) ...[
                  Expanded(
                    child: _CbtStepIndicator(
                      number: index + 1,
                      label: cbtStepLabels[index],
                      state: index + 1 < currentStep
                          ? _CbtStepState.complete
                          : index + 1 == currentStep
                          ? _CbtStepState.current
                          : _CbtStepState.upcoming,
                    ),
                  ),
                  if (index < cbtStepLabels.length - 1)
                    const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

enum _CbtStepState { complete, current, upcoming }

class _CbtStepIndicator extends StatelessWidget {
  const _CbtStepIndicator({
    required this.number,
    required this.label,
    required this.state,
  });

  final int number;
  final String label;
  final _CbtStepState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final active = state != _CbtStepState.upcoming;

    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: active ? colors.primary : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: active ? colors.primary : colors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: state == _CbtStepState.complete
                ? Icon(Icons.check_rounded, size: 16, color: colors.onPrimary)
                : Text(
                    '$number',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: active
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 24,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: Text(
              label,
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(
                color: active ? colors.primary : colors.onSurfaceVariant,
                fontWeight: state == _CbtStepState.current
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CbtEmotionGroupData {
  const CbtEmotionGroupData({
    required this.group,
    required this.title,
    required this.emoji,
  });

  final Emociones group;
  final String title;
  final String emoji;

  List<String> get selectedEmotions {
    final selected = <String>[];
    for (var index = 0; index < group.listaEmociones.length; index++) {
      if (index < group.seleccionEmociones.length &&
          group.seleccionEmociones[index]) {
        selected.add(group.listaEmociones[index]);
      }
    }
    return selected;
  }

  bool get hasSelection => selectedEmotions.isNotEmpty;
}

List<CbtEmotionGroupData> cbtEmotionGroups(RegistroEstadoAnimo record) => [
  CbtEmotionGroupData(
    group: record.grupoEmociones1,
    title: 'Tristeza',
    emoji: '😢',
  ),
  CbtEmotionGroupData(
    group: record.grupoEmociones2,
    title: 'Ansiedad',
    emoji: '😰',
  ),
  CbtEmotionGroupData(
    group: record.grupoEmociones3,
    title: 'Culpa',
    emoji: '😔',
  ),
  CbtEmotionGroupData(
    group: record.grupoEmociones4,
    title: 'Vergüenza',
    emoji: '🫣',
  ),
  CbtEmotionGroupData(
    group: record.grupoEmociones5,
    title: 'Soledad',
    emoji: '😞',
  ),
  CbtEmotionGroupData(
    group: record.grupoEmociones6,
    title: 'Turbación',
    emoji: '😳',
  ),
  CbtEmotionGroupData(
    group: record.grupoEmociones7,
    title: 'Desesperanza',
    emoji: '😩',
  ),
  CbtEmotionGroupData(
    group: record.grupoEmociones8,
    title: 'Frustración',
    emoji: '😤',
  ),
  CbtEmotionGroupData(group: record.grupoEmociones9, title: 'Ira', emoji: '😠'),
  CbtEmotionGroupData(
    group: record.grupoEmocionesPersonalizadas,
    title: 'Otras emociones',
    emoji: '💭',
  ),
];

int cbtEmotionalReduction(RegistroEstadoAnimo record) {
  final ratedGroups = cbtEmotionGroups(record).where(
    (data) =>
        (data.group.porcentajeCreenciaAntes ?? 0) > 0 &&
        data.group.porcentajeCreenciaDespues != null,
  );
  if (ratedGroups.isEmpty) return 0;

  final before = ratedGroups
      .map((data) => data.group.porcentajeCreenciaAntes!)
      .reduce((a, b) => a + b);
  final after = ratedGroups
      .map((data) => data.group.porcentajeCreenciaDespues!)
      .reduce((a, b) => a + b);
  return ((before - after) / before * 100).round().clamp(0, 100).toInt();
}

enum CbtLeaveChoice { save, discard }

Future<bool> confirmCbtLeave(
  BuildContext context, {
  required Future<void> Function() onSave,
  void Function()? onDiscard,
}) async {
  final choice = await showDialog<CbtLeaveChoice>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('¿Guardar antes de volver?'),
      content: const Text(
        'Puedes guardar lo que has avanzado o volver sin conservar los últimos cambios.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(CbtLeaveChoice.discard),
          child: const Text('No guardar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(CbtLeaveChoice.save),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  if (choice == null) return false;
  if (choice == CbtLeaveChoice.save) {
    await onSave();
  } else if (choice == CbtLeaveChoice.discard) {
    onDiscard?.call();
  }
  return true;
}

void showCbtMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class CbtRecordNotFoundView extends StatelessWidget {
  const CbtRecordNotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_outlined,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'No pudimos encontrar este registro',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Es posible que haya sido eliminado o no se pudo cargar desde el servidor.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/registros'),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Volver a mis registros'),
            ),
          ],
        ),
      ),
    );
  }
}
