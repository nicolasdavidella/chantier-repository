import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/auth_repository.dart';
import '../../data/user_repository.dart';
import '../../../../data/models/user_model.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final String role;
  const SignupScreen({super.key, required this.role});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+237');
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    
    setState(() {
      _passwordStrength = strength;
    });
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordStrength < 0.5) {
      setState(() => _errorMessage = 'Le mot de passe est trop faible.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await ref.read(authRepositoryProvider).signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          email: _emailController.text.trim(),
          telephone: _phoneController.text.trim(),
          role: widget.role,
          dateCreation: DateTime.now(),
        );

        await ref.read(userRepositoryProvider).createUser(userModel);

        if (widget.role == 'entreprise') {
          if (mounted) context.go('/entreprise_details', extra: user.uid);
        } else {
          if (mounted) context.go('/');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStrengthColor() {
    if (_passwordStrength <= 0.25) return Colors.red;
    if (_passwordStrength <= 0.5) return Colors.orange;
    if (_passwordStrength <= 0.75) return Colors.lightGreen;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _prenomController,
                        label: 'Prénom',
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                    ),
                    AppSpacing.hLg,
                    Expanded(
                      child: AppTextField(
                        controller: _nomController,
                        label: 'Nom',
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vLg,
                AppTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !v!.contains('@') ? 'Invalide' : null,
                ),
                AppSpacing.vLg,
                AppTextField(
                  controller: _phoneController,
                  label: 'Téléphone',
                  keyboardType: TextInputType.phone,
                ),
                AppSpacing.vLg,
                AppTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                AppSpacing.vSm,
                // Indicateur de force du mot de passe
                Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: 300.ms,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _passwordStrength > 0 ? _getStrengthColor() : theme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: AnimatedContainer(
                        duration: 300.ms,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _passwordStrength > 0.25 ? _getStrengthColor() : theme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: AnimatedContainer(
                        duration: 300.ms,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _passwordStrength > 0.5 ? _getStrengthColor() : theme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: AnimatedContainer(
                        duration: 300.ms,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _passwordStrength > 0.75 ? _getStrengthColor() : theme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vXs,
                Text(
                  '8 caractères min, 1 majuscule, 1 chiffre, 1 caractère spécial.',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                ),
                AppSpacing.vXxl,
                AppButton(
                  onPressed: _signup,
                  text: 'Créer mon compte',
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
