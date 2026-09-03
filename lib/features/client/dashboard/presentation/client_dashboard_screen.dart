import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/dashboard_providers.dart';
import 'widgets/project_card.dart';
import 'widgets/dashboard_empty_state.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../search_entreprises/presentation/screens/search_entreprises_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

import 'tabs/client_projects_tab.dart';
import 'tabs/client_messages_tab.dart';
import 'package:chantier_track/l10n/app_localizations.dart';

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
    final primaryColor = const Color(0xFFD4783B);
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          shape: BoxShape.circle,
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

class ClientHomeTab extends ConsumerStatefulWidget {
  const ClientHomeTab({super.key});

  @override
  ConsumerState<ClientHomeTab> createState() => _ClientHomeTabState();
}

class _ClientHomeTabState extends ConsumerState<ClientHomeTab> {
  final Color primaryColor = const Color(0xFF8B78FF); // Purple from image
  final Color bgColor = const Color(0xFFF8F8FA);
  final Color textColor = const Color(0xFF2E2E2E);
  final Color textLight = const Color(0xFFA0A0A0);
  
  String selectedCategory = 'Gros Œuvre';
  final List<String> categories = ['Gros Œuvre', 'Plomberie', 'Électricité', 'Peinture', 'Menuiserie'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hamburger Menu Icon
                  Icon(Icons.notes, color: textColor, size: 28),
                  // Location Dropdown
                  Row(
                    children: [
                      Text(
                        'Douala, CM',
                        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: textColor),
                    ],
                  ),
                  Row(
                    children: [
                      // Language Toggle
                      InkWell(
                        onTap: () {
                          final currentLang = ref.read(languageProvider);
                          ref.read(languageProvider.notifier).setLanguage(currentLang == 'fr' ? 'en' : 'fr');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ref.watch(languageProvider).toUpperCase(),
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Notification with red dot
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.notifications_none, size: 26),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // 2. Search Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: textLight),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)?.searchHint ?? 'Rechercher un artisan...',
                                hintStyle: TextStyle(color: textLight, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // 3. Categories (Pill Tabs)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ] : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : textLight,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              
              // 4. Near you section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: textColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Près de vous',
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text('Voir tout', style: TextStyle(color: textLight, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _buildNearYouCard(
                      'Bâtisseurs Pros', 
                      'Douala, Akwa', 
                      '2.5 km', 
                      4.5, 
                      'https://images.unsplash.com/photo-1541888081622-15f7956894c4?auto=format&fit=crop&w=400&q=80'
                    ),
                    const SizedBox(width: 20),
                    _buildNearYouCard(
                      'Élite Construction', 
                      'Douala, Bonanjo', 
                      '3.2 km', 
                      4.8, 
                      'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=400&q=80'
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // 5. Recommend For you section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommandés pour vous',
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Voir tout', style: TextStyle(color: textLight, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              _buildRecommendCard(
                'Plomberie Express', 
                'Douala, Deido', 
                '5 Artisans', 
                '2 Chantiers', 
                'https://images.unsplash.com/photo-1581094794329-c8112a89af12?auto=format&fit=crop&w=200&q=80'
              ),
              const SizedBox(height: 16),
              _buildRecommendCard(
                'Menuiserie Moderne', 
                'Douala, Bonamoussadi', 
                '3 Artisans', 
                '1 Chantier', 
                'https://images.unsplash.com/photo-1622675363311-3e1904dc1885?auto=format&fit=crop&w=200&q=80'
              ),
              
              const SizedBox(height: 100), // Padding for bottom nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearYouCard(String title, String location, String distance, double rating, String imageUrl) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        distance,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('$rating', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              location,
              style: TextStyle(color: textLight, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRecommendCard(String title, String location, String stat1, String stat2, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 2),
                        Text('4.5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(color: textLight, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _buildStatIcon(Icons.people_outline, stat1),
                    _buildStatIcon(Icons.business_center_outlined, stat2),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: textLight, size: 14),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: textLight, fontSize: 12)),
      ],
    );
  }
}


