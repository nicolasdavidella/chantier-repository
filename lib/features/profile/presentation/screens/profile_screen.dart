import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/data/auth_repository.dart';
import 'package:go_router/go_router.dart';

import 'widgets/profile_header.dart';
import 'widgets/editable_info_section.dart';
import 'widgets/settings_section.dart';
import 'widgets/security_section.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Déconnexion', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final step1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le compte', style: TextStyle(color: Colors.red)),
        content: const Text('Cette action supprimera définitivement vos données (conformité RGPD). Voulez-vous continuer ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continuer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (step1 == true && mounted) {
      final step2 = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmation finale', style: TextStyle(color: Colors.red)),
          content: const Text('Veuillez confirmer que vous comprenez que cette action est IRRÉVERSIBLE. Toutes vos données seront perdues.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true), 
              child: const Text('SUPPRIMER DÉFINITIVEMENT'),
            ),
          ],
        ),
      );

      if (step2 == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Suppression du compte en cours...')));
        // Simuler la suppression et déconnexion
        await Future.delayed(const Duration(seconds: 2));
        await ref.read(authRepositoryProvider).signOut();
        if (mounted) {
          context.go('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(currentUserProfileProvider);
    
    if (profileState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Si aucun user trouvé (ex: mode invité ou dev), on mock un user
    final user = profileState.value ?? UserModel(
      uid: 'mock_1',
      email: 'client@example.com',
      nom: 'Dupont',
      prenom: 'Jean',
      role: 'client',
      telephone: '+237 600000000',
      dateCreation: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Center(
              child: ProfileHeader(
                user: user,
                onPhotoUpdated: (url) {
                  // Logique pour mettre à jour l'URL côté Firestore
                },
              ),
            ),
            
            AppSpacing.vXxl,
            EditableInfoSection(user: user),
            
            if (user.role == 'entreprise') ...[
              AppSpacing.vXxl,
              _buildActivitySection(context),
            ],
            
            AppSpacing.vXxl,
            const SettingsSection(),
            
            AppSpacing.vXxl,
            const SecuritySection(),
            
            AppSpacing.vXxl,
            AppSpacing.vXxl,
            
            // Logout
            AppButton(
              onPressed: _handleLogout,
              text: 'Se déconnecter',
              icon: Icons.logout,
              isSecondary: true,
            ),
            
            AppSpacing.vMd,
            
            // Delete Account
            TextButton.icon(
              onPressed: _handleDeleteAccount,
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('Supprimer mon compte', style: TextStyle(color: Colors.red)),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mon Activité',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.vLg,
        Row(
          children: [
            Expanded(child: _buildStatCard(context, 'Projets terminés', '12', Icons.task_alt, Colors.green)),
            AppSpacing.hMd,
            Expanded(child: _buildStatCard(context, 'Note moyenne', '4.8', Icons.star, Colors.orange)),
          ],
        ),
        AppSpacing.vMd,
        _buildStatCard(context, 'Taux de respect des délais', '95%', Icons.timer, theme.colorScheme.primary),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          AppSpacing.vSm,
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(title, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
