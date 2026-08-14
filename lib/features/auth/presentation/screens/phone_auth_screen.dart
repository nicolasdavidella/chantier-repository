import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/firebase_errors.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController(text: '+237');
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  String? _verificationId;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone == '+237') return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) context.go('/');
        } catch (e) {
          if (mounted) setState(() => _errorMessage = FirebaseErrors.getMessage(e.toString()));
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = FirebaseErrors.getMessage(e.code);
          });
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6 || _verificationId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      // Let the router handle redirection
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = FirebaseErrors.getMessage(e.code);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOtpMode = _verificationId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isOtpMode ? 'Vérification' : 'Connexion Téléphone')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isOtpMode ? 'Entrez le code' : 'Votre numéro',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              AppSpacing.vSm,
              Text(
                isOtpMode 
                  ? 'Un code à 6 chiffres a été envoyé au ${_phoneController.text}'
                  : 'Nous vous enverrons un code par SMS pour confirmer votre numéro.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
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
              
              if (!isOtpMode) ...[
                AppTextField(
                  controller: _phoneController,
                  label: 'Numéro de téléphone',
                  hintText: '+237 6XX XX XX XX',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                AppSpacing.vXxl,
                AppButton(
                  onPressed: _verifyPhone,
                  text: 'Envoyer le code',
                  isLoading: _isLoading,
                ),
              ] else ...[
                AppTextField(
                  controller: _otpController,
                  label: 'Code de vérification',
                  hintText: '123456',
                  keyboardType: TextInputType.number,
                ),
                AppSpacing.vXxl,
                AppButton(
                  onPressed: _verifyOTP,
                  text: 'Vérifier',
                  isLoading: _isLoading,
                ),
                AppSpacing.vLg,
                TextButton(
                  onPressed: () {
                    setState(() {
                      _verificationId = null;
                      _otpController.clear();
                    });
                  },
                  child: const Text('Modifier le numéro de téléphone'),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
