import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening and dispatching after a short delay for the animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _dispatch();
      }
    });
  }

  Future<void> _dispatch() async {
    try {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final profileState = await ref.read(currentUserProfileProvider.future);
        if (!mounted) return;
        
        if (profileState != null) {
          switch (profileState.role) {
            case 'admin':
              context.go('/admin');
              break;
            case 'chef_chantier':
              context.go('/chef_chantier');
              break;
            case 'entreprise':
              context.go('/entreprise');
              break;
            case 'client':
            default:
              context.go('/client');
              break;
          }
        } else {
          // No profile found
          context.go('/onboarding');
        }
      } else {
        context.go('/onboarding');
      }
    } catch (e) {
      debugPrint('Erreur lors du routing Splash: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion à la base de données. Avez-vous créé Firestore ?')),
        );
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.network(
          'https://lottie.host/8b725055-6677-44da-b371-bd6b90875c75/Z1hW6r60PZ.json', // Placeholder ChantierTrack logo/loader
          width: 200,
          height: 200,
          errorBuilder: (context, error, stackTrace) => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
