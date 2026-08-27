import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsave/auth/presentation/providers/auth_provider.dart';
import 'package:mindsave/home/presentation/widgets/widgets.dart';
import 'package:mindsave/shared/presentation/widgets/mindsave_ui.dart';

class CheckAuthStatusScreen extends ConsumerStatefulWidget {
  const CheckAuthStatusScreen({super.key});

  @override
  ConsumerState<CheckAuthStatusScreen> createState() =>
      _CheckAuthStatusScreenState();
}

class _CheckAuthStatusScreenState extends ConsumerState<CheckAuthStatusScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final hasConnectionError = auth.errorMessage.trim().isNotEmpty;

    if (auth.authStatus == AuthStatus.checking &&
        !hasConnectionError &&
        !_isRetrying) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
        endDrawer: SideMenu(scaffoldKey: _scaffoldKey),
        bottomNavigationBar: const MindsaveBottomNavigation(currentIndex: -1),
        body: const MindsaveLoadingView(message: 'Comprobando sesión…'),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(titleSpacing: 20, title: const CustomAppbar()),
      endDrawer: SideMenu(scaffoldKey: _scaffoldKey),
      bottomNavigationBar: const MindsaveBottomNavigation(currentIndex: -1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minimumHeight = math.max(0.0, constraints.maxHeight - 48);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minimumHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _OfflineContent(
                      isRetrying: _isRetrying,
                      onRetry: _retryConnection,
                      onLogout: () => ref.read(authProvider.notifier).logout(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _retryConnection() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    await ref.read(authProvider.notifier).checkAuthStatus();

    if (mounted) setState(() => _isRetrying = false);
  }
}

class _OfflineContent extends StatelessWidget {
  const _OfflineContent({
    required this.isRetrying,
    required this.onRetry,
    required this.onLogout,
  });

  final bool isRetrying;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      container: true,
      liveRegion: true,
      label:
          'Sin conexión. No pudimos conectar con el servidor. Comprueba tu conexión a internet e inténtalo de nuevo.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(child: _OfflineIllustration()),
          const SizedBox(height: 28),
          Text(
            'Sin conexión',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No pudimos conectar con el servidor. Comprueba tu conexión a internet e inténtalo de nuevo.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('retry-connection-button'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: const StadiumBorder(),
              ),
              onPressed: isRetrying ? null : onRetry,
              icon: isRetrying
                  ? SizedBox.square(
                      dimension: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colors.onPrimary,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  isRetrying ? 'Conectando…' : 'Reintentar conexión',
                  key: ValueKey(isRetrying),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isRetrying ? null : onLogout,
            child: const Text('Iniciar sesión con otra cuenta'),
          ),
        ],
      ),
    );
  }
}

class _OfflineIllustration extends StatelessWidget {
  const _OfflineIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      image: true,
      label: 'Conexión Wi-Fi no disponible',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: 148,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _ConnectionRing(size: 148, color: colors.primary.withAlpha(28)),
              _ConnectionRing(size: 116, color: colors.primary.withAlpha(46)),
              _ConnectionRing(
                size: 84,
                color: colors.primary.withAlpha(68),
                fill: colors.primary.withAlpha(14),
              ),
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary.withAlpha(68)),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 32,
                  color: colors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionRing extends StatelessWidget {
  const _ConnectionRing({required this.size, required this.color, this.fill});

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
