import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/home/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final theme = Theme.of(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      endDrawer: SideMenu(scaffoldKey: scaffoldKey),
      bottomNavigationBar: const MindsaveBottomNavigation(currentIndex: -1),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MindsavePageIntro(
                    eyebrow: 'Tu espacio',
                    title: 'Módulos',
                    description:
                        'Elige una herramienta según lo que necesites en este momento.',
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(
                        avatar: Icon(Icons.check_rounded, size: 18),
                        label: Text('Todos'),
                      ),
                      Chip(label: Text('Evaluación')),
                      Chip(label: Text('Reflexión')),
                      Chip(label: Text('Apoyo')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  MindsaveModuleCard(
                    icon: Icons.fact_check_outlined,
                    title: 'Test breve de ánimo',
                    subtitle:
                        'Evalúa ansiedad, ánimo y bienestar con preguntas guiadas.',
                    meta: 'Diario · 5 min',
                    onTap: () => context.push('/testBreveEstadoAnimo/0'),
                  ),
                  const SizedBox(height: 12),
                  MindsaveModuleCard(
                    icon: Icons.psychology_alt_outlined,
                    title: 'Registro de pensamientos',
                    subtitle:
                        'Comprende una situación difícil y crea una mirada más equilibrada.',
                    meta: 'CBT · 6 pasos',
                    onTap: () => context.push('/registroEstadoAnimo/0'),
                    accent: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 12),
                  MindsaveModuleCard(
                    icon: Icons.forum_outlined,
                    title: 'Externalización de voces',
                    subtitle:
                        'Conversa en un espacio guiado para tomar distancia de tus pensamientos.',
                    meta: 'Conversación asistida',
                    onTap: () => context.push('/externalizacionVoces/0'),
                    accent: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(height: 12),
                  MindsaveModuleCard(
                    icon: Icons.auto_graph_outlined,
                    title: 'Tu seguimiento',
                    subtitle:
                        'Revisa tendencias y reconoce los cambios de tu bienestar.',
                    meta: 'Resultados y gráficos',
                    onTap: () => context.push('/testBreveEstadoAnimo/2'),
                    accent: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 28),
                  MindsaveSectionCard(
                    color: theme.colorScheme.primaryContainer.withAlpha(95),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.favorite_outline_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No necesitas completar todo. Una práctica breve y constante puede ser más útil que intentar hacerlo perfecto.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
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
}
