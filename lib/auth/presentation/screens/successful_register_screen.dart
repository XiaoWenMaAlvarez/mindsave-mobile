import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/auth/presentation/widgets/auth_scaffold.dart';

class SuccessfulRegisterScreen extends StatelessWidget {
  const SuccessfulRegisterScreen({super.key});

  void _showResendHelp(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Revisa también la carpeta de spam o correo no deseado.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            onPressed: () => _showResendHelp(context),
            child: const Text('Reenviar'),
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
                    'Hemos enviado un correo de activación al email que nos proporcionaste.',
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
            onPressed: () => context.push('/login'),
          ),
        ],
      ),
    );
  }
}
