import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
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
        var profileState = await ref.read(currentUserProfileProvider.future);
        
        int retries = 3;
        while (profileState == null && retries > 0) {
          await Future.delayed(const Duration(milliseconds: 1500));
          ref.invalidate(currentUserProfileProvider);
          profileState = await ref.read(currentUserProfileProvider.future);
          retries--;
        }

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
          context.go('/login');
        }
      } else {
        context.go('/login');
      }
    } catch (e) {
      debugPrint('Erreur lors du routing Splash: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion à la base de données.')),
        );
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Architecture Image (keeping intact as requested)
          Image.network(
            'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=1080&auto=format&fit=crop',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.secondary,
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          // Glassmorphic Content Container with Spinning Logo
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.apartment_rounded,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .rotate(duration: 2000.ms, curve: Curves.linear),
                      const SizedBox(height: 24),
                      const Text(
                        'CHANTIER TRACK',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryLight,
                          letterSpacing: 1.5,
                        ),
                      ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutCubic).fadeIn(),
                      const SizedBox(height: 8),
                      const Text(
                        'Chargement en cours...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
