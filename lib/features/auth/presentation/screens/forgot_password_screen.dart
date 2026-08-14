import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/auth_repository.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      if (mounted) setState(() => _success = true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _success
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: theme.colorScheme.primary),
                    AppSpacing.vLg,
                    Text(
                      'Email envoyé',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.vSm,
                    Text(
                      'Veuillez vérifier votre boîte de réception pour réinitialiser votre mot de passe.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Entrez l\'adresse e-mail associée à votre compte.',
                      style: theme.textTheme.bodyLarge,
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
                        ),
                      ),
                      AppSpacing.vLg,
                    ],
                    AppTextField(
                      controller: _emailController,
                      label: 'Adresse e-mail',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    AppSpacing.vXxl,
                    AppButton(
                      onPressed: _resetPassword,
                      text: 'Réinitialiser',
                      isLoading: _isLoading,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
