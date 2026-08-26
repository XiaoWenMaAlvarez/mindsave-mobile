import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindsave/auth/presentation/providers/auth_provider.dart';
import 'package:mindsave/auth/presentation/widgets/auth_scaffold.dart';

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

String? _validarPassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El campo es obligatorio';
  }
  if (value.trim().length < 6) {
    return 'Se requieren al menos 6 caracteres';
  }
  return null;
}

String? _validarNombre(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El campo es obligatorio';
  }
  if (value.trim().length < 2) {
    return 'Se requieren al menos 2 caracteres';
  }
  return null;
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _repeatPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _emailFocusNode.dispose();
    _nameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _repeatPasswordFocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateRepeatedPassword(String? value) {
    final passwordError = _validarPassword(value);
    if (passwordError != null) return passwordError;
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final result = await ref
        .read(authProvider.notifier)
        .registerUser(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
    if (!mounted) return;

    setState(() => _isLoading = false);
    if (result != null) {
      final errorMessage = result.trim();
      _showSnackBar(
        errorMessage.isNotEmpty ? errorMessage : 'Error al crear cuenta',
      );
      return;
    }
    context.push('/successful-register');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Crear cuenta',
      logoSize: 104,
      compact: true,
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          Text(
            '¿Ya tienes cuenta?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextButton(
            onPressed: () => context.push('/login'),
            child: const Text('Inicia sesión'),
          ),
        ],
      ),
      child: AutofillGroup(
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
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _validarEmail,
                onFieldSubmitted: (_) => _nameFocusNode.requestFocus(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                autofillHints: const [AutofillHints.name],
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _validarNombre,
                onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                autofillHints: const [AutofillHints.newPassword],
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: _validarPassword,
                onFieldSubmitted: (_) =>
                    _repeatPasswordFocusNode.requestFocus(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _repeatPasswordController,
                focusNode: _repeatPasswordFocusNode,
                autofillHints: const [AutofillHints.newPassword],
                obscureText: _obscureRepeatPassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Repita la contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _obscureRepeatPassword
                        ? 'Mostrar contraseña repetida'
                        : 'Ocultar contraseña repetida',
                    onPressed: () => setState(
                      () => _obscureRepeatPassword = !_obscureRepeatPassword,
                    ),
                    icon: Icon(
                      _obscureRepeatPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: _validateRepeatedPassword,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 22),
              AuthSubmitButton(
                label: 'Crear cuenta',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
