import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prueba/config/theme/app_theme.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';
import 'package:prueba/registro_estado_animo/presentation/widgets/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('el encabezado CBT muestra los seis pasos en un Pixel 9', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme(isDarkMode: true).getTheme(),
        home: const Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: CbtStepHeader(
                currentStep: 4,
                title: 'Distorsiones cognitivas',
                description: 'Identifica las distorsiones de cada pensamiento.',
              ),
            ),
          ),
        ),
      ),
    );

    for (final label in cbtStepLabels) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Distorsiones cognitivas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la tarjeta de reestructuración se adapta al ancho móvil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final thought = Pensamiento(
      pensamientoNegativo: 'Voy a equivocarme y todo saldrá mal',
      porcentajeCreenciaAntes: 80,
    )..distorsion[0] = true;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme(isDarkMode: false).getTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: CustomFormPensamientoPositivo(
              title: 'Pensamiento 1',
              pensamiento: thought,
              formKey: GlobalKey<FormState>(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('PENSAMIENTO NEGATIVO'), findsOneWidget);
    expect(find.text('PENSAMIENTO ALTERNATIVO POSITIVO'), findsOneWidget);
    expect(find.text('Pensamiento todo o nada'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la revisión emocional muestra antes, después y progreso', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final emotions = GrupoEmociones3(
      seleccionEmociones: [true, true, false, false],
      porcentajeCreenciaAntes: 70,
      porcentajeCreenciaDespues: 30,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme(isDarkMode: true).getTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CbtStepHeader(
                  currentStep: 6,
                  title: 'Revisión emocional',
                  description: 'Re-evalúa la intensidad después del ejercicio.',
                ),
                CustomGrupoEmocionesReevaluacion(
                  title: 'Culpa',
                  emoji: '😔',
                  grupoEmociones: emotions,
                  formKey: GlobalKey<FormState>(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Culpable · Con remordimiento'), findsOneWidget);
    expect(find.text('Redujo 40% · Buen progreso'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'las emociones personalizadas usan el selector de intensidad de 0 a 100',
    (tester) async {
      final emotions = GrupoEmocionesPersonalizadas(
        listaEmociones: ['Abrumado/a'],
        seleccionEmociones: [true],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme(isDarkMode: false).getTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Form(
                child: EmocionesPersonalizadasCheckBoxGroup(
                  grupoEmociones: emotions,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Otras (describir)'));
      await tester.pumpAndSettle();

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 0);
      expect(slider.max, 100);
      expect(slider.divisions, 20);
      expect(find.text('Intensidad inicial'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('el paso 3 usa la jerarquía visual del flujo CBT', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final record = RegistroEstadoAnimo(
      id: '',
      fecha: DateTime(2026, 8, 14),
      sucesoTrastornador: 'Una conversación difícil',
      grupoEmociones1: GrupoEmociones1(),
      grupoEmociones2: GrupoEmociones2(),
      grupoEmociones3: GrupoEmociones3(),
      grupoEmociones4: GrupoEmociones4(),
      grupoEmociones5: GrupoEmociones5(),
      grupoEmociones6: GrupoEmociones6(),
      grupoEmociones7: GrupoEmociones7(),
      grupoEmociones8: GrupoEmociones8(),
      grupoEmociones9: GrupoEmociones9(),
      grupoEmocionesPersonalizadas: GrupoEmocionesPersonalizadas(),
      listaPensamientos: [
        Pensamiento(
          pensamientoNegativo: 'Seguro que todo saldrá mal',
          porcentajeCreenciaAntes: 75,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme(isDarkMode: false).getTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: RegistroEstadoAnimoPaso3(record, GlobalKey<FormState>()),
          ),
        ),
      ),
    );

    expect(find.text('Pensamientos automáticos'), findsOneWidget);
    expect(find.text('Escríbelo tal como apareció'), findsOneWidget);
    expect(find.text('¿Cuánto creíste en cada pensamiento?'), findsOneWidget);
    expect(find.byIcon(Icons.psychology_alt_outlined), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('los porcentajes CBT respetan sus rangos', () {
    expect(validarPorcentajePensamientoNegativo('0'), isNull);
    expect(validarPorcentajePensamientoNegativo('101'), isNotNull);
    expect(validarPorcentajePensamientoPositivo('1'), isNull);
    expect(validarPorcentajePensamientoPositivo('0'), isNotNull);
    expect(validarPorcentajeEmocion('100'), isNull);
    expect(validarPorcentajeEmocion(''), isNotNull);
  });
}
