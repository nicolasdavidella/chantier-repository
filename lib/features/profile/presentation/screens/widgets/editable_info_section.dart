import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chantier_track/data/models/user_model.dart';
import 'package:chantier_track/core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../auth/data/user_repository.dart';
import '../../../../auth/providers/auth_provider.dart';

class EditableInfoSection extends ConsumerStatefulWidget {
  final UserModel user;

  const EditableInfoSection({super.key, required this.user});

  @override
  ConsumerState<EditableInfoSection> createState() => _EditableInfoSectionState();
}

class _EditableInfoSectionState extends ConsumerState<EditableInfoSection> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomCtrl;
  late TextEditingController _prenomCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nomCtrl = TextEditingController(text: widget.user.nom);
    _prenomCtrl = TextEditingController(text: widget.user.prenom);
    _telCtrl = TextEditingController(text: widget.user.telephone);
    _emailCtrl = TextEditingController(text: widget.user.email);
  }

  @override
  void didUpdateWidget(EditableInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _nomCtrl.text = widget.user.nom;
      _prenomCtrl.text = widget.user.prenom;
      _telCtrl.text = widget.user.telephone;
      _emailCtrl.text = widget.user.email;
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updatedUser = widget.user.copyWith(
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        telephone: _telCtrl.text.trim(),
        // email: email might be tied to auth, skipping update here or doing it carefully.
        // for now just updating the user doc.
      );
      
      await ref.read(userRepositoryProvider).updateUser(updatedUser);
      ref.invalidate(currentUserProfileProvider);
      
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool readOnly = false}) {
    if (!_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(controller.text.isEmpty ? 'Non renseigné' : controller.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
        ),
        validator: (v) => v!.trim().isEmpty ? 'Ce champ est requis' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Informations Personnelles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                IconButton(
                  icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded, color: AppColors.primary),
                  onPressed: () => setState(() {
                    if (_isEditing) {
                      _isEditing = false;
                      _initControllers(); // revert changes
                    } else {
                      _isEditing = true;
                    }
                  }),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildField('Prénom', _prenomCtrl, Icons.person_rounded),
            _buildField('Nom', _nomCtrl, Icons.badge_rounded),
            _buildField('Téléphone', _telCtrl, Icons.phone_rounded),
            _buildField('Email', _emailCtrl, Icons.email_rounded, readOnly: true), // Generally email requires re-auth to change
            
            if (_isEditing) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
