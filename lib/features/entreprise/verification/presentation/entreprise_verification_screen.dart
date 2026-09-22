import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/verification_providers.dart';
import 'widgets/document_upload_widget.dart';
import '../../../../data/models/verification_document_model.dart';

class EntrepriseVerificationScreen extends ConsumerStatefulWidget {
  final String entrepriseId;
  const EntrepriseVerificationScreen({super.key, required this.entrepriseId});

  @override
  ConsumerState<EntrepriseVerificationScreen> createState() => _EntrepriseVerificationScreenState();
}

class _EntrepriseVerificationScreenState extends ConsumerState<EntrepriseVerificationScreen> {
  int _currentStep = 0;
  final Map<String, File> _selectedFiles = {};

  @override
  Widget build(BuildContext context) {
    final activeRequestAsync = ref.watch(currentVerificationRequestProvider(widget.entrepriseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certification Entreprise'),
      ),
      body: activeRequestAsync.when(
        data: (request) {
          if (request == null || request.status == 'DRAFT') {
            return _buildStepper(context, request?.id);
          }
          return _buildStatusView(request);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: \$e')),
      ),
    );
  }

  Widget _buildStatusView(request) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(request.status),
              size: 80,
              color: _getStatusColor(request.status),
            ),
            const SizedBox(height: 24),
            Text(
              _getStatusTitle(request.status),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _getStatusDescription(request.status),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (request.status == 'REJECTED' || request.status == 'ADDITIONAL_INFO_REQUIRED') ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Mettre à jour pour repasser en mode DRAFT ou afficher le formulaire de correction
                  setState(() {
                    _currentStep = 1;
                  });
                },
                child: const Text('Soumettre les corrections'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'SUBMITTED':
      case 'UNDER_REVIEW': return Icons.hourglass_top;
      case 'APPROVED': return Icons.verified;
      case 'REJECTED': return Icons.cancel;
      default: return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'SUBMITTED':
      case 'UNDER_REVIEW': return Colors.orange;
      case 'APPROVED': return Colors.green;
      case 'REJECTED': return Colors.red;
      default: return Colors.blue;
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'SUBMITTED': return 'Dossier soumis';
      case 'UNDER_REVIEW': return 'En cours de vérification';
      case 'APPROVED': return 'Entreprise vérifiée !';
      case 'REJECTED': return 'Demande refusée';
      case 'ADDITIONAL_INFO_REQUIRED': return 'Informations manquantes';
      default: return 'Statut inconnu';
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'SUBMITTED': return 'Votre dossier a été soumis avec succès et est en attente d\'examen.';
      case 'UNDER_REVIEW': return 'Un administrateur examine actuellement vos documents.';
      case 'APPROVED': return 'Félicitations, votre entreprise est certifiée sur la plateforme !';
      case 'REJECTED': return 'Veuillez consulter les motifs de rejet dans vos documents.';
      default: return '';
    }
  }

  Widget _buildStepper(BuildContext context, String? requestId) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep < 2) {
          setState(() => _currentStep++);
        } else {
          _submitFinalRequest(requestId);
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        }
      },
      steps: [
        Step(
          title: const Text('Profil Entreprise'),
          content: const Text('Ici sera affiché le formulaire de profil (Nom, adresse, RCCM, etc.).'),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Documents'),
          content: Column(
            children: [
              DocumentUploadWidget(
                title: 'Registre de commerce',
                documentType: 'registre_commerce',
                onFileSelected: (file) => _selectedFiles['registre_commerce'] = file,
              ),
              DocumentUploadWidget(
                title: 'Identifiant Fiscal (NIU)',
                documentType: 'identifiant_fiscal',
                onFileSelected: (file) => _selectedFiles['identifiant_fiscal'] = file,
              ),
              DocumentUploadWidget(
                title: 'Pièce d\'identité du responsable',
                documentType: 'cni_responsable',
                onFileSelected: (file) => _selectedFiles['cni_responsable'] = file,
              ),
            ],
          ),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text('Soumission'),
          content: const Text('En soumettant ce dossier, vous confirmez l\'exactitude des informations fournies.'),
          isActive: _currentStep >= 2,
        ),
      ],
    );
  }

  Future<void> _submitFinalRequest(String? requestId) async {
    // Dans une implémentation complète, nous devrions :
    // 1. S'assurer que le requestId existe (getOrCreateDraft)
    // 2. Upload tous les fichiers dans _selectedFiles via VerificationRepository
    // 3. Appeler submitRequest
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dossier soumis pour vérification !')),
    );
  }
}
