import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chantier_track/core/theme/app_colors.dart';
import 'package:chantier_track/core/theme/app_spacing.dart';
import 'package:chantier_track/features/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ClientReclamationScreen extends ConsumerStatefulWidget {
  const ClientReclamationScreen({super.key});

  @override
  ConsumerState<ClientReclamationScreen> createState() => _ClientReclamationScreenState();
}

class _ClientReclamationScreenState extends ConsumerState<ClientReclamationScreen> {
  final _titreController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _soumettre() async {
    if (_titreController.text.trim().isEmpty || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProfileProvider).value;
      await FirebaseFirestore.instance.collection('reclamations').add({
        'titre': _titreController.text.trim(),
        'description': _descController.text.trim(),
        'statut': 'ouverte',
        'dateCreation': FieldValue.serverTimestamp(),
        'clientUserId': user?.uid ?? 'unknown',
        'entrepriseId': '', 
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Réclamation envoyée avec succès.')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soumettre une réclamation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Text(
              'Signalez-nous tout problème avec une entreprise ou un chantier. Un administrateur vous répondra dans les plus brefs délais.',
              style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: 'Sujet de la réclamation', border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Détails du problème', border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _soumettre,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Envoyer la réclamation'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
