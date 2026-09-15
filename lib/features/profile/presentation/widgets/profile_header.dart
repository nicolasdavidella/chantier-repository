import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/theme/app_spacing.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  final UserModel user;
  final Function(String) onPhotoUpdated;

  const ProfileHeader({super.key, required this.user, required this.onPhotoUpdated});

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isUploading = true);
        
        // Simuler un upload vers Firebase Storage
        await Future.delayed(const Duration(seconds: 2));
        
        // Dans une vraie app, on récupérerait l'URL de téléchargement
        final fakeUrl = 'https://picsum.photos/seed/profile-user/300/300';
        
        widget.onPhotoUpdated(fakeUrl);
        
        if (mounted) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo de profil mise à jour', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sélection de l\'image', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'client': return 'Client';
      case 'entreprise': return 'Entreprise';
      case 'chef_chantier': return 'Chef de Chantier';
      case 'admin': return 'Administrateur';
      default: return 'Utilisateur';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'client': return Colors.blue;
      case 'entreprise': return Colors.orange;
      case 'chef_chantier': return Colors.green;
      case 'admin': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = _getRoleColor(widget.user.role);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Hero(
              tag: 'profile_avatar',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: roleColor, width: 3),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: ClipOval(
                  child: _isUploading
                      ? const Center(child: CircularProgressIndicator())
                      : (widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.user.photoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.person, size: 60, color: theme.colorScheme.primary),
                            )
                          : Icon(Icons.person, size: 60, color: theme.colorScheme.primary)),
                ),
              ),
            ),
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
            ),
          ],
        ).animate().slideY(begin: 0.2).fadeIn(),
        
        AppSpacing.vLg,
        
        Text(
          widget.user.nom,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ).animate().slideY(begin: 0.2, delay: 100.ms).fadeIn(),
        
        AppSpacing.vXs,
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: roleColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            _getRoleLabel(widget.user.role),
            style: theme.textTheme.labelMedium?.copyWith(
              color: roleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ).animate().slideY(begin: 0.2, delay: 200.ms).fadeIn(),
      ],
    );
  }
}
