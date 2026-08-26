import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsave/config/theme/app_theme.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

void main() {
  testWidgets('la pantalla de carga reproduce el diseño en tamaño Pixel 9', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: const AppTheme(isDarkMode: true).getTheme(),
        home: const Scaffold(
          body: MindsaveLoadingView(message: 'Cargando tus datos…'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('MIND SAVE'), findsOneWidget);
    expect(find.text('Cargando tus datos…'), findsOneWidget);
    expect(
      find.byKey(const Key('mindsave-loading-illustration')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('mindsave-loading-shimmer')), findsOneWidget);
    expect(
      find.byKey(const Key('mindsave-loading-logo-pulse')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('mindsave-loading-accent-line')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Cargando tus datos…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la variante compacta respeta animaciones reducidas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: const AppTheme().getTheme(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: SizedBox(
              height: 300,
              child: MindsaveLoadingView(compact: true),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Cargando…'), findsOneWidget);
    expect(find.byKey(const Key('mindsave-loading-shimmer')), findsOneWidget);
    expect(
      find.byKey(const Key('mindsave-loading-logo-pulse')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
