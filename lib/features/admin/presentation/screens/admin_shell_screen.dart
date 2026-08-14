import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_dashboard_screen.dart';
import 'enterprise_validation_screen.dart';
import 'user_management_screen.dart';
import 'moderation_screen.dart';
import 'activity_logs_screen.dart';
import '../../../../core/theme/app_spacing.dart';

class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const EnterpriseValidationScreen(),
    const UserManagementScreen(),
    const ModerationScreen(),
    const ActivityLogsScreen(),
  ];

  final List<NavigationRailDestination> _railDestinations = const [
    NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Tableau de bord')),
    NavigationRailDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: Text('Validation')),
    NavigationRailDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: Text('Utilisateurs')),
    NavigationRailDestination(icon: Icon(Icons.gavel_outlined), selectedIcon: Icon(Icons.gavel), label: Text('Modération')),
    NavigationRailDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: Text('Logs')),
  ];

  final List<NavigationDestination> _bottomDestinations = const [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: 'Validation'),
    NavigationDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: 'Users'),
    NavigationDestination(icon: Icon(Icons.gavel_outlined), selectedIcon: Icon(Icons.gavel), label: 'Modération'),
    NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Logs'),
  ];

  @override
  Widget build(BuildContext context) {
    // Check if we have a wide screen
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: _railDestinations,
              elevation: 4,
              backgroundColor: Theme.of(context).colorScheme.surface,
              indicatorColor: Theme.of(context).colorScheme.primaryContainer,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: FloatingActionButton(
                  elevation: 0,
                  onPressed: () {},
                  child: const Icon(Icons.admin_panel_settings),
                ),
              ),
            ),
          
          if (isWideScreen) const VerticalDivider(thickness: 1, width: 1),

          // Main Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: _bottomDestinations,
            ),
    );
  }
}
