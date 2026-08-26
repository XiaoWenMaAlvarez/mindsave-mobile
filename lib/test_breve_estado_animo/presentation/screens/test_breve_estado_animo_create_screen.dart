import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:prueba/test_breve_estado_animo/presentation/providers/providers.dart';
import 'package:prueba/test_breve_estado_animo/presentation/widgets/widgets.dart';
import 'package:prueba/home/presentation/widgets/widgets.dart';
import 'package:prueba/shared/presentation/widgets/mindsave_ui.dart';

class TestBreveEstadoAnimoCreateScreen extends StatelessWidget {
  const TestBreveEstadoAnimoCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      body: _CreateView(),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: 0),
      endDrawer: SideMenu(scaffoldKey: scaffoldKey),
    );
  }
}

class _CreateView extends StatelessWidget {
  const _CreateView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const _TestBreveForm(),
          ),
        ),
      ],
    );
  }
}

class _TestBreveForm extends ConsumerStatefulWidget {
  const _TestBreveForm();

  @override
  ConsumerState<_TestBreveForm> createState() => _TestBreveFormState();
}

class _TestBreveFormState extends ConsumerState<_TestBreveForm> {
  bool _isEditing = false;

  TestBreveEstadoDeAnimo testBreveEstadoDeAnimo = TestBreveEstadoDeAnimo(
    fechaCreacion: DateTime.now(),
    sentimientosAnsiedadEmocionalTestBreve:
        SentimientosAnsiedadEmocionalTestBreve(),
    sentimientosAnsiedadFisicaTestBreve: SentimientosAnsiedadFisicaTestBreve(),
    depresionTestBreve: DepresionTestBreve(),
    impulsoSuicidaTestBreve: ImpulsoSuicidaTestBreve(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(todayTestBreveEstadoDeAnimoProvider.notifier)
          .setTestBreveRealizadoHoy();
      ref
          .read(todayTestBreveEstadoDeAnimoProvider.notifier)
          .scheduleNextMidnightCheck();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(isLoadingProvider);
    if (isLoading) {
      return const MindsaveLoadingView(message: 'Preparando tu test de ánimo…');
    }

    final todayTest = ref.watch(todayTestBreveEstadoDeAnimoProvider);

    if (todayTest != null && !_isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TitleAndInstruction(isCompleted: true),
          const SizedBox(height: 22),
          TestBreveCompletedCard(
            result: todayTest,
            onViewResults: () => context.push('/testBreveEstadoAnimo/1'),
            onEdit: () => _startEditing(todayTest),
            onDelete: () =>
                _mostrarMensajeEliminarTestBreveEstadoDeAnimo(context, ref),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TitleAndInstruction(isEditing: _isEditing),
        const SizedBox(height: 22),
        MindsaveSectionCard(
          child: AnsiedadEmocionalForm(
            testBreveEstadoDeAnimo.sentimientosAnsiedadEmocionalTestBreve,
          ),
        ),
        const SizedBox(height: 12),
        MindsaveSectionCard(
          child: AnsiedadFisicaForm(
            testBreveEstadoDeAnimo.sentimientosAnsiedadFisicaTestBreve,
          ),
        ),
        const SizedBox(height: 12),
        MindsaveSectionCard(
          child: DepresionForm(testBreveEstadoDeAnimo.depresionTestBreve),
        ),
        const SizedBox(height: 12),
        MindsaveSectionCard(
          child: ImpulsoSuicidaForm(
            testBreveEstadoDeAnimo.impulsoSuicidaTestBreve,
          ),
        ),
        const SizedBox(height: 12),
        MindsaveSectionCard(child: NotasForm(testBreveEstadoDeAnimo)),
        const SizedBox(height: 22),

        FilledButton.icon(
          icon: Icon(_isEditing ? Icons.check_rounded : Icons.save_outlined),
          label: Text(_isEditing ? 'Guardar cambios' : 'Guardar evaluación'),
          onPressed: _saveTest,
        ),
        if (_isEditing) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _cancelEditing,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cancelar edición'),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  void _startEditing(TestBreveEstadoDeAnimo todayTest) {
    setState(() {
      testBreveEstadoDeAnimo = TestBreveEstadoDeAnimo.fromJson(
        todayTest.toJson(),
      );
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isEditing = false);
  }

  Future<void> _saveTest() async {
    FocusManager.instance.primaryFocus?.unfocus();
    testBreveEstadoDeAnimo.fechaCreacion = DateTime.now();

    if (_isEditing) {
      try {
        await ref
            .read(testBreveEstadoDeAnimoProvider.notifier)
            .sobrescribirTestBreveEstadoDeAnimoDeHoy(testBreveEstadoDeAnimo);
        ref
            .read(todayTestBreveEstadoDeAnimoProvider.notifier)
            .localSetTestBreveRealizadoHoy(testBreveEstadoDeAnimo);
        if (!mounted) return;
        setState(() => _isEditing = false);
        _showSnackBar(context, 'Cambios guardados correctamente');
      } catch (_) {
        if (mounted) {
          _showSnackBar(
            context,
            'No fue posible guardar los cambios. Inténtalo nuevamente.',
          );
        }
      }
      return;
    }

    final result = await ref
        .read(testBreveEstadoDeAnimoProvider.notifier)
        .guardarTestBreveEstadoDeAnimo(testBreveEstadoDeAnimo);
    if (result != 'OK') {
      if (mounted) {
        _showSnackBar(
          context,
          'Error al intentar guardar el test de estado de ánimo',
        );
      }
      return;
    }
    ref
        .read(todayTestBreveEstadoDeAnimoProvider.notifier)
        .localSetTestBreveRealizadoHoy(testBreveEstadoDeAnimo);
    if (!mounted) return;
    _showSnackBar(context, 'Test Breve de Estado de Ánimo guardado');
    context.push('/testBreveEstadoAnimo/1');
  }
}

class _TitleAndInstruction extends StatelessWidget {
  const _TitleAndInstruction({
    this.isCompleted = false,
    this.isEditing = false,
  });

  final bool isCompleted;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final DateTime hoy = DateTime.now();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MindsavePageIntro(
          eyebrow: isCompleted
              ? 'Evaluación diaria'
              : isEditing
              ? 'Editar evaluación'
              : 'Evaluación diaria · 5 min',
          title: isCompleted
              ? 'Tu evaluación de hoy'
              : isEditing
              ? 'Actualiza tus respuestas'
              : '¿Cómo te has sentido últimamente?',
          description: isCompleted
              ? 'Consulta el resumen, revisa los resultados o modifica tu evaluación.'
              : 'Elige un valor en cada afirmación. Puedes responder con calma y cambiar cualquier selección antes de guardar.',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}',
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
      ],
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
  BuildContext context,
  String message,
) {
  return ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

void _mostrarMensajeEliminarTestBreveEstadoDeAnimo(
  BuildContext context,
  WidgetRef ref,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar Test Breve de Estado de Ánimo'),
      content: const Text(
        '¿Está seguro que desea eliminar el test breve de estado de ánimo?',
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            ref
                .read(todayTestBreveEstadoDeAnimoProvider.notifier)
                .eliminarTestBreveRealizadoHoy();
            context.pop();
            _showSnackBar(context, 'Test Breve de Estado de Ánimo eliminado');
            context.push("/testBreveEstadoAnimo/0");
            await ref
                .read(testBreveEstadoDeAnimoProvider.notifier)
                .eliminarTestBreveEstadoDeAnimoDeHoy();
          },
          child: const Text('Si, eliminar'),
        ),

        TextButton(
          onPressed: () => context.pop(),
          child: const Text('No, cancelar'),
        ),
      ],
    ),
  );
}
