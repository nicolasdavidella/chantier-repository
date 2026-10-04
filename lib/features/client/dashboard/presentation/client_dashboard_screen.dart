import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../search_entreprises/presentation/screens/search_entreprises_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'tabs/client_projects_tab.dart';
import '../../../chat/presentation/screens/conversations_list_screen.dart';
import '../../../../data/models/entreprise_model.dart';
import '../../../../data/repositories/entreprise_repository.dart';
import 'package:chantier_track/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/widgets/app_circular_loader.dart';
import 'widgets/app_settings_modal.dart';
import 'widgets/quick_services_modal.dart';

// ─────────────────────────────────────────────
// Providers Firestore
// ─────────────────────────────────────────────
final _nearbyEntreprisesProvider = StreamProvider<List<EntrepriseModel>>((ref) {
  final repo = ref.watch(entrepriseRepositoryProvider);
  return repo.watchAll();
});

final _recommendedEntreprisesProvider = StreamProvider<List<EntrepriseModel>>((ref) {
  final repo = ref.watch(entrepriseRepositoryProvider);
  return repo.watchRecommended(limit: 5);
});

// ─────────────────────────────────────────────
// Main Dashboard Screen
// ─────────────────────────────────────────────
class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends ConsumerState<ClientDashboardScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  List<Widget> get _pages => [
    ClientHomeTab(onTabChange: _changeTab),
    const ClientProjectsTab(),
    const SearchEntreprisesScreen(),
    const ConversationsListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image d'arrière-plan recouvrant toute la surface de l'écran
          Positioned.fill(
            child: Image.asset(
              'assets/images/dashboard_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Voile léger pour faire ressortir l'image tout en garantissant le contraste
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          // Contenu principal
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_currentIndex],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/client/ia_chat'),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
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
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _navItem(0, Icons.home_rounded, isFrench ? "Accueil" : "Home"),
                _navItem(1, Icons.assignment_rounded, isFrench ? "Projets" : "My Task"),
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
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Home Tab — Redesign (inspiré du design moderne)
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
    final userName = user?.nom ?? 'Jenifer';
    final language = ref.watch(languageProvider);
    final isFrench = language == 'fr';

    return Scaffold(
      backgroundColor: Colors.transparent, // Let the background image show through
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.grid_view_rounded, color: AppColors.primary),
          tooltip: isFrench ? 'Services & Raccourcis' : 'Services & Shortcuts',
          onPressed: () {
            showQuickServicesModal(
              context: context,
              isFrench: isFrench,
              onSelectTab: (index) => widget.onTabChange?.call(index),
            );
          },
        ),
        title: Text(
          isFrench ? 'Accueil' : 'Home',
          style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded, color: AppColors.primary),
              tooltip: isFrench ? 'Paramètres' : 'Settings',
              onPressed: () {
                showAppSettingsModal(context);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ──
            Text(
              isFrench ? 'Bonjour $userName !' : 'Hi $userName!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 4),
            Text(
              isFrench ? 'Bienvenue sur votre espace' : 'Welcome to your workspace',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),

            // ── Search Bar ──
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: isFrench ? 'Rechercher un artisan, un service...' : 'Search for a pro, service...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
            const SizedBox(height: 24),

            // ── Project Theme Banner (BTP Theme) ──
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary, // Dark Blue
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 24,
                    top: 24,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isFrench ? 'Votre Nouveau Projet' : 'Your New Project',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isFrench ? 'Construire\navec sérénité' : 'Build\nwith serenity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
            const SizedBox(height: 32),

            // ── Ongoing Projects Title ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isFrench ? 'Actions Rapides' : 'Quick Actions',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),

            // ── Projects Grid ──
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
              children: [
                _FeatureCard(
                  title: isFrench ? 'NICO IA' : 'NICO AI',
                  category: isFrench ? 'Générer plan 3D' : 'Generate 3D plan',
                  icon: Icons.architecture_rounded,
                  isDark: true,
                  onTap: () => _openModule(
                    () => context.push('/client/ia_chat'),
                    name: isFrench ? 'NICO IA' : 'NICO AI',
                  ),
                ),
                _FeatureCard(
                  title: isFrench ? 'Mes Projets' : 'My Projects',
                  category: isFrench ? 'Suivi de chantier' : 'Project tracking',
                  icon: Icons.track_changes_rounded,
                  isDark: false,
                  onTap: () => _openModule(
                    () => widget.onTabChange?.call(1),
                    name: isFrench ? 'Mes Projets' : 'My Projects',
                  ),
                ),
                _FeatureCard(
                  title: isFrench ? 'Recherche' : 'Search',
                  category: isFrench ? 'Trouver un pro' : 'Find a contractor',
                  icon: Icons.search_rounded,
                  isDark: false,
                  onTap: () => _openModule(
                    () => widget.onTabChange?.call(2),
                    name: isFrench ? 'Recherche' : 'Search',
                  ),
                ),
                _FeatureCard(
                  title: isFrench ? 'Réclamations' : 'Claims',
                  category: isFrench ? 'Support client' : 'Customer support',
                  icon: Icons.report_problem_rounded,
                  isDark: false,
                  onTap: () => _openModule(
                    () => context.push('/client/reclamation'),
                    name: isFrench ? 'Réclamations' : 'Claims',
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
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

class _FeatureCard extends StatelessWidget {
  final String title;
  final String category;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.category,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.primary : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.primary;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey.shade500;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.arrow_outward_rounded, color: subtitleColor, size: 20),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              category,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 11,
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimaryLight.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Promo Banner
// ─────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 40, bottom: -30,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Offre exclusive',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Trouvez le bon\nprofessionnel BTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Explorer →',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 44),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Category Chip
// ─────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  const _CategoryChip({required this.label, required this.icon, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 72,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.28)
                : AppColors.textPrimaryLight.withValues(alpha: 0.05),
            blurRadius: selected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: selected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Nearby horizontal card
// ─────────────────────────────────────────────
class _NearbyCard extends StatelessWidget {
  final EntrepriseModel entreprise;
  const _NearbyCard({required this.entreprise});

  @override
  Widget build(BuildContext context) {
    final imageUrl = entreprise.realisations.isNotEmpty ? entreprise.realisations.first : '';
    return Container(
      width: 175,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimaryLight.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _imgPlaceholder(),
                        errorWidget: (context, url, error) => _imgPlaceholder(),
                      )
                    : _imgPlaceholder(),
                // Favourite
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.textPrimaryLight.withValues(alpha: 0.1), blurRadius: 6),
                      ],
                    ),
                    child: const Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.secondary),
                  ),
                ),
                // Zone badge
                if (entreprise.zoneIntervention.isNotEmpty)
                  Positioned(
                    bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            entreprise.zoneIntervention.first,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entreprise.raisonSociale,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  entreprise.zoneIntervention.join(', '),
                  style: TextStyle(fontSize: 11, color: AppColors.grey500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      entreprise.noteMoyenne.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${entreprise.nombreAvis})',
                      style: TextStyle(fontSize: 11, color: AppColors.grey500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    height: 130, width: double.infinity,
    color: const Color(0xFFE6F3F0),
    child: const Center(child: Icon(Icons.business_rounded, color: AppColors.primary, size: 40)),
  );
}

// ─────────────────────────────────────────────
// Recommended list card
// ─────────────────────────────────────────────
class _RecommendedCard extends StatelessWidget {
  final EntrepriseModel entreprise;
  const _RecommendedCard({required this.entreprise});

  @override
  Widget build(BuildContext context) {
    final imageUrl = entreprise.realisations.isNotEmpty ? entreprise.realisations.first : '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimaryLight.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 78, height: 78,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _sqPlaceholder(),
                    errorWidget: (context, url, error) => _sqPlaceholder(),
                  )
                : _sqPlaceholder(),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entreprise.raisonSociale,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      entreprise.noteMoyenne.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13, color: AppColors.grey500),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        entreprise.zoneIntervention.join(', '),
                        style: TextStyle(fontSize: 12, color: AppColors.grey500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoBadge(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: '${entreprise.nombreAvis} avis',
                    ),
                    const SizedBox(width: 8),
                    _InfoBadge(
                      icon: Icons.work_history_outlined,
                      label: '${entreprise.anneesExperience} ans',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sqPlaceholder() => Container(
    width: 78, height: 78,
    color: const Color(0xFFE6F3F0),
    child: const Center(child: Icon(Icons.business_rounded, color: AppColors.primary, size: 36)),
  );
}

// ─────────────────────────────────────────────
// Small badge for recommended card
// ─────────────────────────────────────────────
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight)),
        ],
      ),
    );
  }
}
