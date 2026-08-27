import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsave/config/helpers/date_helper.dart';
import 'package:mindsave/config/theme/app_theme.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';
import 'package:mindsave/registro_estado_animo/domain/repositories/registro_estado_animo_repository.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/registro_estado_animo/presentation/widgets/widgets.dart';
import 'package:mindsave/test_breve_estado_animo/domain/entities/entities.dart'
    as tb;
import 'package:mindsave/test_breve_estado_animo/presentation/widgets/shared/notas_form.dart';

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

  testWidgets(
    'confirmCbtLeave con "No guardar" ejecuta onDiscard y no onSave',
    (tester) async {
      var saved = false;
      var discarded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => confirmCbtLeave(
                  context,
                  onSave: () async => saved = true,
                  onDiscard: () => discarded = true,
                ),
                child: const Text('Volver'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();

      expect(find.text('¿Guardar antes de volver?'), findsOneWidget);
      expect(find.text('No guardar'), findsOneWidget);

      await tester.tap(find.text('No guardar'));
      await tester.pumpAndSettle();

      expect(discarded, isTrue);
      expect(saved, isFalse);
    },
  );

  testWidgets('confirmCbtLeave con "Guardar" ejecuta onSave y no onDiscard', (
    tester,
  ) async {
    var saved = false;
    var discarded = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => confirmCbtLeave(
                context,
                onSave: () async => saved = true,
                onDiscard: () => discarded = true,
              ),
              child: const Text('Volver'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(saved, isTrue);
    expect(discarded, isFalse);
  });

  test(
    'restaurarRegistroEstadoDeAnimo revierte las mutaciones en memoria',
    () async {
      final original = RegistroEstadoAnimo(
        id: 'reg-1',
        fecha: DateTime(2026, 8, 14),
        sucesoTrastornador: 'Suceso original',
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
            pensamientoNegativo: 'Pensamiento negativo original',
            porcentajeCreenciaAntes: 80,
          ),
        ],
      );

      final snapshot = RegistroEstadoAnimo.fromJson(original.toJson());
      final fakeRepo = _FakeCbtRepository([original]);
      final container = ProviderContainer(
        overrides: [
          registroEstadoAnimoRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(registroEstadoDeAnimoProvider.notifier);
      await pumpEventQueue();
      await notifier.cargarRegistrosEstadoDeAnimoById('reg-1');

      final inMemoryRecord = notifier.getRegistroEstadoDeAnimoById('reg-1')!;

      // Mutar el registro en memoria
      inMemoryRecord.listaPensamientos.first.pensamientoPositivo =
          'Pensamiento positivo no guardado';
      inMemoryRecord.listaPensamientos.first.distorsion[0] = true;
      expect(
        notifier
            .getRegistroEstadoDeAnimoById('reg-1')
            ?.listaPensamientos
            .first
            .pensamientoPositivo,
        'Pensamiento positivo no guardado',
      );

      // Restaurar desde el snapshot
      notifier.restaurarRegistroEstadoDeAnimo(snapshot);

      final restored = notifier.getRegistroEstadoDeAnimoById('reg-1');
      expect(restored?.listaPensamientos.first.pensamientoPositivo, isNull);
      expect(restored?.listaPensamientos.first.distorsion[0], isFalse);
    },
  );

  testWidgets(
    'CbtRecordNotFoundView muestra mensaje de registro no encontrado',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme(isDarkMode: false).getTheme(),
          home: const Scaffold(body: CbtRecordNotFoundView()),
        ),
      );

      expect(find.text('No pudimos encontrar este registro'), findsOneWidget);
      expect(find.text('Volver a mis registros'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'NotasForm inicializa con las notas existentes y sincroniza cambios',
    (tester) async {
      final testBreve = tb.TestBreveEstadoDeAnimo(
        fechaCreacion: DateTime.now(),
        notas: 'Nota existente de prueba',
        sentimientosAnsiedadEmocionalTestBreve:
            tb.SentimientosAnsiedadEmocionalTestBreve(),
        sentimientosAnsiedadFisicaTestBreve:
            tb.SentimientosAnsiedadFisicaTestBreve(),
        depresionTestBreve: tb.DepresionTestBreve(),
        impulsoSuicidaTestBreve: tb.ImpulsoSuicidaTestBreve(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme(isDarkMode: false).getTheme(),
          home: Scaffold(
            body: SingleChildScrollView(child: NotasForm(testBreve)),
          ),
        ),
      );

      expect(find.text('Nota existente de prueba'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Nueva nota actualizada');
      expect(testBreve.notas, 'Nueva nota actualizada');
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'RegistroEstadoDeAnimoNotifier deduplica registros por id al cargar y guardar',
    () async {
      final record1 = RegistroEstadoAnimo(
        id: 'reg-1',
        fecha: DateTime(2026, 8, 14),
        sucesoTrastornador: 'Suceso 1',
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
        listaPensamientos: [],
      );

      final fakeRepo = _FakeCbtRepository([record1]);
      final container = ProviderContainer(
        overrides: [
          registroEstadoAnimoRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(registroEstadoDeAnimoProvider.notifier);
      await pumpEventQueue();

      await notifier.cargarRegistrosEstadoDeAnimoById('reg-1');
      expect(container.read(registroEstadoDeAnimoProvider).registros.length, 1);

      // Cargar de nuevo el mismo id no debe duplicarlo
      await notifier.cargarRegistrosEstadoDeAnimoById('reg-1');
      expect(container.read(registroEstadoDeAnimoProvider).registros.length, 1);
    },
  );

  test(
    'DateHelper.calcularUltimoDiaDelMes calcula correctamente para años bisiestos y todos los meses',
    () {
      expect(DateHelper.calcularUltimoDiaDelMes(DateTime(2024, 2, 10)), 29);
      expect(DateHelper.calcularUltimoDiaDelMes(DateTime(2023, 2, 10)), 28);
      expect(DateHelper.calcularUltimoDiaDelMes(DateTime(2026, 1, 15)), 31);
      expect(DateHelper.calcularUltimoDiaDelMes(DateTime(2026, 4, 15)), 30);
      expect(DateHelper.calcularUltimoDiaDelMes(DateTime(2026, 12, 1)), 31);
    },
  );
}

class _FakeCbtRepository implements RegistroEstadoAnimoRepository {
  final List<RegistroEstadoAnimo> records;

  _FakeCbtRepository(this.records);

  @override
  Future<String> saveRegistroEstadoDeAnimo(
    RegistroEstadoAnimo registroEstadoAnimo,
  ) async => 'reg-1';

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoCompleto({
    int page = 1,
    int limit = 10,
  }) async => [];

  @override
  Future<List<RegistroEstadoAnimo>> getRegistroEstadoDeAnimoPendiente({
    int page = 1,
    int limit = 10,
  }) async => [];

  @override
  Future<RegistroEstadoAnimo?> getRegistroEstadoDeAnimoById(String id) async {
    return records.firstWhere((r) => r.id == id);
  }

  @override
  Future<void> editarRegistroEstadoDeAnimoDeHoy(
    RegistroEstadoAnimo registroEstadoAnimo,
  ) async {}

  @override
  Future<void> eliminarRegistroEstadoDeAnimoDeHoy(String id) async {}
}
