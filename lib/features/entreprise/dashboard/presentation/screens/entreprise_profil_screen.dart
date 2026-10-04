import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/entreprise_model.dart';
import '../../providers/entreprise_dashboard_providers.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../../auth/providers/auth_provider.dart';

class EntrepriseProfilScreen extends ConsumerStatefulWidget {
  const EntrepriseProfilScreen({super.key});

  @override
  ConsumerState<EntrepriseProfilScreen> createState() => _EntrepriseProfilScreenState();
}

class _EntrepriseProfilScreenState extends ConsumerState<EntrepriseProfilScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _raisonCtrl;
  late TextEditingController _nomCommercialCtrl;
  late TextEditingController _responsableNomCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _villeCtrl;

  bool _initialized = false;
  bool _isUploadingImage = false;

  void _initControllers(EntrepriseModel e) {
    if (_initialized) return;
    _raisonCtrl = TextEditingController(text: e.raisonSociale);
    _nomCommercialCtrl = TextEditingController(text: e.nomCommercial ?? '');
    _responsableNomCtrl = TextEditingController(text: e.responsableNom ?? '');
    _descCtrl = TextEditingController(text: e.description);
    _telCtrl = TextEditingController(text: e.telephone ?? '');
    _emailCtrl = TextEditingController(text: e.emailProfessionnel ?? '');
    _villeCtrl = TextEditingController(text: e.ville ?? '');
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _raisonCtrl.dispose();
      _nomCommercialCtrl.dispose();
      _responsableNomCtrl.dispose();
      _descCtrl.dispose();
      _telCtrl.dispose();
      _emailCtrl.dispose();
      _villeCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save(EntrepriseModel entreprise) async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final updatedData = {
        ...entreprise.toJson(),
        'raisonSociale': _raisonCtrl.text.trim(),
        'nomCommercial': _nomCommercialCtrl.text.trim(),
        'responsableNom': _responsableNomCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'telephone': _telCtrl.text.trim(),
        'emailProfessionnel': _emailCtrl.text.trim(),
        'ville': _villeCtrl.text.trim(),
      };
      
      await ref.read(entrepriseProfileControllerProvider.notifier).updateProfile(
        entreprise.id,
        updatedData,
      );
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Profil mis à jour avec succès'),
            ]),
            backgroundColor: AppColors.success,
          ),
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

  Future<void> _pickImage(EntrepriseModel entreprise) async {
    if (!_isEditing) return;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('entreprises_logos')
          .child('${entreprise.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      String downloadUrl;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        downloadUrl = await storageRef.getDownloadURL();
      } else {
        await storageRef.putFile(File(image.path));
        downloadUrl = await storageRef.getDownloadURL();
      }

      await ref.read(entrepriseProfileControllerProvider.notifier).updateProfile(
        entreprise.id,
        {'logoUrl': downloadUrl},
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo mis à jour avec succès'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Vous serez renvoyé vers la page de connexion.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(authRepositoryProvider).signOut();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final entrepriseAsync = ref.watch(currentEntrepriseStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Modifier le profil',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: entrepriseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (entreprise) {
          final currentUser = ref.watch(authStateProvider).value;
          final displayEntreprise = entreprise ?? EntrepriseModel(
            id: currentUser?.uid ?? 'new_entreprise',
            userId: currentUser?.uid ?? '',
            raisonSociale: 'Nouvelle Entreprise',
            description: '',
            specialites: [],
            anneesExperience: 0,
            noteMoyenne: 0.0,
            nombreAvis: 0,
            realisations: [],
            zoneIntervention: [],
          );

          if (entreprise == null && !_isEditing) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _isEditing = true);
            });
          }

          _initControllers(displayEntreprise);

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? () => _pickImage(displayEntreprise) : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 52,
                                backgroundColor: AppColors.primary.withOpacity(0.12),
                                backgroundImage: displayEntreprise.logoUrl != null ? NetworkImage(displayEntreprise.logoUrl!) : null,
                                child: displayEntreprise.logoUrl == null 
                                  ? const Icon(Icons.business_rounded, size: 52, color: AppColors.primary)
                                  : null,
                              ),
                              if (_isUploadingImage)
                                const Positioned.fill(
                                  child: Center(
                                    child: CircularProgressIndicator(color: AppColors.primary),
                                  ),
                                ),
                              if (_isEditing && !_isUploadingImage)
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Certification badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: displayEntreprise.isVerified
                                ? AppColors.successLight
                                : AppColors.warningLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                displayEntreprise.isVerified ? Icons.verified_rounded : Icons.pending_rounded,
                                size: 16,
                                color: displayEntreprise.isVerified ? AppColors.success : AppColors.warning,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                displayEntreprise.isVerified ? 'Entreprise Certifiée' : 'Certification ${displayEntreprise.verificationStatus}',
                                style: TextStyle(
                                  color: displayEntreprise.isVerified ? AppColors.success : AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatBadge(label: 'Note', value: displayEntreprise.noteMoyenne.toStringAsFixed(1), icon: Icons.star_rounded),
                            const SizedBox(width: 16),
                            _StatBadge(label: 'Avis', value: '${displayEntreprise.nombreAvis}', icon: Icons.reviews_rounded),
                            const SizedBox(width: 16),
                            _StatBadge(label: 'Réalisations', value: '${displayEntreprise.realisations.length}', icon: Icons.construction_rounded),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                  const SizedBox(height: 28),
                  const Divider(color: AppColors.borderLight),
                  const SizedBox(height: 20),

                  // Editable fields
                  _buildSection('Informations générales', [
                    _editableField('Raison sociale', _raisonCtrl, Icons.business_rounded),
                    _editableField('Nom commercial / Nom du profil', _nomCommercialCtrl, Icons.badge_rounded),
                    _editableField('Nom du responsable', _responsableNomCtrl, Icons.person_rounded),
                    _editableField('Téléphone', _telCtrl, Icons.phone_rounded, type: TextInputType.phone),
                    _editableField('Email professionnel', _emailCtrl, Icons.email_rounded, type: TextInputType.emailAddress),
                    _editableField('Ville', _villeCtrl, Icons.location_city_rounded),
                  ]),

                  const SizedBox(height: 16),
                  _buildSection('Description', [
                    _editableField('Description', _descCtrl, Icons.description_rounded, maxLines: 4),
                  ]),

                  const SizedBox(height: 16),
                  // Specialités (read-only chips for now)
                  _buildSection('Spécialités', [
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: displayEntreprise.specialites.map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.primary.withOpacity(0.08),
                        side: BorderSide.none,
                      )).toList(),
                    ),
                  ]),

                  const SizedBox(height: 16),
                  // Zones
                  _buildSection('Zones d\'intervention', [
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: displayEntreprise.zoneIntervention.map((z) => Chip(
                        avatar: const Icon(Icons.location_on_rounded, size: 14, color: AppColors.secondary),
                        label: Text(z, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.secondary.withOpacity(0.08),
                        side: BorderSide.none,
                      )).toList(),
                    ),
                  ]),

                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: ref.watch(entrepriseProfileControllerProvider).isLoading
                            ? null
                            : () => _save(displayEntreprise),
                        icon: ref.watch(entrepriseProfileControllerProvider).isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.save_rounded, color: Colors.white),
                        label: const Text('Sauvegarder',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                      label: const Text('Se déconnecter',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight)),
        const SizedBox(height: 12),
        ...children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: w)),
      ],
    );
  }

  Widget _editableField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? type, int maxLines = 1}) {
    if (!_isEditing) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                Text(ctrl.text.isEmpty ? '—' : ctrl.text,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight)),
              ],
            )),
          ],
        ),
      );
    }
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBadge({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimaryLight)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey500)),
        ],
      ),
    );
  }
}
