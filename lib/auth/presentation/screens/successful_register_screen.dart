import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/auth/presentation/providers/auth_provider.dart';
import 'package:mindsave/auth/presentation/widgets/auth_scaffold.dart';

class SuccessfulRegisterScreen extends ConsumerStatefulWidget {
  final String email;

  const SuccessfulRegisterScreen({super.key, required this.email});

  @override
  ConsumerState<SuccessfulRegisterScreen> createState() =>
      _SuccessfulRegisterScreenState();
}

class _SuccessfulRegisterScreenState
    extends ConsumerState<SuccessfulRegisterScreen> {
  bool _isResending = false;

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resendValidationEmail() async {
    final email = widget.email.trim();
    if (email.isEmpty) {
      _showMessage('No pudimos identificar el correo de la cuenta.');
      return;
    }

    setState(() => _isResending = true);
    final error = await ref
        .read(authProvider.notifier)
        .resendValidationEmail(email);
    if (!mounted) return;

    setState(() => _isResending = false);
    _showMessage(error ?? 'Correo de activación reenviado.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final destination = widget.email.trim();

    return AuthScaffold(
      title: 'Cuenta creada con éxito',
      logoSize: 132,
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          Text('¿No recibiste el correo?', style: theme.textTheme.bodyMedium),
          TextButton(
            onPressed: _isResending ? null : _resendValidationEmail,
            child: Text(_isResending ? 'Reenviando…' : 'Reenviar'),
          ),
        ],
      ),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 30,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Revisa tu bandeja de entrada',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    destination.isEmpty
                        ? 'Hemos enviado un correo de activación al email que nos proporcionaste.'
                        : 'Hemos enviado un correo de activación a $destination.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AuthSubmitButton(
            label: 'Volver al inicio de sesión',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
