import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prueba/config/theme/app_theme.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:prueba/test_breve_estado_animo/domain/repositories/test_breve_estado_de_animo_repository.dart';
import 'package:prueba/test_breve_estado_animo/presentation/providers/providers.dart';
import 'package:prueba/test_breve_estado_animo/presentation/screens/test_breve_estado_animo_daily_results_screen.dart';
import 'package:prueba/test_breve_estado_animo/presentation/screens/test_breve_estado_animo_details_year_results_screen.dart';
import 'package:prueba/test_breve_estado_animo/presentation/services/test_breve_results_exporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('el detalle anual y la ficha diaria se adaptan al Pixel 9', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final testResult = TestBreveEstadoDeAnimo(
      fechaCreacion: DateTime(DateTime.now().year, 8, 14),
      sentimientosAnsiedadEmocionalTestBreve:
          SentimientosAnsiedadEmocionalTestBreve(
            angustiado: 1,
            nervioso: 2,
            preocupado: 1,
          ),
      sentimientosAnsiedadFisicaTestBreve: SentimientosAnsiedadFisicaTestBreve(
        palpitaciones: 1,
      ),
      depresionTestBreve: DepresionTestBreve(tristeza: 1),
      impulsoSuicidaTestBreve: ImpulsoSuicidaTestBreve(),
      notas: 'Dormí mejor y pude pedir apoyo.',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          testBreveEstadoDeAnimoRepositoryProvider.overrideWithValue(
            _FakeTestRepository([testResult]),
          ),
        ],
        child: MaterialApp(
          theme: const AppTheme(isDarkMode: true).getTheme(),
          home: const TestBreveEstadoAnimoDetailsYearResultsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resultados en detalle'), findsOneWidget);
    expect(find.text('Descargar resultados'), findsOneWidget);
    expect(find.byKey(const Key('download-test-results-pdf')), findsOneWidget);
    expect(
      find.byKey(const Key('download-test-results-excel')),
      findsOneWidget,
    );
    expect(find.text('Agosto'), findsOneWidget);
    expect(find.text('Evaluación diaria'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Evaluación diaria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evaluación diaria'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle de la evaluación'), findsOneWidget);
    expect(find.text('Ansiedad emocional'), findsOneWidget);
    expect(find.text('Dormí mejor y pude pedir apoyo.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la vista diaria consulta y muestra el resultado de hoy', (
    tester,
  ) async {
    final testResult = TestBreveEstadoDeAnimo(
      fechaCreacion: DateTime(2026, 8, 25),
      sentimientosAnsiedadEmocionalTestBreve:
          SentimientosAnsiedadEmocionalTestBreve(angustiado: 1),
      sentimientosAnsiedadFisicaTestBreve: SentimientosAnsiedadFisicaTestBreve(
        palpitaciones: 2,
      ),
      depresionTestBreve: DepresionTestBreve(tristeza: 1),
      impulsoSuicidaTestBreve: ImpulsoSuicidaTestBreve(),
      notas: 'Resultado cargado desde la API.',
    );
    final repository = _FakeTestRepository([testResult]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          testBreveEstadoDeAnimoRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
        child: MaterialApp(
          theme: const AppTheme(isDarkMode: false).getTheme(),
          home: const TestBreveEstadoAnimoDailyResultsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.todayRequests, 1);
    expect(find.text('Tus resultados de hoy'), findsOneWidget);
    expect(find.text('Resultado cargado desde la API.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('genera resúmenes simples y válidos en PDF y Excel', () async {
    final testResult = TestBreveEstadoDeAnimo(
      fechaCreacion: DateTime(2026, 8, 14),
      sentimientosAnsiedadEmocionalTestBreve:
          SentimientosAnsiedadEmocionalTestBreve(angustiado: 1, nervioso: 2),
      sentimientosAnsiedadFisicaTestBreve: SentimientosAnsiedadFisicaTestBreve(
        palpitaciones: 2,
      ),
      depresionTestBreve: DepresionTestBreve(tristeza: 1),
      impulsoSuicidaTestBreve: ImpulsoSuicidaTestBreve(),
      notas: 'Apoyo & descanso',
    );

    final pdf = await TestBreveResultsExporter.pdf(
      year: 2026,
      tests: [testResult],
    );
    expect(pdf.fileName, 'mindsave_test_breve_2026.pdf');
    expect(ascii.decode(pdf.bytes.take(4).toList()), '%PDF');
    expect(pdf.bytes.length, greaterThan(500));

    final excel = TestBreveResultsExporter.excel(
      year: 2026,
      tests: [testResult],
    );
    expect(excel.fileName, 'mindsave_test_breve_2026.xlsx');
    expect(excel.bytes.take(2), orderedEquals([0x50, 0x4b]));

    final archive = ZipDecoder().decodeBytes(excel.bytes);
    expect(
      archive.files.map((file) => file.name),
      containsAll([
        '[Content_Types].xml',
        'xl/workbook.xml',
        'xl/worksheets/sheet1.xml',
      ]),
    );
    final worksheet = archive.files.firstWhere(
      (file) => file.name == 'xl/worksheets/sheet1.xml',
    );
    final worksheetXml = utf8.decode(worksheet.readBytes()!);
    expect(worksheetXml, contains('14/08/2026'));
    expect(worksheetXml, contains('Apoyo &amp; descanso'));
  });
}

class _FakeTestRepository implements TestBreveEstadoDeAnimoRepository {
  _FakeTestRepository(this.tests);

  final List<TestBreveEstadoDeAnimo> tests;
  int todayRequests = 0;

  @override
  Future<List<TestBreveEstadoDeAnimo>> getTestBreveEstadoDeAnimoByYear(
    int year,
  ) async => tests.where((test) => test.fechaCreacion.year == year).toList();

  @override
  Future<TestBreveEstadoDeAnimo?> getTodayTestBreveEstadoDeAnimo() async {
    todayRequests++;
    return tests.isEmpty ? null : tests.first;
  }

  @override
  Future<void> saveTestBreveEstadoDeAnimo(
    TestBreveEstadoDeAnimo testBreveEstadoDeAnimo,
  ) async {}

  @override
  Future<void> editarTestBreveEstadoDeAnimoDeHoy(
    TestBreveEstadoDeAnimo testBreveEstadoDeAnimo,
  ) async {}

  @override
  Future<void> eliminarTestBreveEstadoDeAnimoDeHoy() async {}
}
