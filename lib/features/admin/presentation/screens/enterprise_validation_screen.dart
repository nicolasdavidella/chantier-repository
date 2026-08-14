import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/entreprise_model.dart';
import '../providers/admin_providers.dart';

class EnterpriseValidationScreen extends ConsumerWidget {
  const EnterpriseValidationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingEnterprises = ref.watch(pendingEnterprisesProvider);
    final theme = Theme.of(context);

    // Responsive checking
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entreprises en attente'),
        centerTitle: false,
      ),
      body: pendingEnterprises.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                  AppSpacing.vMd,
                  Text('Aucune entreprise en attente', style: theme.textTheme.titleMedium),
                ],
              ),
            )
          : ListView.builder(
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
                      backgroundImage: entreprise.logoUrl != null ? NetworkImage(entreprise.logoUrl!) : null,
                      child: entreprise.logoUrl == null ? const Icon(Icons.business) : null,
                    ),
                    title: Text(entreprise.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(entreprise.specialites.join(', ')),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Email', entreprise.email),
                            _buildInfoRow('Téléphone', entreprise.telephone ?? 'Non renseigné'),
                            _buildInfoRow('Zones', entreprise.zoneIntervention.join(', ')),
                            AppSpacing.vMd,
                            const Text('Documents Soumis', style: TextStyle(fontWeight: FontWeight.bold)),
                            AppSpacing.vSm,
                            Row(
                              children: [
                                const Icon(Icons.description, color: Colors.red),
                                AppSpacing.hXs,
                                const Text('RCCM.pdf', style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                                AppSpacing.hLg,
                                const Icon(Icons.description, color: Colors.red),
                                AppSpacing.hXs,
                                const Text('CNI_Gerant.pdf', style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                              ],
                            ),
                            AppSpacing.vLg,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _showRejectDialog(context, ref, entreprise),
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Rejeter'),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                ),
                                AppSpacing.hMd,
                                FilledButton.icon(
                                  onPressed: () => _showValidateDialog(context, ref, entreprise),
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('Valider'),
                                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
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
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showValidateDialog(BuildContext context, WidgetRef ref, EntrepriseModel entreprise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la validation'),
        content: Text('Voulez-vous vraiment valider l\'entreprise "${entreprise.nom}" ? Elle pourra désormais soumettre des devis.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              ref.read(pendingEnterprisesProvider.notifier).validateEnterprise(entreprise.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Entreprise ${entreprise.nom} validée')));
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, EntrepriseModel entreprise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter la candidature'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez-vous rejeter l\'entreprise "${entreprise.nom}" ?'),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(pendingEnterprisesProvider.notifier).rejectEnterprise(entreprise.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Entreprise ${entreprise.nom} rejetée')));
            },
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }
}
