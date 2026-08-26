import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prueba/config/theme/app_theme.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:prueba/test_breve_estado_animo/presentation/widgets/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('el CRUD del test completado sigue el diseño oscuro en Pixel 9', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var viewed = false;
    var edited = false;
    var deleted = false;
    final result = TestBreveEstadoDeAnimo(
      fechaCreacion: DateTime(2026, 8, 18, 9, 14),
      sentimientosAnsiedadEmocionalTestBreve:
          SentimientosAnsiedadEmocionalTestBreve(
            angustiado: 3,
            nervioso: 2,
            preocupado: 2,
            asustado: 2,
            tenso: 2,
          ),
      sentimientosAnsiedadFisicaTestBreve: SentimientosAnsiedadFisicaTestBreve(
        palpitaciones: 2,
        sudoracion: 2,
      ),
      depresionTestBreve: DepresionTestBreve(tristeza: 2),
      impulsoSuicidaTestBreve: ImpulsoSuicidaTestBreve(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: const AppTheme(isDarkMode: true).getTheme(),
        home: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: TestBreveCompletedCard(
                result: result,
                onViewResults: () => viewed = true,
                onEdit: () => edited = true,
                onDelete: () => deleted = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Completado hoy'), findsOneWidget);
    expect(
      find.text('Respondido a las 09:14 · Puntuación: 17 pts'),
      findsOneWidget,
    );
    expect(find.text('RESUMEN DE HOY'), findsOneWidget);
    expect(find.text('11/20'), findsOneWidget);
    expect(find.text('4/40'), findsOneWidget);
    expect(find.text('2/20'), findsOneWidget);
    expect(find.text('0/8'), findsOneWidget);
    expect(find.text('Ver resultados completos'), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('view-completed-test-results')));
    await tester.tap(find.byKey(const Key('edit-completed-test')));
    await tester.tap(find.byKey(const Key('delete-completed-test')));
    expect(viewed, isTrue);
    expect(edited, isTrue);
    expect(deleted, isTrue);
  });
}
