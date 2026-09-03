import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_spacing.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final String imageUrl;
  final String? imageAsset;
  final String badgeText;
  final IconData? badgeIcon;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.imageAsset,
    required this.badgeText,
    this.badgeIcon,
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
      imageUrl: "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=1000&auto=format&fit=crop", // Modern villa
      badgeText: "Avancement : 68%",
    ),
    OnboardingPageData(
      title: "Une transparence totale sur vos dépenses",
      description: "Contrôlez votre budget en temps réel avec un suivi clair de toutes vos factures et dépenses.",
      imageUrl: "https://images.unsplash.com/photo-1503387762-592deb58ef4e?q=80&w=1000&auto=format&fit=crop", // Architecture
      badgeText: "2 450 000 FCFA suivis",
    ),
    OnboardingPageData(
      title: "L'intelligence artificielle veille sur votre projet",
      description: "Notre IA détecte les risques de retards et les dépassements de budget avant qu'ils n'arrivent.",
      imageUrl: "", // fallback
      imageAsset: "assets/images/onboarding/ai_tracking.png",
      badgeText: "Alerte détectée",
      badgeIcon: Icons.security_rounded,
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
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finishOnboarding() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Gris très clair premium
      body: Stack(
        children: [
          // 1. PageView for the swiping content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          
          // 2. Top UI overlay (Back button & Skip)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Circular back button
                AnimatedOpacity(
                  opacity: _currentPage > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: _currentPage == 0,
                    child: GestureDetector(
                      onTap: _previousPage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ),
                ),
                
                // Skip Button
                if (!isLastPage)
                  TextButton(
                    onPressed: _finishOnboarding,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: const Color(0xFF1A1A1A),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text(
                      "Passer",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ).animate().fadeIn(duration: 300.ms)
                else
                  const SizedBox(width: 60), // keep balance
              ],
            ),
          ),
          
          // 3. Bottom UI (Pagination & Button)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24, 
                right: 24, 
                top: 24, 
                bottom: MediaQuery.of(context).padding.bottom + 24
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF5F5F7).withOpacity(0.0),
                    const Color(0xFFF5F5F7),
                    const Color(0xFFF5F5F7),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Button
                  _buildNextButton(isLastPage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    return Column(
      children: [
        // Top Image Section (approx 60%)
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              // Main Image
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: page.imageAsset != null 
                    ? Image.asset(
                        page.imageAsset!,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        page.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(color: Color(0xFFD85A30)),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 50),
                            ),
                          );
                        },
                      ),
                ),
              ),
              
              // Floating Badge Overlay
              Positioned(
                bottom: 24,
                left: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD85A30), // Orange Terracotta
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD85A30).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (page.badgeIcon != null) ...[
                        Icon(page.badgeIcon, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        page.badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ).animate(key: ValueKey(page.title + "_badge"))
                 .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), delay: 300.ms, duration: 500.ms, curve: Curves.elasticOut)
                 .fadeIn(delay: 300.ms, duration: 300.ms),
              ),
            ],
          ),
        ),
        
        // Bottom Content Section (approx 40%)
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  page.description,
                  style: const TextStyle(
                    color: Color(0xFF8A8A8E), // gris moyen
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ).animate(key: ValueKey(page.title + "_text"))
             .fadeIn(duration: 400.ms)
             .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 32 : 8, // wide pill
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD85A30) : const Color(0xFFD1D1D6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildNextButton(bool isLastPage) {
    return GestureDetector(
      onTap: _nextPage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), // Anthracite très sombre
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A1A).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isLastPage ? "Commencer" : "Suivant",
              key: ValueKey(isLastPage),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
