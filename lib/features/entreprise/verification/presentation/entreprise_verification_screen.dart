import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../data/models/certification_request_model.dart';
import 'widgets/document_upload_widget.dart';
import '../../../../core/theme/app_spacing.dart';

final myCertificationProvider =
    StreamProvider.family<CertificationRequestModel?, String>((
      ref,
      entrepriseId,
    ) {
      return FirebaseFirestore.instance
          .collection('demandes_certification')
          .doc(entrepriseId)
          .snapshots()
          .map(
            (doc) => doc.exists
                ? CertificationRequestModel.fromJson(doc.data()!, doc.id)
                : null,
          );
    });

class EntrepriseVerificationScreen extends ConsumerStatefulWidget {
  final String entrepriseId;
  const EntrepriseVerificationScreen({super.key, required this.entrepriseId});

  @override
  ConsumerState<EntrepriseVerificationScreen> createState() =>
      _EntrepriseVerificationScreenState();
}

class _EntrepriseVerificationScreenState
    extends ConsumerState<EntrepriseVerificationScreen> {
  final Map<String, File> _selectedFiles = {};
  bool _isUploading = false;
  String _uploadStatus = '';

  @override
  Widget build(BuildContext context) {
    final activeRequestAsync = ref.watch(
      myCertificationProvider(widget.entrepriseId),
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Certification Entreprise')),
      body: activeRequestAsync.when(
        data: (request) {
          if (request == null ||
              request.statut == 'brouillon' ||
              request.statut == 'rejetee') {
            return _buildForm(context, request);
          }
          return _buildStatusView(request);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildStatusView(CertificationRequestModel request) {
    final theme = Theme.of(context);
    final isPending = request.statut == 'en_attente';
    final isCertified = request.statut == 'certifiee';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCertified ? Icons.verified : Icons.hourglass_top,
              size: 80,
              color: isCertified ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isCertified ? 'Entreprise certifiée !' : 'En cours d\'examen',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isCertified
                  ? 'Félicitations, vous pouvez désormais répondre aux appels d\'offres.'
                  : 'Votre demande envoyée le ${request.dateSoumission?.toLocal().toString().split(' ')[0] ?? 'récemment'} est en cours de traitement.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, CertificationRequestModel? request) {
    final theme = Theme.of(context);

    // Check missing documents
    bool hasRccm =
        _selectedFiles.containsKey('RCCM') ||
        (request?.documents.any((d) => d.type == 'RCCM') ?? false);
    bool hasNiu =
        _selectedFiles.containsKey('NIU') ||
        (request?.documents.any((d) => d.type == 'NIU') ?? false);
    bool hasId =
        _selectedFiles.containsKey('PIECE_IDENTITE') ||
        (request?.documents.any((d) => d.type == 'PIECE_IDENTITE') ?? false);

    bool canSubmit = hasRccm && hasNiu && hasId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (request?.statut == 'rejetee') ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demande rejetée',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Motif : ${request?.motifRejet ?? "Non précisé"}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          Text(
            'Documents obligatoires',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          DocumentUploadWidget(
            title: 'Registre de commerce (RCCM)',
            documentType: 'RCCM',
            onFileSelected: (file) =>
                setState(() => _selectedFiles['RCCM'] = file),
          ),
          const SizedBox(height: AppSpacing.sm),
          DocumentUploadWidget(
            title: 'Identifiant Fiscal (NIU)',
            documentType: 'NIU',
            onFileSelected: (file) =>
                setState(() => _selectedFiles['NIU'] = file),
          ),
          const SizedBox(height: AppSpacing.sm),
          DocumentUploadWidget(
            title: 'Pièce d\'identité du gérant',
            documentType: 'PIECE_IDENTITE',
            onFileSelected: (file) =>
                setState(() => _selectedFiles['PIECE_IDENTITE'] = file),
          ),

          const SizedBox(height: AppSpacing.xl),

          if (!canSubmit && !_isUploading)
            const Text(
              'Veuillez fournir tous les documents requis pour soumettre la demande.',
              style: TextStyle(color: Colors.orange),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: AppSpacing.md),

          ElevatedButton(
            onPressed: (canSubmit && !_isUploading)
                ? () => _submitRequest(request)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isUploading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(_uploadStatus),
                    ],
                  )
                : const Text(
                    'Soumettre ma demande',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest(CertificationRequestModel? currentRequest) async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Préparation...';
    });

    try {
      final docList = currentRequest?.documents.toList() ?? [];

      for (var entry in _selectedFiles.entries) {
        setState(() => _uploadStatus = 'Envoi de ${entry.key}...');
        final type = entry.key;
        final file = entry.value;
        final ref = FirebaseStorage.instance.ref().child(
          'certifications/${widget.entrepriseId}/${type}_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );

        await ref.putFile(file);
        final url = await ref.getDownloadURL();

        // Remove old document of same type if it exists
        docList.removeWhere((d) => d.type == type);

        docList.add(
          CertificationDocument(
            type: type,
            nom: file.path.split('/').last,
            url: url,
            dateUpload: DateTime.now(),
          ),
        );
      }

      setState(() => _uploadStatus = 'Enregistrement...');

      // Update or create draft in Firestore
      final db = FirebaseFirestore.instance;
      final docRef = db
          .collection('demandes_certification')
          .doc(widget.entrepriseId);

      if (currentRequest == null) {
        // We need enterprise data, let's fetch it from entreprises collection
        final entDoc = await db
            .collection('entreprises')
            .doc(widget.entrepriseId)
            .get();
        final entData = entDoc.data() ?? {};

        await docRef.set({
          'entrepriseId': widget.entrepriseId,
          'raisonSociale': entData['raisonSociale'] ?? 'Entreprise sans nom',
          'rccm': entData['rccm'] ?? '',
          'niu': entData['niu'] ?? '',
          'villesZones': entData['villesIntervention'] ?? [],
          'specialites': entData['specialites'] ?? [],
          'contact': entData['telephone'] ?? '',
          'documents': docList.map((d) => d.toJson()).toList(),
          'statut': 'brouillon',
          'nombreSoumissions': 0,
        });
      } else {
        await docRef.update({
          'documents': docList.map((d) => d.toJson()).toList(),
        });
      }

      setState(() => _uploadStatus = 'Validation finale...');

      // Call Cloud Function to submit
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('soumettreCertification');
      await callable.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande soumise avec succès !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadStatus = '';
        });
      }
    }
  }
}
