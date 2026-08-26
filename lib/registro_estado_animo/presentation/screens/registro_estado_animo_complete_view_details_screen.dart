import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/config/helpers/date_helper.dart';
import 'package:mindsave/home/presentation/widgets/widgets.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/registro_estado_animo/presentation/services/cbt_record_exporter.dart';
import 'package:mindsave/registro_estado_animo/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/infrastructure/files/mindsave_file_saver.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

enum _CbtExportFormat { pdf, excel }

class RegistroEstadoAnimoCompleteViewDetailsScreen
    extends ConsumerStatefulWidget {
  const RegistroEstadoAnimoCompleteViewDetailsScreen({
    super.key,
    required this.idRegistroEstadoAnimo,
  });

  final String idRegistroEstadoAnimo;

  @override
  ConsumerState<RegistroEstadoAnimoCompleteViewDetailsScreen> createState() =>
      _RegistroEstadoAnimoCompleteViewDetailsScreenState();
}

class _RegistroEstadoAnimoCompleteViewDetailsScreenState
    extends ConsumerState<RegistroEstadoAnimoCompleteViewDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _CbtExportFormat? _exporting;

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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      endDrawer: SideMenu(scaffoldKey: _scaffoldKey),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
      body: record == null
          ? const MindsaveLoadingView(message: 'Cargando tu registro…')
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: _DetailsContent(
                      record: record,
                      isLoading: state.isLoading,
                      exporting: _exporting,
                      onExport: (format) => _exportRecord(record, format),
                      onDelete: () => _confirmDelete(record),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _exportRecord(
    RegistroEstadoAnimo record,
    _CbtExportFormat format,
  ) async {
    if (_exporting != null) return;
    setState(() => _exporting = format);
    try {
      final file = switch (format) {
        _CbtExportFormat.pdf => await CbtRecordExporter.pdf(record),
        _CbtExportFormat.excel => CbtRecordExporter.excel(record),
      };
      if (!mounted) return;
      final savedPath = await MindsaveFileSaver.saveAs(
        bytes: file.bytes,
        fileName: file.fileName,
        mimeType: file.mimeType,
      );
      if (!mounted) return;
      showCbtMessage(
        context,
        savedPath == null
            ? 'Guardado cancelado.'
            : 'Archivo guardado correctamente: ${file.fileName}',
      );
    } catch (_) {
      if (!mounted) return;
      showCbtMessage(
        context,
        'No fue posible preparar el archivo. Inténtalo nuevamente.',
      );
    } finally {
      if (mounted) setState(() => _exporting = null);
    }
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

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.record,
    required this.isLoading,
    required this.exporting,
    required this.onExport,
    required this.onDelete,
  });

  final RegistroEstadoAnimo record;
  final bool isLoading;
  final _CbtExportFormat? exporting;
  final ValueChanged<_CbtExportFormat> onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final groups = cbtEmotionGroups(
      record,
    ).where((data) => data.hasSelection).toList();
    final reduction = cbtEmotionalReduction(record);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.push('/registros'),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Mis registros'),
          ),
        ),
        const SizedBox(height: 4),
        MindsavePageIntro(
          eyebrow: 'Registro CBT · ${DateHelper.formatearFecha(record.fecha)}',
          title: 'Detalle del registro',
          description:
              'Revisa el cambio emocional y las alternativas que construiste.',
        ),
        const SizedBox(height: 22),
        MindsaveSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('CONTEXTO', style: theme.textTheme.labelMedium),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withAlpha(22),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'COMPLETADO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                record.sucesoTrastornador,
                style: theme.textTheme.titleMedium?.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final metrics = [
              _DetailMetric(
                icon: Icons.trending_down_rounded,
                value: '$reduction%',
                label: 'Reducción emocional',
              ),
              _DetailMetric(
                icon: Icons.psychology_alt_outlined,
                value: '${record.listaPensamientos.length}',
                label: 'Pensamientos trabajados',
              ),
              _DetailMetric(
                icon: Icons.favorite_outline_rounded,
                value: '${groups.length}',
                label: 'Emociones revisadas',
              ),
            ];
            if (constraints.maxWidth < 520) {
              return Column(
                children: [
                  for (var index = 0; index < metrics.length; index++) ...[
                    metrics[index],
                    if (index < metrics.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < metrics.length; index++) ...[
                  Expanded(child: metrics[index]),
                  if (index < metrics.length - 1) const SizedBox(width: 10),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 26),
        Text('Evolución emocional', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Cómo cambió la intensidad después de reestructurar tus pensamientos.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        for (final data in groups)
          CustomGrupoEmocionesCompleto(
            title: data.title,
            emoji: data.emoji,
            grupoEmociones: data.group,
          ),
        const SizedBox(height: 14),
        Text('Reestructuración', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Pensamientos automáticos, distorsiones y alternativas más equilibradas.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < record.listaPensamientos.length; index++)
          ListaPensamientosCompleto(
            title: 'Pensamiento ${index + 1}',
            pensamiento: record.listaPensamientos[index],
          ),
        const SizedBox(height: 4),
        _RecordExportCard(exporting: exporting, onExport: onExport),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: isLoading || exporting != null
              ? null
              : () => context.push('/registroEstadoAnimo/6/${record.id}'),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar registro'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: isLoading || exporting != null ? null : onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Eliminar registro'),
          style: TextButton.styleFrom(foregroundColor: colors.error),
        ),
      ],
    );
  }
}

class _RecordExportCard extends StatelessWidget {
  const _RecordExportCard({required this.exporting, required this.onExport});

  final _CbtExportFormat? exporting;
  final ValueChanged<_CbtExportFormat> onExport;

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
                      'Descargar este registro',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Guarda un resumen simple y personal en el formato que prefieras.',
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
                key: const Key('download-cbt-record-pdf'),
                onPressed: exporting == null
                    ? () => onExport(_CbtExportFormat.pdf)
                    : null,
                icon: _ExportIcon(
                  isLoading: exporting == _CbtExportFormat.pdf,
                  icon: Icons.picture_as_pdf_outlined,
                ),
                label: const Text('Descargar PDF'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB3261E),
                  foregroundColor: Colors.white,
                ),
              );
              final excelButton = FilledButton.icon(
                key: const Key('download-cbt-record-excel'),
                onPressed: exporting == null
                    ? () => onExport(_CbtExportFormat.excel)
                    : null,
                icon: _ExportIcon(
                  isLoading: exporting == _CbtExportFormat.excel,
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

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
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
    return MindsaveSectionCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
