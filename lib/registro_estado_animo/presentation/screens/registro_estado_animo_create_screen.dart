import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/home/presentation/widgets/widgets.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/registro_estado_animo/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

class RegistroEstadoAnimoCreateScreen extends ConsumerStatefulWidget {
  const RegistroEstadoAnimoCreateScreen({super.key});

  @override
  ConsumerState<RegistroEstadoAnimoCreateScreen> createState() =>
      _RegistroEstadoAnimoCreateScreenState();
}

class _RegistroEstadoAnimoCreateScreenState
    extends ConsumerState<RegistroEstadoAnimoCreateScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());
  int _currentStep = 0;

  static const _stepTitles = [
    '¿Qué ocurrió?',
    'Ponle nombre a lo que sentiste',
    'Observa tus pensamientos',
  ];

  static const _stepDescriptions = [
    'Describe brevemente la situación que alteró tu ánimo. No necesitas escribir todos los detalles.',
    'Selecciona las emociones que aparecieron y estima su intensidad en ese momento.',
    'Anota las ideas automáticas que surgieron y cuánto creíste en cada una.',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(nuevoRegistroEstadoDeAnimoProvider.notifier)
          .crearNuevoRegistroEstadoAnimo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registroEstadoDeAnimoProvider);
    final registro = ref.watch(nuevoRegistroEstadoDeAnimoProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      endDrawer: SideMenu(scaffoldKey: _scaffoldKey),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
      body: state.isLoading
          ? const MindsaveLoadingView(message: 'Preparando tu registro…')
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CbtStepHeader(
                          currentStep: _currentStep + 1,
                          title: _stepTitles[_currentStep],
                          description: _stepDescriptions[_currentStep],
                        ),
                        const SizedBox(height: 22),
                        MindsaveSectionCard(
                          padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: KeyedSubtree(
                              key: ValueKey(_currentStep),
                              child: _buildCurrentStep(registro),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      setState(() => _currentStep--),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  label: const Text('Anterior'),
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: state.isLoading
                                    ? null
                                    : () => _continue(registro),
                                icon: Icon(
                                  _currentStep == 2
                                      ? Icons.check_rounded
                                      : Icons.arrow_forward_rounded,
                                ),
                                label: Text(
                                  _currentStep == 2
                                      ? 'Guardar y continuar'
                                      : 'Continuar',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            _currentStep == 2
                                ? 'Después identificarás distorsiones y crearás una alternativa.'
                                : 'Tus cambios se conservan al avanzar entre pasos.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentStep(RegistroEstadoAnimo registro) {
    return switch (_currentStep) {
      0 => RegistroEstadoAnimoPaso1(registro, _formKeys[0]),
      1 => RegistroEstadoAnimoPaso2(registro, _formKeys[1]),
      _ => RegistroEstadoAnimoPaso3(registro, _formKeys[2]),
    };
  }

  Future<void> _continue(RegistroEstadoAnimo registro) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isCurrentStepValid = _formKeys[_currentStep].currentState?.validate();
    if (isCurrentStepValid != true) {
      _showSnackBar(context, 'Revisa los campos señalados antes de continuar.');
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }

    final validationMessage = registro.isValid;
    if (validationMessage != null) {
      _showSnackBar(context, validationMessage);
      return;
    }

    await ref
        .read(nuevoRegistroEstadoDeAnimoProvider.notifier)
        .guardarRegistroEstadoDeAnimo();
    if (!mounted) return;
    _showSnackBar(
      context,
      'Registro guardado. Continúa con las distorsiones cognitivas.',
    );
    context.push('/registroEstadoAnimo/3/${registro.id}');
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  return ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
