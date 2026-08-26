import 'package:flutter/material.dart';
import 'package:prueba/registro_estado_animo/presentation/screens/registros_screen.dart';

class RegistroEstadoAnimoPendingViewScreen extends StatelessWidget {
  const RegistroEstadoAnimoPendingViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegistrosScreen(initialTab: RecordsTab.pending);
  }
}
