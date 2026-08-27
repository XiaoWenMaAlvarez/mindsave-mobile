import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/test_breve_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/test_breve_estado_animo/presentation/widgets/widgets.dart';
import 'package:mindsave/home/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

class TestBreveEstadoAnimoYearResultsScreen extends StatefulWidget {
  const TestBreveEstadoAnimoYearResultsScreen({super.key});

  @override
  State<TestBreveEstadoAnimoYearResultsScreen> createState() =>
      _TestBreveEstadoAnimoYearResultsScreenState();
}

class _TestBreveEstadoAnimoYearResultsScreenState
    extends State<TestBreveEstadoAnimoYearResultsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      body: _FollowUpView(),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: 2),
      endDrawer: SideMenu(scaffoldKey: _scaffoldKey),
    );
  }
}

class _FollowUpView extends StatelessWidget {
  const _FollowUpView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: const _FollowUpViewBody(),
          ),
        ),
      ],
    );
  }
}

class _FollowUpViewBody extends ConsumerStatefulWidget {
  const _FollowUpViewBody();

  @override
  ConsumerState<_FollowUpViewBody> createState() => _FollowUpViewState();
}

class _FollowUpViewState extends ConsumerState<_FollowUpViewBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadYear(DateTime.now().year);
    });
  }

  Future<void> _loadYear(int year) async {
    final error = await ref
        .read(testBreveEstadoDeAnimoProvider.notifier)
        .loadTestBreveEstadoDeAnimoByYear(year);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(isLoadingProvider);
    if (isLoading) {
      return const MindsaveLoadingView(message: 'Cargando tu seguimiento…');
    }

    int yearSelected = ref.watch(selectedYearProvider);

    List<TestBreveEstadoDeAnimo> testsBreveEstadoDeAnimo = ref
        .watch(testBreveEstadoDeAnimoProvider)
        .where(
          (testBreveEstadoDeAnimo) =>
              testBreveEstadoDeAnimo.fechaCreacion.toLocal().year ==
              yearSelected,
        )
        .toList();

    TextStyle bodyStyle = Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(fontSize: 16);

    Color primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitleAndYear(
          yearSelected: yearSelected,
          onChanged: (value) {
            if (value == null) return;
            ref.read(selectedYearProvider.notifier).select(value);
            _loadYear(value);
          },
        ),
        const SizedBox(height: 20),
        MindsaveSectionCard(
          child: _HistogramaAnsiedadEmocional(testsBreveEstadoDeAnimo),
        ),
        const SizedBox(height: 12),
        MindsaveSectionCard(
          child: _HistogramaAnsiedadFisica(testsBreveEstadoDeAnimo),
        ),
        const SizedBox(height: 12),
        MindsaveSectionCard(
          child: _HistogramaDepresion(testsBreveEstadoDeAnimo),
        ),
        const SizedBox(height: 12),
        MindsaveSectionCard(
          child: _HistogramaImpulsosSuicidas(testsBreveEstadoDeAnimo),
        ),
        const SizedBox(height: 18),
        TextButton(
          child: Text(
            "Exportar resultados",
            style: bodyStyle.copyWith(color: primaryColor),
          ),
          onPressed: () => context.push("/testBreveEstadoAnimo/3"),
        ),
      ],
    );
  }
}

class TitleAndYear extends StatelessWidget {
  final int yearSelected;
  final Function(int?) onChanged;

  const TitleAndYear({
    super.key,
    required this.yearSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MindsavePageIntro(
          eyebrow: 'Tu progreso',
          title: 'Seguimiento del ánimo',
          description:
              'Observa los cambios a lo largo del tiempo. Los días sin registro quedan vacíos.',
        ),
        const SizedBox(height: 18),
        MindsaveSectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: RadioGroup(
            groupValue: yearSelected,
            onChanged: onChanged,
            child: ExpansionTile(
              leading: Icon(
                Icons.calendar_month_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Año seleccionado',
                style: theme.textTheme.titleSmall,
              ),
              subtitle: Text('$yearSelected'),
              shape: const Border(),
              collapsedShape: const Border(),
              children: [
                for (int i = 2024; i <= DateTime.now().year; i++)
                  RadioListTile(title: Text('$i'), value: i),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistogramaAnsiedadEmocional extends StatelessWidget {
  final List<TestBreveEstadoDeAnimo> testsBreveEstadoDeAnimo;

  const _HistogramaAnsiedadEmocional(this.testsBreveEstadoDeAnimo);

  @override
  Widget build(BuildContext context) {
    List<List<int?>> scoreAnsiedadEmocionalPorAnio = [
      for (int i = 0; i < 12; i++) [for (int i = 0; i < 31; i++) null],
    ];

    for (TestBreveEstadoDeAnimo testBreveEstadoDeAnimo
        in testsBreveEstadoDeAnimo) {
      final localDate = testBreveEstadoDeAnimo.fechaCreacion.toLocal();
      int month = localDate.month - 1;
      int day = localDate.day - 1;
      scoreAnsiedadEmocionalPorAnio[month][day] = testBreveEstadoDeAnimo
          .sentimientosAnsiedadEmocionalTestBreve
          .totalScore;
    }

    int minScore = SentimientosAnsiedadEmocionalTestBreve.scoreMin;
    int maxScore = SentimientosAnsiedadEmocionalTestBreve.scoreMax;

    String title = "Sentimientos de ansiedad emocional";

    return CustomHistogram(
      title: title,
      minValue: minScore,
      maxValue: maxScore,
      horizontalInterval: 5,
      data: scoreAnsiedadEmocionalPorAnio,
    );
  }
}

class _HistogramaAnsiedadFisica extends StatelessWidget {
  final List<TestBreveEstadoDeAnimo> testsBreveEstadoDeAnimo;

  const _HistogramaAnsiedadFisica(this.testsBreveEstadoDeAnimo);

  @override
  Widget build(BuildContext context) {
    List<List<int?>> scoreAnsiedadFisicaPorAnio = [
      for (int i = 0; i < 12; i++) [for (int i = 0; i < 31; i++) null],
    ];

    for (TestBreveEstadoDeAnimo testBreveEstadoDeAnimo
        in testsBreveEstadoDeAnimo) {
      final localDate = testBreveEstadoDeAnimo.fechaCreacion.toLocal();
      int month = localDate.month - 1;
      int day = localDate.day - 1;
      scoreAnsiedadFisicaPorAnio[month][day] =
          testBreveEstadoDeAnimo.sentimientosAnsiedadFisicaTestBreve.totalScore;
    }

    int minScore = SentimientosAnsiedadFisicaTestBreve.scoreMin;
    int maxScore = SentimientosAnsiedadFisicaTestBreve.scoreMax;

    String title = "Sentimientos de ansiedad física";

    return CustomHistogram(
      title: title,
      minValue: minScore,
      maxValue: maxScore,
      horizontalInterval: 10,
      data: scoreAnsiedadFisicaPorAnio,
    );
  }
}

class _HistogramaDepresion extends StatelessWidget {
  final List<TestBreveEstadoDeAnimo> testsBreveEstadoDeAnimo;

  const _HistogramaDepresion(this.testsBreveEstadoDeAnimo);

  @override
  Widget build(BuildContext context) {
    List<List<int?>> scoreDepresionPorAnio = [
      for (int i = 0; i < 12; i++) [for (int i = 0; i < 31; i++) null],
    ];

    for (TestBreveEstadoDeAnimo testBreveEstadoDeAnimo
        in testsBreveEstadoDeAnimo) {
      final localDate = testBreveEstadoDeAnimo.fechaCreacion.toLocal();
      int month = localDate.month - 1;
      int day = localDate.day - 1;
      scoreDepresionPorAnio[month][day] =
          testBreveEstadoDeAnimo.depresionTestBreve.totalScore;
    }

    int minScore = DepresionTestBreve.scoreMin;
    int maxScore = DepresionTestBreve.scoreMax;

    String title = "Depresión";

    return CustomHistogram(
      title: title,
      minValue: minScore,
      maxValue: maxScore,
      horizontalInterval: 5,
      data: scoreDepresionPorAnio,
    );
  }
}

class _HistogramaImpulsosSuicidas extends StatelessWidget {
  final List<TestBreveEstadoDeAnimo> testsBreveEstadoDeAnimo;

  const _HistogramaImpulsosSuicidas(this.testsBreveEstadoDeAnimo);

  @override
  Widget build(BuildContext context) {
    List<List<int?>> scoreImpulsosSuicidasPorAnio = [
      for (int i = 0; i < 12; i++) [for (int i = 0; i < 31; i++) null],
    ];

    for (TestBreveEstadoDeAnimo testBreveEstadoDeAnimo
        in testsBreveEstadoDeAnimo) {
      final localDate = testBreveEstadoDeAnimo.fechaCreacion.toLocal();
      int month = localDate.month - 1;
      int day = localDate.day - 1;
      scoreImpulsosSuicidasPorAnio[month][day] =
          testBreveEstadoDeAnimo.impulsoSuicidaTestBreve.totalScore;
    }

    int minScore = ImpulsoSuicidaTestBreve.scoreMin;
    int maxScore = ImpulsoSuicidaTestBreve.scoreMax;

    String title = "Impulsos suicidas";

    return CustomHistogram(
      title: title,
      minValue: minScore,
      maxValue: maxScore,
      horizontalInterval: 2,
      data: scoreImpulsosSuicidasPorAnio,
    );
  }
}
