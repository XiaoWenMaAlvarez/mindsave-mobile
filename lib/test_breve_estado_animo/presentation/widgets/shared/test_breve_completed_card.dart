import 'package:flutter/material.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';
import 'package:mindsave/test_breve_estado_animo/domain/entities/entities.dart';

class TestBreveCompletedCard extends StatelessWidget {
  const TestBreveCompletedCard({
    super.key,
    required this.result,
    required this.onViewResults,
    required this.onEdit,
    required this.onDelete,
  });

  final TestBreveEstadoDeAnimo result;
  final VoidCallback onViewResults;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total =
        result.sentimientosAnsiedadEmocionalTestBreve.totalScore +
        result.sentimientosAnsiedadFisicaTestBreve.totalScore +
        result.depresionTestBreve.totalScore +
        result.impulsoSuicidaTestBreve.totalScore;

    return Semantics(
      container: true,
      label: 'Evaluación de ánimo completada hoy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MindsaveSectionCard(
            color: colors.primaryContainer.withAlpha(55),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colors.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: colors.primary.withAlpha(100)),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: colors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completado hoy',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Respondido a las ${_formatTime(result.fechaCreacion)} · Puntuación: $total pts',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          MindsaveSectionCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'RESUMEN DE HOY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                _ScoreProgress(
                  label: 'Ansiedad emocional',
                  score:
                      result.sentimientosAnsiedadEmocionalTestBreve.totalScore,
                  maxScore: SentimientosAnsiedadEmocionalTestBreve.scoreMax,
                ),
                const SizedBox(height: 15),
                _ScoreProgress(
                  label: 'Ansiedad física',
                  score: result.sentimientosAnsiedadFisicaTestBreve.totalScore,
                  maxScore: SentimientosAnsiedadFisicaTestBreve.scoreMax,
                ),
                const SizedBox(height: 15),
                _ScoreProgress(
                  label: 'Estado de ánimo',
                  score: result.depresionTestBreve.totalScore,
                  maxScore: DepresionTestBreve.scoreMax,
                ),
                const SizedBox(height: 15),
                _ScoreProgress(
                  label: 'Seguridad personal',
                  score: result.impulsoSuicidaTestBreve.totalScore,
                  maxScore: ImpulsoSuicidaTestBreve.scoreMax,
                  highlight: result.impulsoSuicidaTestBreve.totalScore > 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const Key('view-completed-test-results'),
            onPressed: onViewResults,
            icon: const Icon(Icons.bar_chart_rounded),
            label: const Text('Ver resultados completos'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('edit-completed-test'),
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('delete-completed-test'),
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error.withAlpha(95)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreProgress extends StatelessWidget {
  const _ScoreProgress({
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
    final colors = theme.colorScheme;
    final accent = highlight ? colors.error : colors.primary;
    final progress = maxScore == 0 ? 0.0 : (score / maxScore).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              '$score/$maxScore',
              style: theme.textTheme.labelMedium?.copyWith(
                color: highlight ? colors.error : colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            color: accent,
            backgroundColor: accent.withAlpha(22),
          ),
        ),
      ],
    );
  }
}

String _formatTime(DateTime date) {
  final hour = (date.hour - 4).toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
