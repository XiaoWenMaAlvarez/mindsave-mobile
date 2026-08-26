import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba/auth/presentation/providers/auth_provider.dart';
import 'package:prueba/auth/presentation/widgets/auth_scaffold.dart';

String? _validarEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El campo es obligatorio';
  }
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegExp.hasMatch(value.trim())) {
    return 'No tiene formato de correo electrónico';
  }
  return null;
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final result = await ref
        .read(authProvider.notifier)
        .resetPassword(_emailController.text.trim());
    if (!mounted) return;

    setState(() => _isLoading = false);
    if (result != null) {
      final errorMessage = result.trim();
      _showSnackBar(
        errorMessage.isNotEmpty
            ? errorMessage
            : 'Error al intentar recuperar contraseña',
      );
      return;
    }
    _showSnackBar(
      'Enviamos las instrucciones de recuperación al correo proporcionado.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Restablecer contraseña',
      subtitle:
          'Ingresa tu correo y te enviaremos las instrucciones para recuperar el acceso.',
      footer: TextButton.icon(
        onPressed: () => context.push('/login'),
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text('Volver al login'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: _validarEmail,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            AuthSubmitButton(
              label: 'Recuperar contraseña',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
