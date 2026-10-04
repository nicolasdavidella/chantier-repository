import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'admin_dashboard_screen.dart';
import 'certifications_screen.dart';
import 'user_management_screen.dart';

import 'activity_logs_screen.dart';
import 'reclamations_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

import '../../../auth/data/auth_repository.dart';
import 'package:chantier_track/core/theme/app_colors.dart';

class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  int _selectedIndex = 0;
  bool _isExpanded = false;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const CertificationsScreen(),
    const UserManagementScreen(),
    const ReclamationsScreen(),
    const ActivityLogsScreen(),
    const ProfileScreen(),
  ];

  List<NavigationRailDestination> _getRailDestinations(int pendingCount) {
    return [
      const NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Tableau de bord')),
      const NavigationRailDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: Text('Certifications')),
      const NavigationRailDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: Text('Utilisateurs')),
      NavigationRailDestination(
        icon: Badge(isLabelVisible: pendingCount > 0, label: Text(pendingCount.toString()), child: const Icon(Icons.report_problem_outlined)),
        selectedIcon: Badge(isLabelVisible: pendingCount > 0, label: Text(pendingCount.toString()), child: const Icon(Icons.report_problem)),
        label: const Text('Réclamations')
      ),
      const NavigationRailDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: Text('Logs')),
      const NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profil')),
    ];
  }

  Widget _buildCustomBottomNav(int pendingCount) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimaryLight.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(0, Icons.dashboard_rounded),
              _navItem(1, Icons.domain_rounded),
              _navItem(2, Icons.people_rounded),
              _navItem(3, Icons.report_problem_rounded, pendingCount),
              _navItem(4, Icons.history_rounded, 0),
              _navItem(5, Icons.person_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, [int badgeCount = 0]) {
    final isSelected = _selectedIndex == index;
    Widget iconWidget = Icon(
      icon,
      color: isSelected ? Colors.white : AppColors.grey400,
      size: 24,
    );
    
    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text(badgeCount.toString()),
        child: iconWidget,
      );
    }
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(child: iconWidget),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final pendingCount = ref.watch(pendingReclamationsBadgeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light blue-grey background
      extendBody: true,
      body: Row(
        children: [
          if (isWideScreen)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimaryLight.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  )
                ],
              ),
              child: NavigationRail(
                extended: _isExpanded,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                minExtendedWidth: 220,
                backgroundColor: Colors.transparent,
                indicatorColor: AppColors.secondary.withValues(alpha: 0.15),
                selectedIconTheme: IconThemeData(color: AppColors.secondary),
                selectedLabelTextStyle: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                unselectedIconTheme: IconThemeData(color: AppColors.textSecondaryLight),
                unselectedLabelTextStyle: TextStyle(color: AppColors.textSecondaryLight),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.primary),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                      ),
                      if (_isExpanded) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ADMIN CHANTIER',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        tooltip: 'Déconnexion',
                        onPressed: () async {
                          await ref.read(authRepositoryProvider).signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ),
                  ),
                ),
                destinations: _getRailDestinations(pendingCount),
              ),
            ),

          // Main Content
          Expanded(
            child: ClipRRect(
              borderRadius: isWideScreen ? const BorderRadius.only(topLeft: Radius.circular(32), bottomLeft: Radius.circular(32)) : BorderRadius.zero,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _screens[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen ? null : _buildCustomBottomNav(pendingCount),
    );
  }
}
