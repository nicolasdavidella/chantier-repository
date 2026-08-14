import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // SplashScreen or global router handles redirect
      if (mounted) context.go('/');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Content de vous revoir !',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vXxl,
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    AppSpacing.vLg,
                  ],
                  AppTextField(
                    controller: _emailController,
                    label: 'Adresse e-mail',
                    hintText: 'exemple@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Veuillez entrer votre e-mail';
                      if (!value.contains('@')) return 'E-mail invalide';
                      return null;
                    },
                  ),
                  AppSpacing.vLg,
                  AppTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) => value!.isEmpty ? 'Veuillez entrer votre mot de passe' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot_password'),
                      child: const Text('Mot de passe oublié ?'),
                    ),
                  ),
                  AppSpacing.vXl,
                  AppButton(
                    onPressed: _login,
                    text: 'Se connecter',
                    isLoading: _isLoading,
                  ),
                  AppSpacing.vXxl,
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Text(
                          'OU',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  AppSpacing.vXxl,
                  AppButton(
                    onPressed: () => context.push('/phone_auth'),
                    text: 'Connexion par téléphone',
                    isSecondary: true,
                    isOutlined: true,
                    icon: Icons.phone_android,
                  ),
                  AppSpacing.vXxl,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pas encore de compte ?'),
                      TextButton(
                        onPressed: () => context.push('/role_selection'),
                        child: const Text('S\'inscrire'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
