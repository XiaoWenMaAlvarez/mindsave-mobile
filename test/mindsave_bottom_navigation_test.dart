import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

  testWidgets('los destinos reemplazan la ruta en vez de apilar pantallas', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(
            body: Text('Inicio'),
            bottomNavigationBar: MindsaveBottomNavigation(currentIndex: 0),
          ),
        ),
        GoRoute(
          path: '/registros',
          builder: (context, state) => const Scaffold(body: Text('Registros')),
        ),
        GoRoute(
          path: '/testBreveEstadoAnimo/2',
          builder: (context, state) =>
              const Scaffold(body: Text('Seguimiento')),
        ),
        GoRoute(
          path: '/testBreveEstadoAnimo/0',
          builder: (context, state) => const Scaffold(body: Text('Test')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Registros'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/registros');
    expect(router.canPop(), isFalse);
  });
}
