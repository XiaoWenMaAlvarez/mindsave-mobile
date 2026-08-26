import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/config/helpers/date_helper.dart';
import 'package:mindsave/home/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/infrastructure/files/mindsave_file_saver.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';
import 'package:mindsave/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/test_breve_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/test_breve_estado_animo/presentation/services/test_breve_results_exporter.dart';
import 'package:mindsave/test_breve_estado_animo/presentation/widgets/widgets.dart';

const _months = <String>[
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

enum _ExportFormat { pdf, excel }

class TestBreveEstadoAnimoDetailsYearResultsScreen
    extends ConsumerStatefulWidget {
  const TestBreveEstadoAnimoDetailsYearResultsScreen({super.key});

  @override
  ConsumerState<TestBreveEstadoAnimoDetailsYearResultsScreen> createState() =>
      _TestBreveEstadoAnimoDetailsYearResultsScreenState();
}

class _TestBreveEstadoAnimoDetailsYearResultsScreenState
    extends ConsumerState<TestBreveEstadoAnimoDetailsYearResultsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _ExportFormat? _exporting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final year = ref.read(selectedYearProvider);
      ref
          .read(testBreveEstadoDeAnimoProvider.notifier)
          .loadTestBreveEstadoDeAnimoByYear(year);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final tests =
        ref
            .watch(testBreveEstadoDeAnimoProvider)
            .where((test) => test.fechaCreacion.year == selectedYear)
            .toList()
          ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    final testsByMonth = List.generate(
      12,
      (monthIndex) => tests
          .where((test) => test.fechaCreacion.month == monthIndex + 1)
          .toList(),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      endDrawer: SideMenu(scaffoldKey: _scaffoldKey),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.push('/testBreveEstadoAnimo/2'),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Seguimiento'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const MindsavePageIntro(
                    eyebrow: 'Seguimiento anual',
                    title: 'Resultados en detalle',
                    description:
                        'Explora cada evaluación y observa cómo fue cambiando tu ánimo durante el año.',
                  ),
                  const SizedBox(height: 20),
                  _YearSelector(
                    selectedYear: selectedYear,
                    onChanged: _changeYear,
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(minHeight: 4),
                  ],
                  const SizedBox(height: 16),
                  _YearSummary(tests: tests),
                  const SizedBox(height: 14),
                  _ExportCard(
                    enabled: tests.isNotEmpty && !isLoading,
                    exporting: _exporting,
                    onExport: (format) => _exportResults(
                      format: format,
                      year: selectedYear,
                      tests: tests,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Evaluaciones por mes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Los meses con registros aparecen primero. Selecciona una fecha para revisar sus resultados.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (isLoading && tests.isEmpty)
                    const _LoadingMonths()
                  else if (tests.isEmpty)
                    _EmptyYear(year: selectedYear)
                  else
                    _MonthsList(
                      testsByMonth: testsByMonth,
                      selectedYear: selectedYear,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeYear(int? year) async {
    if (year == null || year == ref.read(selectedYearProvider)) return;
    ref.read(selectedYearProvider.notifier).select(year);
    await ref
        .read(testBreveEstadoDeAnimoProvider.notifier)
        .loadTestBreveEstadoDeAnimoByYear(year);
  }

  Future<void> _exportResults({
    required _ExportFormat format,
    required int year,
    required List<TestBreveEstadoDeAnimo> tests,
  }) async {
    if (_exporting != null || tests.isEmpty) return;

    setState(() => _exporting = format);
    try {
      final file = switch (format) {
        _ExportFormat.pdf => await TestBreveResultsExporter.pdf(
          year: year,
          tests: tests,
        ),
        _ExportFormat.excel => TestBreveResultsExporter.excel(
          year: year,
          tests: tests,
        ),
      };

      if (!mounted) return;
      final savedPath = await MindsaveFileSaver.saveAs(
        bytes: file.bytes,
        fileName: file.fileName,
        mimeType: file.mimeType,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath == null
                ? 'Guardado cancelado.'
                : 'Archivo guardado correctamente: ${file.fileName}',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible preparar el archivo. Inténtalo nuevamente.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = null);
    }
  }
}

class _YearSelector extends StatelessWidget {
  const _YearSelector({required this.selectedYear, required this.onChanged});

  final int selectedYear;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final years = [
      for (var year = DateTime.now().year; year >= 2024; year--) year,
    ];

    return MindsaveSectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(24),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Período', style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                Text('Año seleccionado', style: theme.textTheme.titleSmall),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedYear,
              borderRadius: BorderRadius.circular(16),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              icon: const Icon(Icons.expand_more_rounded),
              items: [
                for (final year in years)
                  DropdownMenuItem(value: year, child: Text('$year')),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _YearSummary extends StatelessWidget {
  const _YearSummary({required this.tests});

  final List<TestBreveEstadoDeAnimo> tests;

  @override
  Widget build(BuildContext context) {
    final activeMonths = tests.map((test) => test.fechaCreacion.month).toSet();
    final latest = tests.isEmpty ? null : tests.first.fechaCreacion;

    return MindsaveSectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _SummaryMetric(
              icon: Icons.assignment_turned_in_outlined,
              value: '${tests.length}',
              label: 'Evaluaciones',
            ),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryMetric(
              icon: Icons.date_range_outlined,
              value: '${activeMonths.length}',
              label: 'Meses activos',
            ),
          ),
          const _SummaryDivider(),
          Expanded(
            child: _SummaryMetric(
              icon: Icons.history_rounded,
              value: latest == null
                  ? '—'
                  : '${latest.day.toString().padLeft(2, '0')}/${latest.month.toString().padLeft(2, '0')}',
              label: 'Último registro',
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({
    required this.enabled,
    required this.exporting,
    required this.onExport,
  });

  final bool enabled;
  final _ExportFormat? exporting;
  final ValueChanged<_ExportFormat> onExport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return MindsaveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withAlpha(24),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.download_outlined, color: colors.primary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descargar resultados',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      enabled
                          ? 'Guarda un resumen simple del año en el formato que prefieras.'
                          : 'Selecciona un año que tenga evaluaciones para descargarlo.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackButtons = constraints.maxWidth < 440;
              final pdfButton = FilledButton.icon(
                key: const Key('download-test-results-pdf'),
                onPressed: enabled && exporting == null
                    ? () => onExport(_ExportFormat.pdf)
                    : null,
                icon: _ExportIcon(
                  isLoading: exporting == _ExportFormat.pdf,
                  icon: Icons.picture_as_pdf_outlined,
                ),
                label: const Text('Descargar PDF'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB3261E),
                  foregroundColor: Colors.white,
                ),
              );
              final excelButton = FilledButton.icon(
                key: const Key('download-test-results-excel'),
                onPressed: enabled && exporting == null
                    ? () => onExport(_ExportFormat.excel)
                    : null,
                icon: _ExportIcon(
                  isLoading: exporting == _ExportFormat.excel,
                  icon: Icons.table_view_outlined,
                ),
                label: const Text('Descargar Excel'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B7F4B),
                  foregroundColor: Colors.white,
                ),
              );

              if (stackButtons) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    pdfButton,
                    const SizedBox(height: 10),
                    excelButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: pdfButton),
                  const SizedBox(width: 10),
                  Expanded(child: excelButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExportIcon extends StatelessWidget {
  const _ExportIcon({required this.isLoading, required this.icon});

  final bool isLoading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return Icon(icon);
    return const SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: Column(
        children: [
          Icon(icon, size: 21, color: theme.colorScheme.primary),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 66,
      color: Theme.of(context).colorScheme.outlineVariant.withAlpha(120),
    );
  }
}

class _MonthsList extends StatelessWidget {
  const _MonthsList({required this.testsByMonth, required this.selectedYear});

  final List<List<TestBreveEstadoDeAnimo>> testsByMonth;
  final int selectedYear;

  @override
  Widget build(BuildContext context) {
    final nonEmptyMonths = [
      for (var index = 0; index < testsByMonth.length; index++)
        if (testsByMonth[index].isNotEmpty) index,
    ];
    final latestMonth = nonEmptyMonths.isEmpty ? -1 : nonEmptyMonths.last;
    final emptyMonths = [
      for (var index = 0; index < testsByMonth.length; index++)
        if (testsByMonth[index].isEmpty) index,
    ];
    final orderedMonths = [...nonEmptyMonths.reversed, ...emptyMonths.reversed];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Evaluaciones mensuales de $selectedYear',
      child: Column(
        children: [
          for (
            var orderIndex = 0;
            orderIndex < orderedMonths.length;
            orderIndex++
          ) ...[
            _MonthCard(
              month: orderedMonths[orderIndex] + 1,
              monthName: _months[orderedMonths[orderIndex]],
              tests: testsByMonth[orderedMonths[orderIndex]],
              initiallyExpanded: orderedMonths[orderIndex] == latestMonth,
            ),
            if (orderIndex < orderedMonths.length - 1)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.monthName,
    required this.tests,
    required this.initiallyExpanded,
  });

  final int month;
  final String monthName;
  final List<TestBreveEstadoDeAnimo> tests;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sortedTests = [...tests]
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

    return MindsaveSectionCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        key: PageStorageKey('details-month-$month'),
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: tests.isEmpty
                ? colors.surfaceContainerHighest
                : colors.primary.withAlpha(24),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            tests.isEmpty
                ? Icons.event_busy_outlined
                : Icons.event_note_outlined,
            color: tests.isEmpty ? colors.onSurfaceVariant : colors.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(monthName)),
            Container(
              constraints: const BoxConstraints(minWidth: 26),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tests.isEmpty
                    ? colors.surfaceContainerHighest
                    : colors.primary,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '${tests.length}',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tests.isEmpty
                      ? colors.onSurfaceVariant
                      : colors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          tests.isEmpty
              ? 'Sin evaluaciones'
              : '${tests.length} ${tests.length == 1 ? 'evaluación' : 'evaluaciones'}',
        ),
        children: [
          Divider(color: colors.outlineVariant.withAlpha(120)),
          if (sortedTests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No registraste evaluaciones durante este mes.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            for (var index = 0; index < sortedTests.length; index++) ...[
              _DayResultTile(test: sortedTests[index]),
              if (index < sortedTests.length - 1) const SizedBox(height: 9),
            ],
        ],
      ),
    );
  }
}

class _DayResultTile extends StatelessWidget {
  const _DayResultTile({required this.test});

  final TestBreveEstadoDeAnimo test;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final date = test.fechaCreacion;

    return Semantics(
      button: true,
      label: 'Ver evaluación del ${DateHelper.formatearFecha(date)}',
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => showTestBreveResultDetails(context, test),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Evaluación diaria',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateHelper.formatearFecha(date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: colors.primary),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _ScorePill(
                      label: 'Emocional',
                      score: test
                          .sentimientosAnsiedadEmocionalTestBreve
                          .totalScore,
                      maxScore: SentimientosAnsiedadEmocionalTestBreve.scoreMax,
                    ),
                    _ScorePill(
                      label: 'Física',
                      score:
                          test.sentimientosAnsiedadFisicaTestBreve.totalScore,
                      maxScore: SentimientosAnsiedadFisicaTestBreve.scoreMax,
                    ),
                    _ScorePill(
                      label: 'Ánimo',
                      score: test.depresionTestBreve.totalScore,
                      maxScore: DepresionTestBreve.scoreMax,
                    ),
                    _ScorePill(
                      label: 'Seguridad',
                      score: test.impulsoSuicidaTestBreve.totalScore,
                      maxScore: ImpulsoSuicidaTestBreve.scoreMax,
                      highlight: test.impulsoSuicidaTestBreve.totalScore > 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.label,
    required this.score,
    required this.maxScore,
    this.highlight = false,
  });

  final String label;
  final int score;
  final int maxScore;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlight
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Text(
        '$label $score/$maxScore',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyYear extends StatelessWidget {
  const _EmptyYear({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MindsaveSectionCard(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 30),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            'Sin evaluaciones en $year',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando completes un test, podrás revisar aquí su fecha y resultados.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.push('/testBreveEstadoAnimo/0'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Realizar test'),
          ),
        ],
      ),
    );
  }
}

class _LoadingMonths extends StatelessWidget {
  const _LoadingMonths();

  @override
  Widget build(BuildContext context) {
    return const MindsaveSectionCard(
      padding: EdgeInsets.zero,
      child: MindsaveLoadingView(
        compact: true,
        message: 'Cargando evaluaciones…',
      ),
    );
  }
}

Future<void> showTestBreveResultDetails(
  BuildContext context,
  TestBreveEstadoDeAnimo test,
) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: .92,
      child: _ResultDetailsSheet(test: test),
    ),
  );
}

class _ResultDetailsSheet extends StatelessWidget {
  const _ResultDetailsSheet({required this.test});

  final TestBreveEstadoDeAnimo test;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final safetyHighlight = test.impulsoSuicidaTestBreve.totalScore > 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalle de la evaluación',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateHelper.formatearFecha(test.fechaCreacion),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Cerrar detalle',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (safetyHighlight) ...[
                        MindsaveSectionCard(
                          color: colors.errorContainer,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.health_and_safety_outlined,
                                color: colors.error,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tu seguridad es prioritaria',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: colors.onErrorContainer,
                                          ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      test.impulsoSuicidaTestBreve.result,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colors.onErrorContainer,
                                            height: 1.4,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _DetailScoreCard(
                        icon: Icons.psychology_outlined,
                        title: 'Ansiedad emocional',
                        score: test
                            .sentimientosAnsiedadEmocionalTestBreve
                            .totalScore,
                        maxScore:
                            SentimientosAnsiedadEmocionalTestBreve.scoreMax,
                        result:
                            test.sentimientosAnsiedadEmocionalTestBreve.result,
                        description: test
                            .sentimientosAnsiedadEmocionalTestBreve
                            .resultDescription,
                      ),
                      const SizedBox(height: 10),
                      _DetailScoreCard(
                        icon: Icons.monitor_heart_outlined,
                        title: 'Ansiedad física',
                        score:
                            test.sentimientosAnsiedadFisicaTestBreve.totalScore,
                        maxScore: SentimientosAnsiedadFisicaTestBreve.scoreMax,
                        result: test.sentimientosAnsiedadFisicaTestBreve.result,
                        description: test
                            .sentimientosAnsiedadFisicaTestBreve
                            .resultDescription,
                      ),
                      const SizedBox(height: 10),
                      _DetailScoreCard(
                        icon: Icons.cloud_outlined,
                        title: 'Estado de ánimo',
                        score: test.depresionTestBreve.totalScore,
                        maxScore: DepresionTestBreve.scoreMax,
                        result: test.depresionTestBreve.result,
                        description: test.depresionTestBreve.resultDescription,
                      ),
                      const SizedBox(height: 10),
                      _DetailScoreCard(
                        icon: Icons.health_and_safety_outlined,
                        title: 'Seguridad personal',
                        score: test.impulsoSuicidaTestBreve.totalScore,
                        maxScore: ImpulsoSuicidaTestBreve.scoreMax,
                        result: test.impulsoSuicidaTestBreve.result,
                        description:
                            test.impulsoSuicidaTestBreve.resultDescription,
                        highlight: safetyHighlight,
                      ),
                      if (test.notas?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        MindsaveSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notes_rounded,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    'Notas',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 9),
                              Text(
                                test.notas!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      MindsaveSectionCard(
                        color: colors.primaryContainer.withAlpha(90),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                'Estos resultados sirven para observar tendencias y no reemplazan una evaluación profesional.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailScoreCard extends StatelessWidget {
  const _DetailScoreCard({
    required this.icon,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.result,
    required this.description,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final int score;
  final int maxScore;
  final String result;
  final String description;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = highlight ? colors.error : colors.primary;
    final progress = maxScore <= 0 ? 0.0 : (score / maxScore).clamp(0.0, 1.0);

    return MindsaveSectionCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: accent.withAlpha(24),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accent),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title)),
            Text(
              '$score/$maxScore',
              style: theme.textTheme.titleMedium?.copyWith(color: accent),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: accent,
                  backgroundColor: accent.withAlpha(26),
                ),
              ),
              const SizedBox(height: 7),
              Text(result, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
