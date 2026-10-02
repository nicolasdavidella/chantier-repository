import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/entreprise_model.dart';
import 'package:chantier_track/features/admin/providers/admin_providers.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class EnterpriseValidationScreen extends ConsumerWidget {
  const EnterpriseValidationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingEnterprisesAsync = ref.watch(pendingEnterprisesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entreprises en attente'),
        centerTitle: false,
      ),
      body: pendingEnterprisesAsync.when(
        data: (pendingEnterprises) {
          if (pendingEnterprises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.successVariant),
                  AppSpacing.vMd,
                  Text('Aucune entreprise en attente', style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: pendingEnterprises.length,
            itemBuilder: (context, index) {
              final entreprise = pendingEnterprises[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.business),
                  ),
                  title: Text(entreprise.raisonSociale, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(entreprise.specialites.join(', ')),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Description', entreprise.description),
                          _buildInfoRow('Zones', entreprise.zoneIntervention.join(', ')),
                          AppSpacing.vMd,
                          const Text('Documents Soumis', style: TextStyle(fontWeight: FontWeight.bold)),
                          AppSpacing.vSm,
                          if (entreprise.nifDocumentUrl != null)
                            ListTile(
                              leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
                              title: const Text('Document NIF'),
                              trailing: const Icon(Icons.open_in_new),
                              onTap: () => _launchURL(entreprise.nifDocumentUrl!),
                            ),
                          if (entreprise.rccmDocumentUrl != null)
                            ListTile(
                              leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
                              title: const Text('Document RCCM'),
                              trailing: const Icon(Icons.open_in_new),
                              onTap: () => _launchURL(entreprise.rccmDocumentUrl!),
                            ),
                          if (entreprise.nifDocumentUrl == null && entreprise.rccmDocumentUrl == null)
                            const Text('Aucun document fourni', style: TextStyle(color: AppColors.error, fontStyle: FontStyle.italic)),
                          AppSpacing.vLg,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showRejectDialog(context, entreprise),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Rejeter'),
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                              ),
                              AppSpacing.hMd,
                              FilledButton.icon(
                                onPressed: () => _showValidateDialog(context, entreprise),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Certifier'),
                                style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textSecondaryLight, fontWeight: FontWeight.bold))),
          Expanded(child: Text(value.isEmpty ? 'Non renseigné' : value)),
        ],
      ),
    );
  }

  void _showValidateDialog(BuildContext context, EntrepriseModel entreprise) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la certification'),
        content: Text('Voulez-vous vraiment certifier l\'entreprise "${entreprise.raisonSociale}" ? Elle pourra désormais soumettre des devis.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance.collection('entreprises').doc(entreprise.id).update({
                  'isVerified': true,
                  'verificationStatus': 'APPROVED',
                  'verificationDate': FieldValue.serverTimestamp(),
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Entreprise ${entreprise.raisonSociale} certifiée')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
            child: const Text('Certifier'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, EntrepriseModel entreprise) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter la candidature'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez-vous rejeter l\'entreprise "${entreprise.raisonSociale}" ?'),
            AppSpacing.vMd,
            const TextField(
              decoration: InputDecoration(
                hintText: 'Motif du rejet (Optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance.collection('entreprises').doc(entreprise.id).update({
                  'verificationStatus': 'REJECTED',
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Entreprise ${entreprise.raisonSociale} rejetée')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }
}
