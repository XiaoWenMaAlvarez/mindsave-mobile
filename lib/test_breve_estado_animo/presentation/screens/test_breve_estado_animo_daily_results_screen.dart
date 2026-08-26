import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba/config/helpers/date_helper.dart';
import 'package:prueba/home/presentation/widgets/widgets.dart';
import 'package:prueba/shared/presentation/widgets/mindsave_ui.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:prueba/test_breve_estado_animo/presentation/providers/providers.dart';
import 'package:prueba/test_breve_estado_animo/presentation/widgets/widgets.dart';

class TestBreveEstadoAnimoDailyResultsScreen extends ConsumerStatefulWidget {
  const TestBreveEstadoAnimoDailyResultsScreen({super.key});

  @override
  ConsumerState<TestBreveEstadoAnimoDailyResultsScreen> createState() =>
      _TestBreveEstadoAnimoDailyResultsScreenState();
}

class _TestBreveEstadoAnimoDailyResultsScreenState
    extends ConsumerState<TestBreveEstadoAnimoDailyResultsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(todayTestBreveEstadoDeAnimoProvider.notifier)
          .setTestBreveRealizadoHoy();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final result = ref.watch(todayTestBreveEstadoDeAnimoProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      endDrawer: SideMenu(scaffoldKey: _scaffoldKey),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
      body: isLoading
          ? const MindsaveLoadingView(message: 'Cargando tus resultados…')
          : result == null
          ? const _EmptyResult()
          : _ResultContent(result: result),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Aún no hay resultados de hoy',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Completa la evaluación breve para obtener una lectura de cómo te has sentido.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push('/testBreveEstadoAnimo/0'),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Realizar test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  final TestBreveEstadoDeAnimo result;

  const _ResultContent({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MindsavePageIntro(
                  eyebrow: 'Evaluación diaria',
                  title: 'Tus resultados de hoy',
                  description:
                      'Estos valores son una guía para observar tendencias, no un diagnóstico.',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 17,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateHelper.formatearFecha(result.fechaCreacion),
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _ScoreCard(
                  icon: Icons.psychology_outlined,
                  title: 'Ansiedad emocional',
                  score:
                      result.sentimientosAnsiedadEmocionalTestBreve.totalScore,
                  maxScore: SentimientosAnsiedadEmocionalTestBreve.scoreMax,
                  description: result
                      .sentimientosAnsiedadEmocionalTestBreve
                      .resultDescription,
                ),
                const SizedBox(height: 12),
                _ScoreCard(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Síntomas físicos de ansiedad',
                  score: result.sentimientosAnsiedadFisicaTestBreve.totalScore,
                  maxScore: SentimientosAnsiedadFisicaTestBreve.scoreMax,
                  description: result
                      .sentimientosAnsiedadFisicaTestBreve
                      .resultDescription,
                ),
                const SizedBox(height: 12),
                _ScoreCard(
                  icon: Icons.cloud_outlined,
                  title: 'Estado de ánimo',
                  score: result.depresionTestBreve.totalScore,
                  maxScore: DepresionTestBreve.scoreMax,
                  description: result.depresionTestBreve.resultDescription,
                ),
                const SizedBox(height: 12),
                _ScoreCard(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Seguridad personal',
                  score: result.impulsoSuicidaTestBreve.totalScore,
                  maxScore: ImpulsoSuicidaTestBreve.scoreMax,
                  description: result.impulsoSuicidaTestBreve.resultDescription,
                  highlight: result.impulsoSuicidaTestBreve.totalScore > 0,
                ),
                if (result.notas?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  MindsaveSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tus notas', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          result.notas!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                MindsaveSectionCard(
                  color: theme.colorScheme.primaryContainer.withAlpha(95),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.spa_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No es necesario sentirse bien todo el tiempo. Lo importante es reconocer los cambios y usar las herramientas que ya estás practicando.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/testBreveEstadoAnimo/2'),
                    icon: const Icon(Icons.insights_rounded),
                    label: const Text('Ver mi seguimiento'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int score;
  final int maxScore;
  final String description;
  final bool highlight;

  const _ScoreCard({
    required this.icon,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.description,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = highlight
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final progress = maxScore <= 0 ? 0.0 : (score / maxScore).clamp(0.0, 1.0);
    return MindsaveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              Text(
                '$score',
                style: theme.textTheme.headlineSmall?.copyWith(color: accent),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              color: accent,
              backgroundColor: accent.withAlpha(28),
            ),
          ),
          const SizedBox(height: 11),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
