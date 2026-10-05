import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/features/admin/providers/admin_providers.dart';
import 'package:chantier_track/core/theme/app_colors.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);
    final theme = Theme.of(context);

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
                hintText: 'Rechercher par nom, email ou téléphone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Erreur de chargement: $err', style: TextStyle(color: theme.colorScheme.error)),
              ),
              data: (users) {
                final filteredUsers = users.where((u) {
                  final query = _searchQuery.toLowerCase();
                  final fullName = '${u.prenom} ${u.nom}'.toLowerCase();
                  final email = u.email.toLowerCase();
                  final phone = u.telephone.toLowerCase();
                  return fullName.contains(query) || email.contains(query) || phone.contains(query);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_rounded, size: 54, color: AppColors.textSecondaryLight),
                        AppSpacing.vMd,
                        Text(
                          _searchQuery.isEmpty ? 'Aucun utilisateur trouvé.' : 'Aucun résultat pour "$_searchQuery"',
                          style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  itemCount: filteredUsers.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    
                    Color roleColor;
                    switch (user.role) {
                      case 'admin':
                        roleColor = Colors.purple;
                        break;
                      case 'entreprise':
                        roleColor = AppColors.warning;
                        break;
                      case 'chef_chantier':
                        roleColor = AppColors.primary;
                        break;
                      default:
                        roleColor = AppColors.success;
                    }

                    final displayName = (user.prenom.trim().isEmpty && user.nom.trim().isEmpty)
                        ? (user.email.isNotEmpty ? user.email : 'Utilisateur sans nom')
                        : '${user.prenom} ${user.nom}'.trim();

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: user.isActive ? theme.colorScheme.primaryContainer : AppColors.grey300,
                        backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                            ? Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: user.isActive ? theme.colorScheme.primary : AppColors.textSecondaryLight,
                                ),
                              )
                            : null,
                      ),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: user.isActive ? null : TextDecoration.lineThrough,
                              color: user.isActive ? null : AppColors.textSecondaryLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: roleColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(fontSize: 10, color: roleColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (user.email.isNotEmpty) Text(user.email, style: const TextStyle(fontSize: 13)),
                          if (user.telephone.isNotEmpty)
                            Text(user.telephone, style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'toggle_status') {
                            await AdminUserController.toggleStatus(user.uid, user.isActive);
                          } else {
                            await AdminUserController.changeRole(user.uid, value);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Utilisateur mis à jour avec succès'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'toggle_status',
                            child: Text(
                              user.isActive ? 'Désactiver le compte' : 'Réactiver le compte',
                              style: TextStyle(color: user.isActive ? AppColors.error : AppColors.success),
                            ),
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
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
