import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../search_entreprises/presentation/screens/search_entreprises_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'tabs/client_projects_tab.dart';
import '../../../chat/presentation/screens/conversations_list_screen.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/widgets/app_circular_loader.dart';
import 'widgets/app_settings_modal.dart';
import 'widgets/quick_services_modal.dart';

class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends ConsumerState<ClientDashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ClientHomeTab(onTabChange: (index) {
        setState(() => _currentIndex = index);
      }),
      const ClientProjectsTab(),
      const SearchEntreprisesScreen(),
      const ConversationsListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFAF8F5), // Fond beige doux architectural
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Lueurs d'ambiance vert forêt & menthe
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
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
            bottom: 60,
            left: -60,
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

          // Contenu de la page sélectionnée
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _pages[_currentIndex],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/client/ia_chat'),
        backgroundColor: const Color(0xFF143D2B),
        elevation: 6,
        shape: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF143D2B), Color(0xFF10B981)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.architecture_rounded, color: Colors.white, size: 26),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final language = ref.watch(languageProvider);
    final isFrench = language == 'fr';

    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 20,
      shadowColor: const Color(0xFF143D2B).withValues(alpha: 0.12),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _navItem(0, Icons.home_rounded, isFrench ? "Accueil" : "Home"),
                _navItem(1, Icons.assignment_rounded, isFrench ? "Projets" : "Projects"),
              ],
            ),
            Row(
              children: [
                _navItem(3, Icons.chat_bubble_outline_rounded, isFrench ? "Chat" : "Chat"),
                _navItem(4, Icons.person_outline_rounded, isFrench ? "Profil" : "Profile"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return MaterialButton(
      minWidth: 70,
      onPressed: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF143D2B) : const Color(0xFF94A3B8),
            size: 23,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF143D2B) : const Color(0xFF94A3B8),
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Home Tab — Redesign NextGen Construction
// ─────────────────────────────────────────────
class ClientHomeTab extends ConsumerStatefulWidget {
  final void Function(int)? onTabChange;
  const ClientHomeTab({super.key, this.onTabChange});

  @override
  ConsumerState<ClientHomeTab> createState() => _ClientHomeTabState();
}

class _ClientHomeTabState extends ConsumerState<ClientHomeTab> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider).value;
    final userName = user?.nom ?? 'Client';
    final language = ref.watch(languageProvider);
    final isFrench = language == 'fr';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.grid_view_rounded, color: Color(0xFF143D2B)),
          tooltip: isFrench ? 'Services & Raccourcis' : 'Services & Shortcuts',
          onPressed: () {
            showQuickServicesModal(
              context: context,
              isFrench: isFrench,
              onSelectTab: (index) => widget.onTabChange?.call(index),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.architecture_rounded,
                  color: Color(0xFF143D2B),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ChantierTrack',
              style: TextStyle(
                color: Color(0xFF143D2B),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded, color: Color(0xFF143D2B)),
              tooltip: isFrench ? 'Paramètres' : 'Settings',
              onPressed: () => showAppSettingsModal(context),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).copyWith(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting Header (Flexible with no overflow) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFrench ? 'Bonjour $userName !' : 'Hi $userName!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 2),
                      Text(
                        isFrench
                            ? 'Bienvenue sur votre espace ChantierTrack'
                            : 'Welcome to your construction workspace',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF81C784).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
                      SizedBox(width: 4),
                      Text(
                        '100% Qualité',
                        style: TextStyle(
                          color: Color(0xFF143D2B),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Hero Banner NextGen (Inspiré de l'image de référence) ──
            _buildNextGenHeroCard(context, isFrench),

            const SizedBox(height: 26),

            // ── Section Actions Rapides / Modules ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isFrench ? 'Modules & Outils' : 'Modules & Tools',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  isFrench ? 'Accès rapide' : 'Quick access',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: 14),

            // ── Grille des 4 Modules ──
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
              children: [
                _NextGenModuleCard(
                  title: isFrench ? 'Studio 3D' : '3D Studio',
                  subtitle: isFrench ? 'Plans 3D & Devis' : '3D Plans & Estimates',
                  icon: Icons.architecture_rounded,
                  badgeText: 'Conception',
                  isHighlighted: true,
                  onTap: () => _openModule(
                    () => context.push('/client/ia_chat'),
                    name: isFrench ? 'Studio 3D' : '3D Studio',
                  ),
                ),
                _NextGenModuleCard(
                  title: isFrench ? 'Mes Projets' : 'My Projects',
                  subtitle: isFrench ? 'Suivi & Planning' : 'Tracking & Planning',
                  icon: Icons.assignment_rounded,
                  badgeText: 'Chantiers',
                  isHighlighted: false,
                  onTap: () => _openModule(
                    () => widget.onTabChange?.call(1),
                    name: isFrench ? 'Mes Projets' : 'My Projects',
                  ),
                ),
                _NextGenModuleCard(
                  title: isFrench ? 'Trouver un Pro' : 'Find a Pro',
                  subtitle: isFrench ? 'Entreprises certifiées' : 'Certified Contractors',
                  icon: Icons.search_rounded,
                  badgeText: 'Artisans',
                  isHighlighted: false,
                  onTap: () => _openModule(
                    () => widget.onTabChange?.call(2),
                    name: isFrench ? 'Trouver un Pro' : 'Find a Pro',
                  ),
                ),
                _NextGenModuleCard(
                  title: isFrench ? 'Réclamations' : 'Claims',
                  subtitle: isFrench ? 'Médiation & Support' : 'Support & Assistance',
                  icon: Icons.shield_outlined,
                  badgeText: 'Garantie',
                  isHighlighted: false,
                  onTap: () => _openModule(
                    () => context.push('/client/reclamation'),
                    name: isFrench ? 'Réclamations' : 'Claims',
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 24),

            // ── Footer Info Contact & Qualité (Pill Bar comme sur l'affiche) ──
            _buildNextGenFooterPill(isFrench),
          ],
        ),
      ),
    );
  }

  Widget _buildNextGenHeroCard(BuildContext context, bool isFrench) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF143D2B), // Deep Forest Green
            Color(0xFF1B5E3B), // Emerald Forest
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF34D399).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D2B).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Décoration d'ondes en arrière-plan
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag supérieur NextGen (sécurisé contre les overflows)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF86EFAC).withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Building Excellence',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFDCFCE7),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sceau 100% Quality Gold & Green
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAB308).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFDE047),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: Color(0xFFFDE047), size: 12),
                          SizedBox(width: 3),
                          Text(
                            '100% QUALITÉ',
                            style: TextStyle(
                              color: Color(0xFFFEF08A),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Grand titre
                Text(
                  isFrench ? 'Concevez vos Projets\nde Rêves' : 'Designing Unique\nStructures',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 14),

                // Liste de nos services (comme sur l'image)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildServiceItem(
                        Icons.home_work_outlined,
                        isFrench ? 'Plans 3D Sur-Mesure & Devis' : 'Custom Home Builds & 3D Plans',
                      ),
                      const SizedBox(height: 6),
                      _buildServiceItem(
                        Icons.view_in_ar_rounded,
                        isFrench ? 'Modélisation 3D Architecturale' : '3D Design & Visualization',
                      ),
                      const SizedBox(height: 6),
                      _buildServiceItem(
                        Icons.engineering_outlined,
                        isFrench ? 'Suivi de Chantier & Entreprises' : 'Project Management & Contractors',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bouton d'action
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => _openModule(
                      () => context.push('/client/ia_chat'),
                      name: isFrench ? 'Studio 3D' : '3D Studio',
                    ),
                    icon: const Icon(Icons.architecture_rounded, color: Color(0xFF143D2B), size: 18),
                    label: Text(
                      isFrench ? 'Démarrer la conception' : 'Start Designing',
                      style: const TextStyle(
                        color: Color(0xFF143D2B),
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF86EFAC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.06);
  }

  Widget _buildServiceItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextGenFooterPill(bool isFrench) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC8E6C9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D2B).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF10B981), size: 16),
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assistance 24/7',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '+237 600 000 000',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Certifié ChantierTrack',
              style: TextStyle(
                color: Color(0xFF15803D),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 550.ms);
  }

  void _openModule(VoidCallback action, {String? name}) {
    showAppLoadingDialog(
      context,
      message: name != null ? 'Ouverture de $name...' : 'Chargement...',
    );
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) {
        hideAppLoadingDialog(context);
        action();
      }
    });
  }
}

class _NextGenModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String badgeText;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _NextGenModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badgeText,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted ? const Color(0xFF10B981) : const Color(0xFFC8E6C9),
            width: isHighlighted ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : const Color(0xFF143D2B).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isHighlighted ? const Color(0xFF10B981) : const Color(0xFF143D2B),
                    size: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: isHighlighted ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                height: 1.25,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
