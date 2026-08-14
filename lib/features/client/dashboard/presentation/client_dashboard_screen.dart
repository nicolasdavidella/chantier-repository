import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/dashboard_providers.dart';
import 'widgets/project_card.dart';
import 'widgets/dashboard_empty_state.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../search_entreprises/presentation/screens/search_entreprises_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

import 'tabs/client_projects_tab.dart';
import 'tabs/client_messages_tab.dart';

class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends ConsumerState<ClientDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ClientHomeTab(),
    const ClientProjectsTab(),
    const SearchEntreprisesScreen(),
    const ClientMessagesTab(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBody: true,
      backgroundColor: theme.colorScheme.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Black pill
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, FontAwesomeIcons.house),
                _buildNavItem(1, FontAwesomeIcons.barsProgress),
                _buildNavItem(2, FontAwesomeIcons.magnifyingGlass),
                _buildNavItem(3, FontAwesomeIcons.message),
                _buildNavItem(4, FontAwesomeIcons.user),
              ],
            ),
          ).animate().slideY(begin: 1, duration: 500.ms, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, dynamic icon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: FaIcon(
          icon,
          color: isSelected ? Colors.white : Colors.white54,
          size: 20,
        ),
      ),
    );
  }
}

class ClientHomeTab extends ConsumerWidget {
  const ClientHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileState = ref.watch(currentUserProfileProvider);
    final projectsState = ref.watch(clientProjectsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: theme.colorScheme.primary,
          onRefresh: () async {
            ref.invalidate(clientProjectsProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // EN-TÊTE (Header)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menu Icon (Placeholder for drawer or settings)
                      const FaIcon(FontAwesomeIcons.barsStaggered, size: 24),
                      
                      // Notification & Avatar
                      Row(
                        children: [
                          Stack(
                            children: [
                              const FaIcon(FontAwesomeIcons.bell, size: 24),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.surface,
                            backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              
              // TEXTE D'ACCROCHE
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Découvrez vos\nnouveaux chantiers !',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              
              // SEARCH BAR & FILTERS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              icon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16, color: Colors.grey),
                              hintText: 'Rechercher un projet...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const FaIcon(FontAwesomeIcons.sliders, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              
              // CHIPS (En cours, Terminés)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildPillChip('En cours', true),
                        const SizedBox(width: 12),
                        _buildPillChip('Terminés', false),
                        const SizedBox(width: 12),
                        _buildPillChip('Brouillons', false),
                      ],
                    ),
                  ),
                ),
              ),

              // LISTE HORIZONTALE (Discover)
              projectsState.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return SliverToBoxAdapter(
                      child: DashboardEmptyState(
                        onAddProject: () {
                          context.go('/client/create_project');
                        },
                      ),
                    );
                  }

                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 320,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: SizedBox(
                              width: 280,
                              child: ProjectCard(project: projects[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: ProjectCardSkeleton(),
                  ),
                ),
                error: (err, _) => const SliverToBoxAdapter(child: SizedBox()),
              ),
              
              // SECTION "Récents" ou "À proximité"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text(
                    'Activités Récentes',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              // LISTE VERTICALE
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1503387762-592deb58ef4e?q=80&w=300&auto=format&fit=crop'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Villa Horizon', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('12 500 000 FCFA', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const FaIcon(FontAwesomeIcons.heart, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: 3,
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Spacer for bottom nav
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/client/create_project'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const FaIcon(FontAwesomeIcons.plus, size: 20),
      ),
    );
  }

  Widget _buildPillChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: isSelected ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: isSelected ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

