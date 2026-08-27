import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/config/helpers/date_helper.dart';
import 'package:mindsave/home/presentation/widgets/widgets.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/registro_estado_animo/presentation/widgets/cbt_flow_layout.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

enum RecordsTab { pending, completed }

class RegistrosScreen extends ConsumerStatefulWidget {
  const RegistrosScreen({super.key, this.initialTab = RecordsTab.pending});

  final RecordsTab initialTab;

  @override
  ConsumerState<RegistrosScreen> createState() => _RegistrosScreenState();
}

class _RegistrosScreenState extends ConsumerState<RegistrosScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late RecordsTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registroEstadoDeAnimoProvider);
    final pending = state.registros.where((record) => record.isPending).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    final completed =
        state.registros.where((record) => !record.isPending).toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));
    final visibleRecords = _selectedTab == RecordsTab.pending
        ? pending
        : completed;
    final loadError = _selectedTab == RecordsTab.pending
        ? state.pendientesError
        : state.completosError;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      endDrawer: SideMenu(scaffoldKey: _scaffoldKey),
      bottomNavigationBar: const MindsaveBottomNavigation(currentIndex: 1),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(registroEstadoDeAnimoProvider.notifier)
              .refreshRegistros();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const MindsavePageIntro(
                      eyebrow: 'Registro CBT',
                      title: 'Mis registros',
                      description:
                          'Retoma un proceso pendiente o revisa lo que ya has trabajado.',
                    ),
                    const SizedBox(height: 22),
                    _RecordsTabs(
                      selected: _selectedTab,
                      pendingCount: pending.length,
                      completedCount: completed.length,
                      onSelected: (value) {
                        setState(() => _selectedTab = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    if (state.isLoading && state.registros.isEmpty)
                      const MindsaveLoadingView(
                        compact: true,
                        message: 'Cargando tus registros…',
                      )
                    else if (loadError != null && visibleRecords.isEmpty)
                      _RecordsLoadError(
                        message: loadError,
                        onRetry: () => ref
                            .read(registroEstadoDeAnimoProvider.notifier)
                            .refreshRegistros(),
                      )
                    else if (visibleRecords.isEmpty)
                      _EmptyRecordsState(tab: _selectedTab)
                    else ...[
                      for (final record in visibleRecords) ...[
                        if (_selectedTab == RecordsTab.pending)
                          _PendingRecordCard(record: record)
                        else
                          _CompletedRecordCard(record: record),
                        const SizedBox(height: 14),
                      ],
                      _LoadMoreButton(
                        tab: _selectedTab,
                        isLoading: state.isLoading,
                        isLastPage: _selectedTab == RecordsTab.pending
                            ? state.isLastPendientePage
                            : state.isLastCompletoPage,
                      ),
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

class _RecordsLoadError extends StatelessWidget {
  const _RecordsLoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MindsaveSectionCard(
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 44,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _RecordsTabs extends StatelessWidget {
  final RecordsTab selected;
  final int pendingCount;
  final int completedCount;
  final ValueChanged<RecordsTab> onSelected;

  const _RecordsTabs({
    required this.selected,
    required this.pendingCount,
    required this.completedCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RecordsTabButton(
              label: 'Pendientes',
              count: pendingCount,
              selected: selected == RecordsTab.pending,
              onTap: () => onSelected(RecordsTab.pending),
            ),
          ),
          Expanded(
            child: _RecordsTabButton(
              label: 'Completados',
              count: completedCount,
              selected: selected == RecordsTab.completed,
              onTap: () => onSelected(RecordsTab.completed),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordsTabButton extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _RecordsTabButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '$label, $count registros',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Container(
                constraints: const BoxConstraints(minWidth: 24),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingRecordCard extends StatelessWidget {
  final RegistroEstadoAnimo record;

  const _PendingRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _RecordProgress.fromRecord(record);
    final emotions = cbtEmotionGroups(
      record,
    ).expand((data) => data.selectedEmotions).take(3).toList();

    return MindsaveSectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateHelper.formatearFecha(record.fecha),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              _StatusBadge(
                label: 'EN PROGRESO',
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            record.sucesoTrastornador,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(height: 1.35),
          ),
          if (emotions.isNotEmpty) ...[
            const SizedBox(height: 13),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final emotion in emotions)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Text('●', style: TextStyle(fontSize: 9)),
                    label: Text(emotion),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Paso ${progress.completedStep} de 6 — ${progress.nextStepLabel}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '${(progress.completedStep / 6 * 100).round()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _SegmentedProgress(completedSteps: progress.completedStep),
          const SizedBox(height: 17),
          FilledButton.icon(
            onPressed: () => context.push(progress.route),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('Continuar desde el paso ${progress.completedStep}'),
          ),
        ],
      ),
    );
  }
}

class _CompletedRecordCard extends StatelessWidget {
  final RegistroEstadoAnimo record;

  const _CompletedRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final success = theme.brightness == Brightness.dark
        ? const Color(0xFF73D99A)
        : const Color(0xFF247A4A);
    final reduction = cbtEmotionalReduction(record);
    final selectedEmotionGroups = cbtEmotionGroups(
      record,
    ).where((data) => data.hasSelection).toList();
    final primaryEmotion = selectedEmotionGroups.isEmpty
        ? null
        : selectedEmotionGroups.first;

    return MindsaveSectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateHelper.formatearFecha(record.fecha),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              _StatusBadge(label: 'COMPLETADO', color: success),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            record.sucesoTrastornador,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 560;
              final halfWidth = (constraints.maxWidth - 10) / 2;
              final thirdWidth = (constraints.maxWidth - 20) / 3;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: wide ? thirdWidth : halfWidth,
                    child: _RecordMetric(
                      value: '$reduction%',
                      label: 'Reducción emocional',
                      icon: Icons.trending_down_rounded,
                    ),
                  ),
                  SizedBox(
                    width: wide ? thirdWidth : halfWidth,
                    child: _RecordMetric(
                      value: '${record.listaPensamientos.length}',
                      label: 'Pensamientos trabajados',
                      icon: Icons.psychology_alt_outlined,
                    ),
                  ),
                  if (primaryEmotion != null)
                    SizedBox(
                      width: wide ? thirdWidth : constraints.maxWidth,
                      child: _RecordMetric(
                        value:
                            '${primaryEmotion.emoji} ${primaryEmotion.title}',
                        label:
                            '${primaryEmotion.group.porcentajeCreenciaAntes ?? 0}% → ${primaryEmotion.group.porcentajeCreenciaDespues ?? 0}%',
                        icon: Icons.favorite_outline_rounded,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 17),
          OutlinedButton.icon(
            onPressed: () =>
                context.push('/registroEstadoAnimo/7/${record.id}'),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Ver detalle completo'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

class _SegmentedProgress extends StatelessWidget {
  final int completedSteps;

  const _SegmentedProgress({required this.completedSteps});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var index = 0; index < 6; index++) ...[
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: index < completedSteps
                    ? colors.primary
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          if (index < 5) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

class _RecordMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _RecordMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecordsState extends StatelessWidget {
  final RecordsTab tab;

  const _EmptyRecordsState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final pending = tab == RecordsTab.pending;
    final theme = Theme.of(context);
    return MindsaveSectionCard(
      padding: const EdgeInsets.fromLTRB(24, 38, 24, 30),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              pending ? Icons.task_alt_rounded : Icons.history_rounded,
              size: 34,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            pending ? 'Estás al día' : 'Aún no hay registros completados',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            pending
                ? 'No tienes procesos CBT pendientes. Puedes iniciar uno cuando lo necesites.'
                : 'Cuando completes un registro podrás volver aquí para revisar tus avances.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (pending) ...[
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => context.push('/registroEstadoAnimo/0'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Iniciar un nuevo registro'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadMoreButton extends ConsumerWidget {
  final RecordsTab tab;
  final bool isLoading;
  final bool isLastPage;

  const _LoadMoreButton({
    required this.tab,
    required this.isLoading,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLastPage) return const SizedBox.shrink();
    return TextButton(
      onPressed: isLoading
          ? null
          : () {
              final notifier = ref.read(registroEstadoDeAnimoProvider.notifier);
              if (tab == RecordsTab.pending) {
                notifier.loadNextPendientesPage();
              } else {
                notifier.loadNextCompletosPage();
              }
            },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: isLoading
            ? const Row(
                key: ValueKey('loading-more-records'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  MindsaveLoadingBar(
                    width: 48,
                    semanticsLabel: 'Cargando más registros',
                  ),
                  SizedBox(width: 12),
                  Text('Cargando registros…'),
                ],
              )
            : const Row(
                key: ValueKey('load-more-records'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.expand_more_rounded),
                  SizedBox(width: 8),
                  Text('Cargar más registros'),
                ],
              ),
      ),
    );
  }
}

class _RecordProgress {
  final int completedStep;
  final String nextStepLabel;
  final String route;

  const _RecordProgress({
    required this.completedStep,
    required this.nextStepLabel,
    required this.route,
  });

  factory _RecordProgress.fromRecord(RegistroEstadoAnimo record) {
    final hasDistortions = record.listaPensamientos.any(
      (thought) => thought.distorsion.any((selected) => selected),
    );
    if (!hasDistortions) {
      return _RecordProgress(
        completedStep: 3,
        nextStepLabel: 'Distorsiones',
        route: '/registroEstadoAnimo/3/${record.id}',
      );
    }

    final hasRestructuring = record.listaPensamientos.every(
      (thought) =>
          thought.pensamientoPositivo != null &&
          thought.porcentajeCreenciaPositivo != null,
    );
    if (!hasRestructuring) {
      return _RecordProgress(
        completedStep: 4,
        nextStepLabel: 'Reestructurar',
        route: '/registroEstadoAnimo/4/${record.id}',
      );
    }

    return _RecordProgress(
      completedStep: 5,
      nextStepLabel: 'Revisión',
      route: '/registroEstadoAnimo/5/${record.id}',
    );
  }
}
