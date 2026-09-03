import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chantier_track/data/models/user_model.dart';
import '../../../../../core/theme/app_spacing.dart';

class ProfileHeader extends StatefulWidget {
  final UserModel user;
  final Function(XFile) onPhotoSelected;
  final bool isUploading;

  const ProfileHeader({
    super.key, 
    required this.user, 
    required this.onPhotoSelected,
    this.isUploading = false,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      widget.onPhotoSelected(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty
                  ? NetworkImage(widget.user.photoUrl!)
                  : null,
              child: widget.user.photoUrl == null || widget.user.photoUrl!.isEmpty
                  ? Text(
                      widget.user.prenom.isNotEmpty ? widget.user.prenom[0].toUpperCase() : '?',
                      style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    )
                  : null,
            ),
            if (widget.isUploading)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: widget.isUploading ? null : _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vMd,
        Text(
          '${widget.user.prenom} ${widget.user.nom}',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          widget.user.role.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
