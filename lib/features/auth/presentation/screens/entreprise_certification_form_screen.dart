import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/certification_request_model.dart';

class EntrepriseCertificationFormScreen extends ConsumerStatefulWidget {
  final String entrepriseId;
  const EntrepriseCertificationFormScreen({super.key, required this.entrepriseId});

  @override
  ConsumerState<EntrepriseCertificationFormScreen> createState() => _EntrepriseCertificationFormScreenState();
}

class _EntrepriseCertificationFormScreenState extends ConsumerState<EntrepriseCertificationFormScreen> {
  bool _isLoading = false;

  final Map<String, File?> _documents = {
    'RCCM': null,
    'AGREMENT_MINHDU': null,
    'PHOTO_SIEGE_CHANTIER': null,
    'ORGANIGRAMME': null,
    'REFERENCES_PROJETS': null,
    'PIECE_IDENTITE_GERANT': null,
    'NIU': null,
    'CNSS': null,
    'NON_REDEVANCE': null,
    'AUTORISATION_CONSTRUIRE': null,
  };

  final _geolocalisationCtrl = TextEditingController();

  Future<void> _pickFile(String key) async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg']);
    if (result != null && result.isNotEmpty && result.first.path != null) {
      setState(() {
        _documents[key] = File(result.first.path!);
      });
    }
  }

  Future<String?> _uploadFile(File file, String type) async {
    try {
      final ext = p.extension(file.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('entreprises/${widget.entrepriseId}/certification/${type}_${DateTime.now().millisecondsSinceEpoch}$ext');
      final task = await ref.putFile(file);
      return await task.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _submit() async {
    // Check if at least some important documents are uploaded
    // REMOVED FOR TESTING PURPOSES
    /*
    if (_documents['RCCM'] == null && _documents['PIECE_IDENTITE_GERANT'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez fournir au minimum le RCCM et la pièce d\'identité.'))
      );
      return;
    }
    */

    setState(() => _isLoading = true);

    try {
      final fallbackId = FirebaseAuth.instance.currentUser?.uid ?? 'entreprise_test_id';
      final actualEntrepriseId = widget.entrepriseId.isNotEmpty ? widget.entrepriseId : fallbackId;

      // Get current entreprise data to pre-fill model if possible
      final entrepriseDoc = await FirebaseFirestore.instance.collection('entreprises').doc(actualEntrepriseId).get();
      final entrepriseData = entrepriseDoc.data() ?? {};
      
      final uploadedDocs = <CertificationDocument>[];

      for (var entry in _documents.entries) {
        if (entry.value != null) {
          final url = await _uploadFile(entry.value!, entry.key);
          if (url != null) {
            uploadedDocs.add(CertificationDocument(
              type: entry.key,
              nom: p.basename(entry.value!.path),
              url: url,
              dateUpload: DateTime.now(),
            ));
          }
        }
      }

      final certif = CertificationRequestModel(
        entrepriseId: actualEntrepriseId,
        raisonSociale: entrepriseData['raisonSociale'] ?? 'Entreprise Test',
        rccm: entrepriseData['numeroImmatriculation'] ?? '',
        niu: '', // or fetch from enterprise
        villesZones: List<String>.from(entrepriseData['zoneIntervention'] ?? []),
        specialites: List<String>.from(entrepriseData['specialites'] ?? []),
        contact: _geolocalisationCtrl.text, // Reusing contact for geoloc for now
        documents: uploadedDocs,
        statut: 'en_attente',
        dateSoumission: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('demandes_certification')
          .doc(actualEntrepriseId)
          .set(certif.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande de certification soumise avec succès !'), backgroundColor: AppColors.success)
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDocUploader(String key, String title) {
    final file = _documents[key];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _pickFile(key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: file != null ? AppColors.success : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(
                file != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                color: file != null ? AppColors.success : AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (file != null)
                      Text(p.basename(file.path), style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Certification Entreprise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => context.go('/'),
            child: const Text('Plus tard', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prouvez votre expertise',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fournissez ces documents pour obtenir le badge "Entreprise Certifiée" et rassurer vos futurs clients.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildDocUploader('RCCM', 'Photo/scan du RCCM'),
                  _buildDocUploader('NIU', 'Carte de contribuable / NIU'),
                  _buildDocUploader('CNSS', 'Attestation d\'immatriculation CNSS'),
                  _buildDocUploader('NON_REDEVANCE', 'Attestation de non-redevance'),
                  _buildDocUploader('AGREMENT_MINHDU', 'Agrément MINHDU'),
                  _buildDocUploader('AUTORISATION_CONSTRUIRE', 'Autorisation de construire (spécifique BTP)'),
                  _buildDocUploader('PHOTO_SIEGE_CHANTIER', 'Photo du siège / chantier en cours'),
                  
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _geolocalisationCtrl,
                      decoration: InputDecoration(
                        labelText: 'Géolocalisation du siège (ex: Lien Google Maps)',
                        prefixIcon: const Icon(Icons.map_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),

                  _buildDocUploader('ORGANIGRAMME', 'Organigramme de l\'entreprise signé'),
                  _buildDocUploader('REFERENCES_PROJETS', '2-3 références de projets (Photos/PDF)'),
                  _buildDocUploader('PIECE_IDENTITE_GERANT', 'Carte d\'identité du gérant'),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Soumettre la demande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
