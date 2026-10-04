import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chantier_track/core/widgets/app_circular_loader.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
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
          await Future.delayed(const Duration(milliseconds: 1000));
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
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtils halos d'ambiance vert forêt & émeraude
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8F5E9).withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDCFCE7).withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Contenu central avec Logo rotatif circulaire
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.84,
              padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFC8E6C9),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B4D3E).withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Officiel ChantierTrack avec rotation circulaire fluide
                  const AppCircularLoader(
                    size: 96,
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'CHANTIER TRACK',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B4D3E),
                      letterSpacing: 1.5,
                    ),
                  ).animate().slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic).fadeIn(),

                  const SizedBox(height: 6),

                  const Text(
                    'Gérez • Suivez • Construisez',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1.3, 1.3),
                            duration: 800.ms,
                          ),
                      const SizedBox(width: 8),
                      const Text(
                        'Chargement de l\'espace...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
