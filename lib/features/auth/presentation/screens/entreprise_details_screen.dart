import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/user_repository.dart';
import '../../../../data/models/entreprise_model.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class EntrepriseDetailsScreen extends ConsumerStatefulWidget {
  final String userId;
  const EntrepriseDetailsScreen({super.key, required this.userId});

  @override
  ConsumerState<EntrepriseDetailsScreen> createState() => _EntrepriseDetailsScreenState();
}

class _EntrepriseDetailsScreenState extends ConsumerState<EntrepriseDetailsScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Info Société
  final _step1FormKey = GlobalKey<FormState>();
  final _raisonSocialeController = TextEditingController();
  final _nifController = TextEditingController();
  final _rccmController = TextEditingController();
  final _adresseController = TextEditingController();

  // Step 2: Spécialités
  final _step2FormKey = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  List<String> _selectedSpecialites = [];
  final List<String> _availableSpecialites = [
    'Gros œuvre', 'Plomberie', 'Électricité', 'Menuiserie',
    'Peinture', 'Revêtement', 'Charpente', 'Terrassement'
  ];

  // Step 3: Documents
  File? _nifFile;
  File? _rccmFile;

  Future<void> _pickFile(bool isNif) async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
    if (result != null && result.isNotEmpty && result.first.path != null) {
      setState(() {
        if (isNif) {
          _nifFile = File(result.first.path!);
        } else {
          _rccmFile = File(result.first.path!);
        }
      });
    }
  }

  Future<String?> _uploadFile(File file, String entrepriseId, String docType) async {
    try {
      final ext = p.extension(file.path);
      final ref = FirebaseStorage.instance.ref().child('entreprises/$entrepriseId/documents/${docType}_$entrepriseId$ext');
      final task = await ref.putFile(file);
      return await task.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (_nifFile == null || _rccmFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez uploader les deux documents.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newId = FirebaseFirestore.instance.collection('entreprises').doc().id;
      
      // Upload docs
      final nifUrl = await _uploadFile(_nifFile!, newId, 'nif');
      final rccmUrl = await _uploadFile(_rccmFile!, newId, 'rccm');

      if (nifUrl == null || rccmUrl == null) {
        throw Exception("Erreur lors de l'upload des documents.");
      }

      final entreprise = EntrepriseModel(
        id: newId,
        userId: widget.userId,
        raisonSociale: _raisonSocialeController.text.trim(),
        numeroImmatriculation: _rccmController.text.trim(),
        adresseSiege: _adresseController.text.trim(),
        description: '', // Can be added later
        specialites: _selectedSpecialites, 
        anneesExperience: int.tryParse(_experienceController.text.trim()) ?? 0,
        noteMoyenne: 0.0,
        nombreAvis: 0,
        realisations: [],
        zoneIntervention: [],
        isVerified: false,
        nifDocumentUrl: nifUrl,
        rccmDocumentUrl: rccmUrl,
      );

      await ref.read(userRepositoryProvider).createEntreprise(entreprise);
      if (mounted) context.go('/entreprise_certification', extra: entreprise.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription Entreprise')),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_step1FormKey.currentState!.validate()) {
              setState(() => _currentStep++);
            }
          } else if (_currentStep == 1) {
            if (_step2FormKey.currentState!.validate()) {
              if (_selectedSpecialites.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sélectionnez au moins une spécialité.')));
                return;
              }
              setState(() => _currentStep++);
            }
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: details.onStepContinue,
                    text: _currentStep == 2 ? 'Terminer' : 'Suivant',
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : details.onStepCancel,
                      child: const Text('Précédent'),
                    ),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Infos'),
            isActive: _currentStep >= 0,
            content: Form(
              key: _step1FormKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _raisonSocialeController,
                    label: 'Raison sociale',
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _nifController,
                    label: 'NIF (Numéro d\'Identification Fiscale)',
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _rccmController,
                    label: 'Numéro RCCM',
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _adresseController,
                    label: 'Adresse',
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Spécialités'),
            isActive: _currentStep >= 1,
            content: Form(
              key: _step2FormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _experienceController,
                    label: 'Années d\'expérience',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Spécialités', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8.0,
                    children: _availableSpecialites.map((spec) {
                      final isSelected = _selectedSpecialites.contains(spec);
                      return FilterChip(
                        label: Text(spec),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSpecialites.add(spec);
                            } else {
                              _selectedSpecialites.remove(spec);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Documents'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Uploadez vos documents légaux pour vérification.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.textSecondaryLight),
                  ),
                  leading: Icon(_nifFile != null ? Icons.check_circle : Icons.upload_file, color: _nifFile != null ? AppColors.success : AppColors.textSecondaryLight),
                  title: const Text('Copie du NIF'),
                  subtitle: Text(_nifFile?.path.split(Platform.pathSeparator).last ?? 'Aucun fichier sélectionné'),
                  trailing: TextButton(
                    onPressed: () => _pickFile(true),
                    child: const Text('Parcourir'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.textSecondaryLight),
                  ),
                  leading: Icon(_rccmFile != null ? Icons.check_circle : Icons.upload_file, color: _rccmFile != null ? AppColors.success : AppColors.textSecondaryLight),
                  title: const Text('Copie du RCCM'),
                  subtitle: Text(_rccmFile?.path.split(Platform.pathSeparator).last ?? 'Aucun fichier sélectionné'),
                  trailing: TextButton(
                    onPressed: () => _pickFile(false),
                    child: const Text('Parcourir'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
