import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../search_entreprises/presentation/screens/search_entreprises_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'tabs/client_projects_tab.dart';
import 'tabs/client_messages_tab.dart';
import '../../../../data/models/entreprise_model.dart';
import '../../../../data/repositories/entreprise_repository.dart';


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

  static const List<Widget> _pages = [
    ClientHomeTab(),
    ClientProjectsTab(),
    SearchEntreprisesScreen(),
    ClientMessagesTab(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF4F6F9),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(0, Icons.home_rounded),
              _navItem(1, Icons.view_agenda_rounded),
              _navItem(2, Icons.search_rounded),
              _navItem(3, Icons.chat_bubble_rounded),
              _navItem(4, Icons.person_rounded),
            ],
          ),
        ).animate().slideY(begin: 1, duration: 500.ms, curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _navItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8601A) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white54,
          size: 22,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Home Tab — Entreprise Discovery
// ─────────────────────────────────────────────
class ClientHomeTab extends ConsumerStatefulWidget {
  const ClientHomeTab({super.key});

  @override
  ConsumerState<ClientHomeTab> createState() => _ClientHomeTabState();
}

class _ClientHomeTabState extends ConsumerState<ClientHomeTab> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider).value;
    final userName = user?.nom ?? 'Client';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, $userName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: Color(0xFF0F6E56), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Douala, CM',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFE6F3F0),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          color: Color(0xFF0F6E56),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),
              const SizedBox(height: 24),

              // ── Entreprises à proximité ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'À proximité',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(
                          color: Color(0xFF0F6E56),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms),
              ),
              const SizedBox(height: 12),

              // ── Horizontal scroll Firestore ──
              Consumer(
                builder: (context, ref, _) {
                  final nearby = ref.watch(_nearbyEntreprisesProvider);
                  return SizedBox(
                    height: 230,
                    child: nearby.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: Colors.red))),
                      data: (list) => list.isEmpty
                          ? const Center(child: Text('Aucune entreprise', style: TextStyle(color: Color(0xFF6B7280))))
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: list.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                return _NearbyCard(entreprise: list[i])
                                    .animate()
                                    .slideX(begin: 0.2, delay: Duration(milliseconds: 100 * i), duration: 400.ms)
                                    .fadeIn();
                              },
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // ── Recommandés pour vous ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recommandés pour vous',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(
                          color: Color(0xFF0F6E56),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
              ),
              const SizedBox(height: 8),

              // ── Recommended list Firestore ──
              Consumer(
                builder: (context, ref, _) {
                  final recommended = ref.watch(_recommendedEntreprisesProvider);
                  return recommended.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: Colors.red))),
                    data: (list) => list.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Aucune entreprise recommandée', style: TextStyle(color: Color(0xFF6B7280))),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: list.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              return _RecommendedCard(entreprise: list[i])
                                  .animate()
                                  .slideY(begin: 0.1, delay: Duration(milliseconds: 100 * i + 350), duration: 400.ms)
                                  .fadeIn();
                            },
                          ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
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
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(height: 120, color: const Color(0xFFE6F3F0)),
                        errorWidget: (context, url, error) => Container(
                          height: 120, color: const Color(0xFFE6F3F0),
                          child: const Icon(Icons.business, color: Color(0xFF0F6E56)),
                        ),
                      )
                    : Container(
                        height: 120,
                        color: const Color(0xFFE6F3F0),
                        child: const Center(child: Icon(Icons.business, color: Color(0xFF0F6E56), size: 40)),
                      ),
                // Zone badge
                if (entreprise.zoneIntervention.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            entreprise.zoneIntervention.first,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
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
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entreprise.raisonSociale,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Color(0xFFF59E0B), size: 13),
                    const SizedBox(width: 2),
                    Text(
                      entreprise.noteMoyenne.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entreprise.zoneIntervention.join(', '),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(width: 72, height: 72, color: const Color(0xFFE6F3F0)),
                    errorWidget: (context, url, error) => Container(
                      width: 72, height: 72, color: const Color(0xFFE6F3F0),
                      child: const Icon(Icons.business, color: Color(0xFF0F6E56)),
                    ),
                  )
                : Container(
                    width: 72, height: 72, color: const Color(0xFFE6F3F0),
                    child: const Center(child: Icon(Icons.business, color: Color(0xFF0F6E56), size: 36)),
                  ),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      entreprise.noteMoyenne.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entreprise.zoneIntervention.join(', '),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_outline, color: Color(0xFF6B7280), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${entreprise.nombreAvis} Avis',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.work_outline, color: Color(0xFF6B7280), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${entreprise.anneesExperience} ans exp.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
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
}
