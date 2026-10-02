import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // Uses global theme primary color instead of hardcoded terracotta

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsetsGeometry? padding, double borderRadius = 16, double opacity = 0.75}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        children: [
          _buildScreen1(),
          _buildScreen2(),
          _buildScreen3(),
        ],
      ),
    );
  }

  Widget _buildScreen1() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        Align(
          alignment: Alignment.topCenter,
          child: Image.network(
            'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&q=80&w=1080',
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        
        // Bottom White Card
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.45,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenue sur\nChantierTrack',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 16),
                
                Text(
                  'La plateforme intelligente de gestion de chantier pour suivre vos projets de A à Z en toute simplicité.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withValues(alpha: 0.5),
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1),
                
                const Spacer(),
                
                // Bottom Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pagination Dots
                    Row(
                      children: [
                        _buildDot(true),
                        _buildDot(false),
                        _buildDot(false),
                      ],
                    ),
                    
                    // Next Button
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text('Suivant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ).animate().slideY(begin: 1.0, duration: 500.ms, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }

  Widget _buildScreen2() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image (Different angle/house)
        Image.asset(
          'assets/images/onboarding2.jpg',
          fit: BoxFit.cover,
        ),
        
        // Back Button
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 16),
              child: GestureDetector(
                onTap: () => _pageController.previousPage(duration: 300.ms, curve: Curves.ease),
                child: _buildGlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 24,
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
                ),
              ).animate().fadeIn(),
            ),
          ),
        ),
        
        // Bottom White Card
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.45,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suivez votre chantier\noù que vous soyez',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 16),
                
                Text(
                  'Gardez le contrôle sur l\'avancement de vos projets avec une vue claire et détaillée en temps réel.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withValues(alpha: 0.5),
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1),
                
                const Spacer(),
                
                // Bottom Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pagination Dots
                    Row(
                      children: [
                        _buildDot(false),
                        _buildDot(true),
                        _buildDot(false),
                      ],
                    ),
                    
                    // Next Button
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text('Suivant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ).animate().slideY(begin: 1.0, duration: 500.ms, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }

  Widget _buildScreen3() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // AI Image Background (matching the design requested)
        Align(
          alignment: Alignment.topCenter,
          child: Image.asset(
            'assets/images/ia_hologram.png',
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        
        // Back Button
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 16),
              child: GestureDetector(
                onTap: () => _pageController.previousPage(duration: 300.ms, curve: Curves.ease),
                child: _buildGlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 24,
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
                ),
              ).animate().fadeIn(),
            ),
          ),
        ),
        
        // Bottom White Card
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.45,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anticipez avec\nl\'Intelligence Artificielle',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 16),
                
                Text(
                  'Recevez des alertes intelligentes et des prévisions pour éviter les retards et les dépassements.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withValues(alpha: 0.5),
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1),
                
                const Spacer(),
                
                // Bottom Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pagination Dots
                    Row(
                      children: [
                        _buildDot(false),
                        _buildDot(false),
                        _buildDot(true),
                      ],
                    ),
                    
                    // Next / Start Button
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text('Commencer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ).animate().slideY(begin: 1.0, duration: 500.ms, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
