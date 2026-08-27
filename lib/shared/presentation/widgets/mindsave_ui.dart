import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MindsaveLoadingView extends StatelessWidget {
  const MindsaveLoadingView({
    super.key,
    this.message = 'Cargando…',
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final illustrationSize = compact ? 132.0 : 260.0;
    final logoSize = compact ? 52.0 : 82.0;

    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: compact ? 18 : 36,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        key: const Key('mindsave-loading-illustration'),
                        dimension: illustrationSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _LoadingRing(
                              size: illustrationSize,
                              color: colors.primary.withAlpha(16),
                            ),
                            _LoadingRing(
                              size: illustrationSize * .7,
                              color: colors.primary.withAlpha(28),
                            ),
                            _LoadingRing(
                              size: illustrationSize * .44,
                              color: colors.primary.withAlpha(42),
                              fill: colors.primary.withAlpha(7),
                            ),
                            _MindsavePulsingLogo(size: logoSize),
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 12),
                      Text(
                        'MIND SAVE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: compact ? 2.1 : 3.0,
                        ),
                      ),
                      SizedBox(height: compact ? 9 : 12),
                      const _LoadingAccentLine(),
                      SizedBox(height: compact ? 14 : 18),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          letterSpacing: .2,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: compact ? 18 : 28),
                      MindsaveLoadingBar(width: compact ? 138 : 162),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MindsaveLoadingBar extends StatelessWidget {
  const MindsaveLoadingBar({
    super.key,
    this.width = 162,
    this.semanticsLabel = 'Cargando',
  });

  final double width;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(child: _MindsaveShimmerBar(width: width)),
    );
  }
}

class _LoadingRing extends StatelessWidget {
  const _LoadingRing({required this.size, required this.color, this.fill});

  final double size;
  final Color color;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
    );
  }
}

class _MindsavePulsingLogo extends StatefulWidget {
  const _MindsavePulsingLogo({required this.size});

  final double size;

  @override
  State<_MindsavePulsingLogo> createState() => _MindsavePulsingLogoState();
}

class _MindsavePulsingLogoState extends State<_MindsavePulsingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  bool _animationsDisabled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scale = Tween<double>(begin: .96, end: 1.04).animate(curved);
    _opacity = Tween<double>(begin: .78, end: 1).animate(curved);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_animationsDisabled == animationsDisabled &&
        (_controller.isAnimating || animationsDisabled)) {
      return;
    }

    _animationsDisabled = animationsDisabled;
    if (animationsDisabled) {
      _controller
        ..stop()
        ..value = .5;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: const Key('mindsave-loading-logo-pulse'),
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: Image.asset(
            'assets/img/icon.png',
            width: widget.size,
            height: widget.size,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _LoadingAccentLine extends StatelessWidget {
  const _LoadingAccentLine();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      key: const Key('mindsave-loading-accent-line'),
      width: 48,
      height: 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: LinearGradient(colors: [primary, const Color(0xFF00CACB)]),
        boxShadow: [BoxShadow(color: primary.withAlpha(90), blurRadius: 8)],
      ),
    );
  }
}

class _MindsaveShimmerBar extends StatefulWidget {
  const _MindsaveShimmerBar({required this.width});

  final double width;

  @override
  State<_MindsaveShimmerBar> createState() => _MindsaveShimmerBarState();
}

class _MindsaveShimmerBarState extends State<_MindsaveShimmerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animationsDisabled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_animationsDisabled == animationsDisabled &&
        (_controller.isAnimating || animationsDisabled)) {
      return;
    }

    _animationsDisabled = animationsDisabled;
    if (animationsDisabled) {
      _controller
        ..stop()
        ..value = .5;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return RepaintBoundary(
      child: SizedBox(
        key: const Key('mindsave-loading-shimmer'),
        width: widget.width,
        height: 12,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final glowWidth = constraints.maxWidth * .5;
            final segment = Container(
              width: glowWidth,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: LinearGradient(
                  colors: [primary, const Color(0xFF00CACB)],
                ),
                boxShadow: [
                  BoxShadow(color: primary.withAlpha(165), blurRadius: 8),
                ],
              ),
            );

            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: constraints.maxWidth,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withAlpha(100),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                if (_animationsDisabled)
                  Align(child: segment)
                else
                  AnimatedBuilder(
                    animation: _controller,
                    child: segment,
                    builder: (context, child) {
                      final left =
                          (constraints.maxWidth + glowWidth) *
                              Curves.easeInOut.transform(_controller.value) -
                          glowWidth;
                      return Positioned(left: left, child: child!);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MindsaveBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const MindsaveBottomNavigation({super.key, required this.currentIndex});

  static const _paths = <String>[
    '/home',
    '/registros',
    '/testBreveEstadoAnimo/2',
    '/testBreveEstadoAnimo/0',
  ];

  static const _destinations =
      <({IconData icon, IconData selected, String label})>[
        (
          icon: Icons.home_outlined,
          selected: Icons.home_rounded,
          label: 'Inicio',
        ),
        (
          icon: Icons.view_list_outlined,
          selected: Icons.view_list_rounded,
          label: 'Registros',
        ),
        (
          icon: Icons.show_chart_rounded,
          selected: Icons.insights_rounded,
          label: 'Seguimiento',
        ),
        (
          icon: Icons.assignment_outlined,
          selected: Icons.assignment_rounded,
          label: 'Test',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 84,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                top: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    border: Border(
                      top: BorderSide(
                        color: colors.outlineVariant.withAlpha(120),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      for (var index = 0; index < 2; index++)
                        Expanded(
                          child: _MindsaveNavigationItem(
                            destination: _destinations[index],
                            selected: currentIndex == index,
                            onTap: () => _goTo(context, index),
                          ),
                        ),
                      const SizedBox(width: 74),
                      for (var index = 2; index < _destinations.length; index++)
                        Expanded(
                          child: _MindsaveNavigationItem(
                            destination: _destinations[index],
                            selected: currentIndex == index,
                            onTap: () => _goTo(context, index),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'Crear un nuevo registro CBT',
                child: Tooltip(
                  message: 'Nuevo registro CBT',
                  child: Material(
                    color: colors.primary,
                    elevation: 7,
                    shadowColor: colors.shadow.withAlpha(100),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.push('/registroEstadoAnimo/0'),
                      child: SizedBox.square(
                        dimension: 62,
                        child: Icon(
                          Icons.add_rounded,
                          size: 32,
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goTo(BuildContext context, int index) {
    if (index != currentIndex) context.go(_paths[index]);
  }
}

class _MindsaveNavigationItem extends StatelessWidget {
  final ({IconData icon, IconData selected, String label}) destination;
  final bool selected;
  final VoidCallback onTap;

  const _MindsaveNavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 13, 2, 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? destination.selected : destination.icon,
                color: color,
                size: 23,
              ),
              const SizedBox(height: 3),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 18 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MindsaveSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  const MindsaveSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: card,
    );
  }
}

class MindsavePageIntro extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? description;

  const MindsavePageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: theme.textTheme.headlineMedium),
        if (description != null) ...[
          const SizedBox(height: 10),
          Text(
            description!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class MindsaveModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? meta;
  final VoidCallback onTap;
  final Color? accent;

  const MindsaveModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.meta,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.primary;
    return MindsaveSectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withAlpha(28),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (meta != null) ...[
                  const SizedBox(height: 7),
                  Text(
                    meta!,
                    style: theme.textTheme.labelMedium?.copyWith(color: color),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, color: color),
        ],
      ),
    );
  }
}

class MindsaveStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String description;

  const MindsaveStepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Paso $currentStep de $totalSteps',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const Spacer(),
            Text(
              '${(currentStep / totalSteps * 100).round()}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            minHeight: 7,
          ),
        ),
        const SizedBox(height: 24),
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
