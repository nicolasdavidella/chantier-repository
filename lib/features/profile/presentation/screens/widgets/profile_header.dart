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
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF143D2B).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFF143D2B),
                backgroundImage: widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty
                    ? NetworkImage(widget.user.photoUrl!)
                    : null,
                child: widget.user.photoUrl == null || widget.user.photoUrl!.isEmpty
                    ? Text(
                        widget.user.prenom.isNotEmpty ? widget.user.prenom[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF86EFAC)),
                      )
                    : null,
              ),
            ),
            if (widget.isUploading)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF10B981)),
                ),
              ),
            Positioned(
              right: 2,
              bottom: 2,
              child: GestureDetector(
                onTap: widget.isUploading ? null : _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vMd,
        Text(
          '${widget.user.prenom} ${widget.user.nom}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF143D2B)),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
          ),
          child: Text(
            widget.user.role == 'entreprise' ? 'ENTREPRISE BTP' : 'CLIENT / MAÎTRE D\'OUVRAGE',
            style: const TextStyle(
              color: Color(0xFF143D2B),
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
