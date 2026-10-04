import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../providers/entreprise_dashboard_providers.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../../chat/presentation/screens/conversations_list_screen.dart';
import 'mes_chantiers_screen.dart';
import 'equipe_screen.dart';
import 'documents_reports_screen.dart';
import 'entreprise_profil_screen.dart';
import '../../../devis/presentation/screens/devis_screen.dart';
import '../../../offres/presentation/screens/offres_screen.dart';

class EntrepriseDashboardScreen extends ConsumerStatefulWidget {
  const EntrepriseDashboardScreen({super.key});

  @override
  ConsumerState<EntrepriseDashboardScreen> createState() =>
      _EntrepriseDashboardScreenState();
}

class _EntrepriseDashboardScreenState
    extends ConsumerState<EntrepriseDashboardScreen> {
  int _currentIndex = 0;

  // Pages corresponding to bottom nav items
  List<Widget> get _pages => [
    const _DashboardHomeTab(),
    const OffresScreen(),
    MesChantierScreen(key: UniqueKey()), // Force rebuild to bypass cached Red Screen
    const ConversationsListScreen(),
    const EntrepriseProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final offresAsync = ref.watch(appelsOffresStreamProvider);
    final newOffresCount = offresAsync.value?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2822),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Accueil'),
              _navItem(1, Icons.assignment_rounded, 'Offres', badge: newOffresCount),
              _navItem(2, Icons.construction_rounded, 'Chantiers'),
              _navItem(3, Icons.chat_bubble_rounded, 'Messages'),
              _navItem(4, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, {int badge = 0}) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.secondary : Colors.white54,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        color: selected ? AppColors.secondary : Colors.white54,
                        fontSize: 10,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
            if (badge > 0)
              Positioned(
                top: -6,
                right: -8,
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: Center(
                    child: Text('$badge',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 600.ms),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────
class _DashboardHomeTab extends ConsumerWidget {
  const _DashboardHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entrepriseAsync = ref.watch(currentEntrepriseStreamProvider);
    final chantierAsync = ref.watch(mesChantierStreamProvider);
    final offresAsync = ref.watch(appelsOffresStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, ref, entrepriseAsync.value),
              const SizedBox(height: 20),

              // Certification Banner
              if (entrepriseAsync.value == null)
                const Text('Profil entreprise introuvable', style: TextStyle(color: Colors.red)),
              if (entrepriseAsync.value == null || !entrepriseAsync.value!.isVerified) ...[
                _buildCertificationBanner(context, entrepriseAsync.value?.id ?? ''),
                const SizedBox(height: 20),
              ],

              // Stats row
              _buildStatsRow(context, chantierAsync.value ?? [], offresAsync.value ?? []),
              const SizedBox(height: 24),

              // Quick actions
              const Text('Actions rapides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight)),
              const SizedBox(height: 14),
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // New offres banner
              _buildOffresBanner(context, offresAsync.value?.length ?? 0),
              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, entreprise) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: const Icon(Icons.business_rounded, size: 26, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entreprise?.raisonSociale ?? 'Espace Entreprise',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Tableau de bord',
                  style: TextStyle(fontSize: 12, color: AppColors.grey500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 8)],
              ),
              child: const Icon(Icons.notifications_none_rounded, size: 20, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/login');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.errorLight, shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildCertificationBanner(BuildContext context, String entrepriseId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8),
              Text(
                'Entreprise non certifiée',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pour obtenir plus de clients et rassurer sur votre expertise, veuillez soumettre vos documents de certification (RCCM, Carte contribuable, etc.).',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/entreprise_certification', extra: entrepriseId),
              icon: const Icon(Icons.verified_rounded),
              label: const Text('Faire certifier mon entreprise'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: -0.1).fadeIn();
  }

  Widget _buildStatsRow(BuildContext context, List projects, List offres) {
    final enCours = projects.where((p) => p.statut == 'en_cours').length;
    final termines = projects.where((p) => p.statut == 'termine').length;
    return Row(
      children: [
        Expanded(child: _StatCard(
          label: 'En cours', 
          value: '$enCours', 
          icon: Icons.construction_rounded, 
          color: AppColors.secondary,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MesChantierScreen(initialFilter: 'en_cours'))),
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          label: 'Terminés', 
          value: '$termines', 
          icon: Icons.check_circle_rounded, 
          color: AppColors.success,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MesChantierScreen(initialFilter: 'termine'))),
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          label: 'Nouvelles offres', 
          value: '${offres.length}', 
          icon: Icons.assignment_rounded, 
          color: AppColors.warning,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OffresScreen())),
        )),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'name': 'Mes\nChantiers', 'icon': Icons.construction_rounded, 'screen': const MesChantierScreen()},
      {'name': 'Devis', 'icon': Icons.request_quote_rounded, 'screen': const DevisScreen()},
      {'name': 'Équipe', 'icon': Icons.group_rounded, 'screen': const EquipeScreen()},
      {'name': 'Rapports', 'icon': Icons.bar_chart_rounded, 'screen': const RapportsScreen()},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.asMap().entries.map((entry) {
        final act = entry.value;
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => act['screen'] as Widget)),
          child: Column(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 10)],
                ),
                child: Icon(act['icon'] as IconData, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                act['name'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
              ),
            ],
          ).animate().fadeIn(delay: Duration(milliseconds: 50 * entry.key)).slideY(begin: 0.1),
        );
      }).toList(),
    );
  }

  Widget _buildOffresBanner(BuildContext context, int count) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OffresScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('$count nouveau${count > 1 ? 'x' : ''}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(height: 8),
                  const Text('Appels d\'offres\n& Annonces',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, height: 1.2)),
                  const SizedBox(height: 6),
                  const Text('Découvrez les projets disponibles',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Text('Voir les annonces', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.secondary),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.assignment_rounded, size: 60, color: Colors.white24),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
          ],
        ),
      ),
    );
  }
}

class _MiniChantierCard extends StatelessWidget {
  final project;
  const _MiniChantierCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final ville = project.localisation['ville'] ?? '';
    Color statusColor = project.statut == 'en_cours' ? AppColors.secondary :
                        project.statut == 'termine' ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.construction_rounded, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.titre,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                    overflow: TextOverflow.ellipsis),
                Text(ville, style: const TextStyle(fontSize: 12, color: AppColors.grey500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(project.statut.replaceAll('_', ' '),
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
