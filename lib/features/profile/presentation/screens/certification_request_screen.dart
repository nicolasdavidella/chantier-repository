import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
// Note: We might need to import a provider if we had a real backend, 
// for now we will simulate the submission.
// import '../../../../data/repositories/entreprise_repository.dart';

class CertificationRequestScreen extends ConsumerStatefulWidget {
  const CertificationRequestScreen({super.key});

  @override
  ConsumerState<CertificationRequestScreen> createState() => _CertificationRequestScreenState();
}

class _CertificationRequestScreenState extends ConsumerState<CertificationRequestScreen> {
  final Map<String, PlatformFile?> _documents = {
    'RCCM': null,
    'Pièce d\'identité du gérant': null,
    'Attestation fiscale': null,
    'Assurance RC Pro': null,
  };
  
  bool _isSubmitting = false;

  Future<void> _pickFile(String documentType) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result.isNotEmpty) {
        setState(() {
          _documents[documentType] = result.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection du fichier : $e')),
        );
      }
    }
  }

  Future<void> _submitRequest() async {
    // Validate that all required files are present
    final missingDocs = _documents.entries.where((e) => e.value == null).map((e) => e.key).toList();
    if (missingDocs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez fournir tous les documents requis : ${missingDocs.join(", ")}')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, we would upload the files to Firebase Storage and update the Firestore document:
      // final urls = await uploadFiles(_documents);
      // await ref.read(entrepriseRepositoryProvider).updateCertificationRequest(urls);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande de certification soumise avec succès. Un administrateur l\'examinera sous peu.')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la soumission : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de certification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: theme.colorScheme.primary),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  AppSpacing.hMd,
                  Expanded(
                    child: Text(
                      'Pour certifier votre entreprise et débloquer toutes les fonctionnalités, veuillez fournir les documents justificatifs suivants.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.vXxl,
            Text('Documents requis', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.vLg,
            ..._documents.keys.map((docType) => _buildDocumentPicker(docType)),
            AppSpacing.vXxl,
            AppSpacing.vXxl,
            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: _isSubmitting ? () {} : _submitRequest,
                text: _isSubmitting ? 'Soumission en cours...' : 'Soumettre la demande',
                icon: Icons.upload_file,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPicker(String documentType) {
    final theme = Theme.of(context);
    final file = _documents[documentType];
    final isUploaded = file != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: isUploaded ? Colors.green : Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file,
            color: isUploaded ? Colors.green : Colors.grey,
            size: 32,
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentType,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacing.vXs,
                Text(
                  isUploaded ? file.name : 'Format PDF, JPG ou PNG',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isUploaded ? Colors.green[700] : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppSpacing.hMd,
          OutlinedButton(
            onPressed: () => _pickFile(documentType),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: isUploaded ? Colors.green : theme.colorScheme.primary),
              foregroundColor: isUploaded ? Colors.green : theme.colorScheme.primary,
            ),
            child: Text(isUploaded ? 'Modifier' : 'Ajouter'),
          ),
        ],
      ),
    );
  }
}
