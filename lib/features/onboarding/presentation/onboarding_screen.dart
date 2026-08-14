import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final String lottieUrl;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.lottieUrl,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: "Suivez votre chantier où que vous soyez",
      description: "Restez connecté à l'avancement de vos projets immobiliers 24/7, directement depuis votre smartphone.",
      lottieUrl: "https://lottie.host/2464ebdf-d0cc-4045-8c01-7baeeeb5822e/O2nN2fP83v.json", // Placeholder d'illustration
    ),
    OnboardingPageData(
      title: "Une transparence totale sur vos dépenses",
      description: "Contrôlez votre budget en temps réel avec un suivi clair de toutes vos factures et dépenses.",
      lottieUrl: "https://lottie.host/79c9462c-8067-4bd9-ba9d-0925e01f6534/8iA0U68QvU.json", // Placeholder d'illustration
    ),
    OnboardingPageData(
      title: "L'intelligence artificielle veille sur votre projet",
      description: "Notre IA détecte les risques de retards et les dépassements de budget avant qu'ils n'arrivent.",
      lottieUrl: "https://lottie.host/5239dfb3-ebfe-4822-ba34-4bcbf63e6f9f/7Q5m2hC54C.json", // Placeholder d'illustration
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    // Redirection vers le login ou le showcase
    context.go('/showcase');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Bouton "Passer" (Skip)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isLastPage)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        "Passer",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms)
                  else
                    const SizedBox(height: 48), // Maintient l'espace quand le bouton disparait
                ],
              ),
            ),
            
            // PageView pour les écrans
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  // Animation Fade + Slide à l'intérieur de la page (flutter_animate le gère automatiquement si la clé change)
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Footer (Points de pagination + Bouton)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicateurs animés (Dots qui s'étirent)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index, theme),
                    ),
                  ),
                  AppSpacing.vXxl,
                  // Bouton avec morphing du texte via AnimatedSwitcher
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation.drive(Tween(begin: 0.95, end: 1.0)),
                            child: child,
                          ),
                        );
                      },
                      child: AppButton(
                        key: ValueKey<bool>(isLastPage),
                        onPressed: _nextPage,
                        text: isLastPage ? "Commencer" : "Suivant",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Lottie.network(
              page.lottieUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icône si le lien Lottie échoue (pas d'internet, etc.)
                return Icon(
                  Icons.image_outlined,
                  size: 120,
                  color: theme.colorScheme.outline.withOpacity(0.5),
                );
              },
            ),
          ),
          AppSpacing.vLg,
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Text(
                  page.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.vLg,
                Text(
                  page.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ).animate(key: ValueKey(page.title)) // Ajoute une animation unique à chaque page
       .fadeIn(duration: 400.ms, curve: Curves.easeOut)
       .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildDot(int index, ThemeData theme) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
