import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/user_repository.dart';
import '../../../../data/models/entreprise_model.dart';

class EntrepriseDetailsScreen extends ConsumerStatefulWidget {
  final String userId;
  const EntrepriseDetailsScreen({super.key, required this.userId});

  @override
  ConsumerState<EntrepriseDetailsScreen> createState() => _EntrepriseDetailsScreenState();
}

class _EntrepriseDetailsScreenState extends ConsumerState<EntrepriseDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _raisonSocialeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final newId = FirebaseFirestore.instance.collection('entreprises').doc().id;
      final entreprise = EntrepriseModel(
        id: newId,
        userId: widget.userId,
        raisonSociale: _raisonSocialeController.text.trim(),
        description: _descriptionController.text.trim(),
        specialites: [], 
        anneesExperience: int.tryParse(_experienceController.text.trim()) ?? 0,
        noteMoyenne: 0.0,
        nombreAvis: 0,
        realisations: [],
        zoneIntervention: [],
        certifie: false,
      );

      await ref.read(userRepositoryProvider).createEntreprise(entreprise);
      if (mounted) context.go('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de l\'entreprise')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Finalisons votre profil professionnel',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppSpacing.vXxl,
              AppTextField(
                controller: _raisonSocialeController,
                label: 'Raison sociale',
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              AppSpacing.vLg,
              AppTextField(
                controller: _experienceController,
                label: 'Années d\'expérience',
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              AppSpacing.vLg,
              AppTextField(
                controller: _descriptionController,
                label: 'Description rapide',
                maxLines: 4,
              ),
              AppSpacing.vXxl,
              AppButton(
                onPressed: _submit,
                text: 'Terminer',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
