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
      backgroundColor: const Color(0xFFFAF8F5),
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
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF143D2B),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFC8E6C9).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D2B).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Expanded(child: _navItem(0, Icons.home_rounded, 'Accueil')),
              Expanded(child: _navItem(1, Icons.assignment_rounded, 'Offres', badge: newOffresCount)),
              Expanded(child: _navItem(2, Icons.construction_rounded, 'Chantiers')),
              Expanded(child: _navItem(3, Icons.chat_bubble_rounded, 'Messages')),
              Expanded(child: _navItem(4, Icons.person_rounded, 'Profil')),
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF10B981).withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? const Color(0xFF86EFAC) : Colors.white60,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? const Color(0xFF86EFAC) : Colors.white60,
                    fontSize: 9.5,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (badge > 0)
              Positioned(
                top: -4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(color: Color(0xFFEAB308), shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: const TextStyle(color: Color(0xFF143D2B), fontSize: 9, fontWeight: FontWeight.w900),
                    ),
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
      backgroundColor: const Color(0xFFFAF8F5),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8F5E9).withValues(alpha: 0.8),
                    const Color(0xFFE8F5E9).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDCFCE7).withValues(alpha: 0.6),
                    const Color(0xFFDCFCE7).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NextGen Header
                  _buildHeader(context, ref, entrepriseAsync.value),
                  const SizedBox(height: 16),

                  // Tagline Pill (Responsive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.workspace_premium_rounded, size: 16, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Building Excellence',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF143D2B),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 16),

                  // Certification Banner - Only displayed if company is not certified
                  if (entrepriseAsync.value != null &&
                      !entrepriseAsync.value!.isVerified &&
                      entrepriseAsync.value!.verificationStatus != 'APPROVED') ...[
                    _buildCertificationBanner(context, entrepriseAsync.value!.id),
                    const SizedBox(height: 16),
                  ],

                  // Stats row
                  _buildStatsRow(context, chantierAsync.value ?? [], offresAsync.value ?? []),
                  const SizedBox(height: 22),

                  // Quick actions
                  const Text(
                    'SERVICES & ACTIONS',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF143D2B), letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                  const SizedBox(height: 22),

                  // New offres banner
                  _buildOffresBanner(context, offresAsync.value?.length ?? 0),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, entreprise) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
                ),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF143D2B),
                  child: Icon(Icons.business_rounded, size: 22, color: Color(0xFF86EFAC)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entreprise?.raisonSociale ?? 'Espace Entreprise',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF143D2B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Tableau de bord Pro',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF143D2B).withValues(alpha: 0.05), blurRadius: 6),
                ],
              ),
              child: const Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF143D2B)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/login');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                ),
                child: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFDC2626)),
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
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified_user_outlined, color: Color(0xFFD97706), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Obtenir le badge 100% QUALITÉ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF92400E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Faites certifier vos documents pour débloquer plus de chantiers et rassurer vos clients.',
            style: TextStyle(fontSize: 12, color: Color(0xFFB45309), height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/entreprise_certification', extra: entrepriseId),
              icon: const Icon(Icons.verified_rounded, size: 18),
              label: const Text('Soumettre mes documents', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF143D2B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
          color: const Color(0xFF10B981),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MesChantierScreen(initialFilter: 'en_cours'))),
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          label: 'Terminés', 
          value: '$termines', 
          icon: Icons.check_circle_rounded, 
          color: const Color(0xFF143D2B),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MesChantierScreen(initialFilter: 'termine'))),
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          label: 'Offres', 
          value: '${offres.length}', 
          icon: Icons.assignment_rounded, 
          color: const Color(0xFFD97706),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OffresScreen())),
        )),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'name': 'Chantiers', 'icon': Icons.construction_rounded, 'screen': const MesChantierScreen()},
      {'name': 'Devis', 'icon': Icons.request_quote_rounded, 'screen': const DevisScreen()},
      {'name': 'Équipe', 'icon': Icons.group_rounded, 'screen': const EquipeScreen()},
      {'name': 'Rapports', 'icon': Icons.bar_chart_rounded, 'screen': const RapportsScreen()},
    ];

    return Row(
      children: actions.asMap().entries.map((entry) {
        final act = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: entry.key == 0 ? 0 : 4,
              right: entry.key == actions.length - 1 ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => act['screen'] as Widget)),
              child: Column(
                children: [
                  Container(
                    height: 64,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF143D2B).withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(act['icon'] as IconData, color: const Color(0xFF143D2B), size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    act['name'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF143D2B)),
                  ),
                ],
              ).animate().fadeIn(delay: Duration(milliseconds: 50 * entry.key)).slideY(begin: 0.1),
            ),
          ),
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
            colors: [Color(0xFF143D2B), Color(0xFF1E5C41)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF86EFAC).withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF143D2B).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count NOUVELLE${count > 1 ? 'S' : ''}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appels d\'offres\n& Annonces',
                    style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Découvrez les nouveaux projets de construction',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Text('Explorer les opportunités', style: TextStyle(color: Color(0xFF86EFAC), fontSize: 13, fontWeight: FontWeight.w800)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF86EFAC)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.assignment_rounded, size: 64, color: Colors.white24),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
          boxShadow: [
            BoxShadow(color: const Color(0xFF143D2B).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
