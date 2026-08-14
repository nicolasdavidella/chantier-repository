import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/admin_providers.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersManagementProvider);
    final theme = Theme.of(context);
    
    final filteredUsers = users.where((u) => 
      u.nom.toLowerCase().contains(_searchQuery.toLowerCase()) || 
      u.email.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: filteredUsers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                
                Color roleColor;
                switch (user.role) {
                  case 'admin': roleColor = Colors.purple; break;
                  case 'entreprise': roleColor = Colors.orange; break;
                  case 'chef_chantier': roleColor = Colors.blue; break;
                  default: roleColor = Colors.green;
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: user.isActive ? theme.colorScheme.primaryContainer : Colors.grey[300],
                    child: Icon(Icons.person, color: user.isActive ? theme.colorScheme.primary : Colors.grey),
                  ),
                  title: Row(
                    children: [
                      Text(user.nom, style: TextStyle(fontWeight: FontWeight.bold, decoration: user.isActive ? null : TextDecoration.lineThrough, color: user.isActive ? null : Colors.grey)),
                      AppSpacing.hSm,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: roleColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(user.role.toUpperCase(), style: TextStyle(fontSize: 10, color: roleColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  subtitle: Text(user.email),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'toggle_status') {
                        ref.read(usersManagementProvider.notifier).toggleStatus(user.id);
                      } else {
                        ref.read(usersManagementProvider.notifier).changeRole(user.id, value);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle_status',
                        child: Text(user.isActive ? 'Désactiver le compte' : 'Réactiver le compte', style: TextStyle(color: user.isActive ? Colors.red : Colors.green)),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(enabled: false, child: Text('Changer de rôle :')),
                      const PopupMenuItem(value: 'client', child: Text('Client')),
                      const PopupMenuItem(value: 'entreprise', child: Text('Entreprise')),
                      const PopupMenuItem(value: 'chef_chantier', child: Text('Chef de chantier')),
                      const PopupMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
