import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/auth/presentation/providers/auth_provider.dart';
import 'package:mindsave/home/presentation/widgets/widgets.dart';
import 'package:mindsave/registro_estado_animo/presentation/providers/providers.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedMood = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final savedMood = await ref
          .read(localStorageServiceProvider)
          .getValue<int>('quickMood');
      if (savedMood != null && mounted) {
        setState(() => _selectedMood = savedMood);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(authProvider).user?.name.trim();
    final firstName = userName == null || userName.isEmpty
        ? ''
        : userName.split(RegExp(r'\s+')).first;
    final hour = DateTime.now().hour;
    final timeGreeting = hour >= 6 && hour < 12
        ? 'Buenos días'
        : hour >= 12 && hour < 20
        ? 'Buenas tardes'
        : 'Buenas noches';
    final greeting = firstName.isEmpty
        ? timeGreeting
        : '$timeGreeting, $firstName';
    final pendingRecords = ref
        .watch(registroEstadoDeAnimoProvider)
        .registros
        .where((record) => record.isPending)
        .length;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      endDrawer: SideMenu(scaffoldKey: _scaffoldKey),
      bottomNavigationBar: const MindsaveBottomNavigation(currentIndex: 0),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatLongDate(DateTime.now()).toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 26),
                  _MoodCard(
                    selectedMood: _selectedMood,
                    onSelected: (value) {
                      setState(() => _selectedMood = value);
                      ref
                          .read(localStorageServiceProvider)
                          .setKeyValue<int>('quickMood', value);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Estado de ánimo registrado'),
                          ),
                        );
                    },
                  ),
                  const SizedBox(height: 30),
                  _PendingRecordsBanner(count: pendingRecords),
                  const SizedBox(height: 26),
                  Text(
                    'Accesos rápidos',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  _QuickAccessTile(
                    icon: Icons.show_chart_rounded,
                    title: 'Seguimiento mensual',
                    subtitle: 'Revisa cómo ha cambiado tu bienestar.',
                    onTap: () => context.push('/testBreveEstadoAnimo/2'),
                  ),
                  const SizedBox(height: 10),
                  _QuickAccessTile(
                    icon: Icons.assignment_outlined,
                    title: 'Test de ánimo',
                    subtitle: 'Evaluación diaria · 5 min.',
                    onTap: () => context.push('/testBreveEstadoAnimo/0'),
                  ),
                  const SizedBox(height: 10),
                  _QuickAccessTile(
                    icon: Icons.history_rounded,
                    title: 'Resultados anteriores',
                    subtitle: 'Consulta el historial de tus evaluaciones.',
                    onTap: () => context.push('/testBreveEstadoAnimo/1'),
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

class _MoodCard extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onSelected;

  const _MoodCard({required this.selectedMood, required this.onSelected});

  static const _moods = [
    ('😞', 'Muy mal'),
    ('😕', 'Mal'),
    ('😐', 'Regular'),
    ('🙂', 'Bien'),
    ('😊', 'Muy bien'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MindsaveSectionCard(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿CÓMO TE SIENTES HOY?',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.15,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(_moods.length, (index) {
              final mood = _moods[index];
              final isSelected = selectedMood == index;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: 'Me siento ${mood.$2}',
                  child: InkWell(
                    onTap: () => onSelected(index),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              mood.$1,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            mood.$2,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PendingRecordsBanner extends StatelessWidget {
  final int count;

  const _PendingRecordsBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPending = count > 0;
    return Material(
      color: theme.colorScheme.primaryContainer.withAlpha(95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.primary.withAlpha(80)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/registros'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  hasPending ? Icons.schedule_rounded : Icons.task_alt_rounded,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasPending
                          ? '$count ${count == 1 ? 'registro pendiente' : 'registros pendientes'}'
                          : 'No tienes registros pendientes',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasPending
                          ? 'Continúa donde lo dejaste'
                          : 'Revisa tus registros completados',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MindsaveSectionCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

String _formatLongDate(DateTime date) {
  const weekdays = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];
  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} · ${date.year}';
}
