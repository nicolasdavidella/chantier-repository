import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_spacing.dart';

class SecuritySection extends ConsumerStatefulWidget {
  const SecuritySection({super.key});

  @override
  ConsumerState<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends ConsumerState<SecuritySection> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      if (mounted) {
        setState(() {
          _canCheckBiometrics = canCheck || isDeviceSupported;
        });
      }
    } catch (e) {
      // Ignorer l'erreur silencieusement (souvent le cas sur Desktop)
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      try {
        final didAuthenticate = await auth.authenticate(
          localizedReason: 'Veuillez vous authentifier pour activer cette fonctionnalité',
          options: const AuthenticationOptions(biometricOnly: true),
        );
        if (didAuthenticate) {
          ref.read(biometricProvider.notifier).setBiometric(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec de l\'authentification biométrique')),
          );
        }
      }
    } else {
      ref.read(biometricProvider.notifier).setBiometric(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBiometricEnabled = ref.watch(biometricProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sécurité',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.vLg,
        
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock_outline),
          title: const Text('Changer de mot de passe'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Redirection vers le changement de mot de passe...')),
            );
          },
        ),
        
        const Divider(),
        
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.fingerprint),
          title: const Text('Authentification Biométrique'),
          subtitle: const Text('Exiger l\'empreinte pour ouvrir l\'app', style: TextStyle(fontSize: 12)),
          trailing: Switch(
            value: isBiometricEnabled,
            onChanged: _canCheckBiometrics ? _toggleBiometric : null,
          ),
        ),
      ],
    );
  }
}
