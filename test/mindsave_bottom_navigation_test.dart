import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

void main() {
  testWidgets('la barra compacta muestra cuatro destinos y el FAB CBT', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const Scaffold(
          body: SizedBox.expand(),
          bottomNavigationBar: MindsaveBottomNavigation(currentIndex: 0),
        ),
      ),
    );

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Registros'), findsOneWidget);
    expect(find.text('Seguimiento'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
