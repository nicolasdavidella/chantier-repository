import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/verification_request_model.dart';
import '../../../../data/models/verification_document_model.dart';
import '../providers/admin_verification_providers.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class AdminVerificationDetailScreen extends ConsumerStatefulWidget {
  final VerificationRequestModel request;

  const AdminVerificationDetailScreen({super.key, required this.request});

  @override
  ConsumerState<AdminVerificationDetailScreen> createState() => _AdminVerificationDetailScreenState();
}

class _AdminVerificationDetailScreenState extends ConsumerState<AdminVerificationDetailScreen> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la demande'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations Entreprise',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text('Entreprise ID: \${widget.request.entrepriseId}'),
                subtitle: const Text('Dans un vrai cas, on charge les détails de l\'entreprise ici.'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Documents soumis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.request.documents.isEmpty)
              const Text('Aucun document fourni.'),
            ...widget.request.documents.map((doc) => _buildDocumentCard(doc)),
            const SizedBox(height: 32),
            const Divider(),
            const Text(
              'Décision finale',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Motif ou commentaire global (obligatoire en cas de rejet)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () => _handleDecision('REJECTED'),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text('Rejeter', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () => _handleDecision('APPROVED'),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('Approuver', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(VerificationDocumentModel doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  doc.type.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildStatusBadge(doc.status),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Ouvrir le document (PDF viewer ou Image viewer)
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Ouvrir le document'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => _updateDocStatus(doc, 'REJECTED'),
                  child: const Text('Rejeter (doc)', style: TextStyle(color: AppColors.error)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _updateDocStatus(doc, 'APPROVED'),
                  child: const Text('Valider (doc)', style: TextStyle(color: AppColors.success)),
                ),
              ],
            ),
            if (doc.rejectionReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Motif du rejet: \${doc.rejectionReason}', style: const TextStyle(color: AppColors.error)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'APPROVED':
        color = AppColors.success;
        break;
      case 'REJECTED':
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _updateDocStatus(VerificationDocumentModel doc, String status) {
    if (status == 'REJECTED') {
      // Afficher un dialog pour demander le motif
      showDialog(
        context: context,
        builder: (context) {
          final motifController = TextEditingController();
          return AlertDialog(
            title: const Text('Motif de rejet'),
            content: TextField(
              controller: motifController,
              decoration: const InputDecoration(hintText: 'Le document est flou...'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
              TextButton(
                onPressed: () {
                  if (motifController.text.isNotEmpty) {
                    ref.read(adminVerificationControllerProvider.notifier).updateDocumentStatus(
                      widget.request.id,
                      widget.request.entrepriseId,
                      doc.type,
                      'REJECTED',
                      motifController.text,
                      'admin_123', // TODO: Remplacer par l'ID de l'admin connecté
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Confirmer'),
              ),
            ],
          );
        },
      );
    } else {
      ref.read(adminVerificationControllerProvider.notifier).updateDocumentStatus(
        widget.request.id,
        widget.request.entrepriseId,
        doc.type,
        'APPROVED',
        null,
        'admin_123', // TODO: Remplacer par l'ID de l'admin connecté
      );
    }
  }

  void _handleDecision(String status) {
    if (status == 'REJECTED' && _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez fournir un motif de rejet.')),
      );
      return;
    }

    ref.read(adminVerificationControllerProvider.notifier).updateRequestStatus(
      widget.request.id,
      widget.request.entrepriseId,
      status,
      'admin_123', // TODO: Remplacer par l'ID de l'admin connecté
      globalFeedback: _feedbackController.text,
    );
    
    Navigator.pop(context);
  }
}
