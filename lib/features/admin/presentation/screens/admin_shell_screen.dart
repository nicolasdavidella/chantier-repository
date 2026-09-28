import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'admin_dashboard_screen.dart';
import 'certifications_screen.dart';
import 'user_management_screen.dart';
import 'moderation_screen.dart';
import 'activity_logs_screen.dart';
import 'reclamations_screen.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/data/auth_repository.dart';

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
    const ModerationScreen(),
    const ActivityLogsScreen(),
    const ReclamationsScreen(),
  ];

  final List<NavigationRailDestination> _railDestinations = const [
    NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Tableau de bord')),
    NavigationRailDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: Text('Certifications')),
    NavigationRailDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: Text('Utilisateurs')),
    NavigationRailDestination(icon: Icon(Icons.gavel_outlined), selectedIcon: Icon(Icons.gavel), label: Text('Modération')),
    NavigationRailDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: Text('Logs')),
    NavigationRailDestination(icon: Icon(Icons.report_problem_outlined), selectedIcon: Icon(Icons.report_problem), label: Text('Réclamations')),
  ];

  final List<NavigationDestination> _bottomDestinations = const [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Tableau de bord'),
    NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: 'Certifications'),
    NavigationDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: 'Utilisateurs'),
    NavigationDestination(icon: Icon(Icons.gavel_outlined), selectedIcon: Icon(Icons.gavel), label: 'Modération'),
    NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Logs'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light blue-grey background
      body: Row(
        children: [
          if (isWideScreen)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                indicatorColor: const Color(0xFFE8601A).withValues(alpha: 0.15),
                selectedIconTheme: const IconThemeData(color: Color(0xFFE8601A)),
                selectedLabelTextStyle: const TextStyle(color: Color(0xFFE8601A), fontWeight: FontWeight.bold),
                unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
                unselectedLabelTextStyle: TextStyle(color: Colors.grey.shade600),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF0F6E56)),
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
                            color: const Color(0xFF0F6E56).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ADMIN CHANTIER',
                            style: TextStyle(
                              color: Color(0xFF0F6E56),
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
                        icon: const Icon(Icons.logout, color: Colors.red),
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
                destinations: _railDestinations,
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
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              indicatorColor: const Color(0xFFE8601A).withValues(alpha: 0.2),
              destinations: _bottomDestinations,
            ),
    );
  }
}
