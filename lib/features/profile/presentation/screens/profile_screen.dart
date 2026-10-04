import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/data/user_repository.dart';
import 'package:go_router/go_router.dart';

import 'widgets/profile_header.dart';
import 'widgets/editable_info_section.dart';
import 'widgets/settings_section.dart';
import 'widgets/security_section.dart';
import '../../../../core/services/storage_service.dart';
import 'certification_request_screen.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingPhoto = false;

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Déconnexion', style: TextStyle(color: AppColors.error))),
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
        title: const Text('Supprimer le compte', style: TextStyle(color: AppColors.error)),
        content: const Text('Cette action supprimera définitivement vos données (conformité RGPD). Voulez-vous continuer ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continuer', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (step1 == true && mounted) {
      final step2 = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmation finale', style: TextStyle(color: AppColors.error)),
          content: const Text('Veuillez confirmer que vous comprenez que cette action est IRRÉVERSIBLE. Toutes vos données seront perdues.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
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
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF143D2B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mon Profil',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -40,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Center(
                  child: ProfileHeader(
                    user: user,
                    isUploading: _isUploadingPhoto,
                    onPhotoSelected: (file) async {
                      setState(() => _isUploadingPhoto = true);
                      try {
                        final storage = ref.read(storageServiceProvider);
                        final data = await file.readAsBytes();
                        final url = await storage.uploadData('profile_pictures/${user.uid}/avatar.jpg', data, contentType: file.mimeType);
                        
                        final updatedUser = user.copyWith(photoUrl: url);
                        await ref.read(userRepositoryProvider).updateUser(updatedUser);
                        
                        // Invalider le provider pour recharger le profil
                        ref.invalidate(currentUserProfileProvider);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo de profil mise à jour !')));
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
                        }
                      } finally {
                        if (mounted) setState(() => _isUploadingPhoto = false);
                      }
                    },
                  ),
                ),
                
                AppSpacing.vXxl,
                EditableInfoSection(user: user),
                
                if (user.role == 'entreprise') ...[
                  AppSpacing.vXxl,
                  _buildCertificationSection(context), // Added certification section
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
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFF143D2B)),
                    label: const Text(
                      'Se déconnecter',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF143D2B)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFC8E6C9), width: 1.5),
                      ),
                    ),
                  ),
                ),
                
                AppSpacing.vMd,
                
                // Delete Account
                TextButton.icon(
                  onPressed: _handleDeleteAccount,
                  icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626), size: 20),
                  label: const Text('Supprimer mon compte', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
                ),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationSection(BuildContext context) {
    final theme = Theme.of(context);
    // In a real app, this would check the current status from the EntrepriseModel
    // final profileState = ref.watch(currentUserProfileProvider);
    // final status = profileState.value?.statutCertification ?? 'non_demande';
    
    // For demonstration, we'll assume it's 'non_demande' or 'en_attente'
    // If it was 'approuve', we could show a green badge.
    final status = 'non_demande'; // This should be dynamic

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certification',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.vLg,
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.verified, color: status == 'approuve' ? AppColors.success : AppColors.textSecondaryLight, size: 32),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statut de certification',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      status == 'approuve' ? 'Vérifié' : status == 'en_attente' ? 'En cours de validation' : 'Non certifié',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status == 'approuve' ? AppColors.success : status == 'en_attente' ? AppColors.warning : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (status == 'non_demande' || status == 'rejete')
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CertificationRequestScreen(),
                    ));
                  },
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  label: const Text('Demander'),
                ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
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
            Expanded(child: _buildStatCard(context, 'Projets terminés', '12', Icons.task_alt, AppColors.success)),
            AppSpacing.hMd,
            Expanded(child: _buildStatCard(context, 'Note moyenne', '4.8', Icons.star, AppColors.warning)),
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
