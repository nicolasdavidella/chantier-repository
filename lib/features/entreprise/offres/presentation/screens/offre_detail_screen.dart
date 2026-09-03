import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/data/models/project_model.dart';
import 'package:chantier_track/features/entreprise/offres/providers/offres_provider.dart';

class OffreDetailScreen extends ConsumerWidget {
  final ProjectModel projet;

  const OffreDetailScreen({super.key, required this.projet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final candidatureState = ref.watch(candidatureControllerProvider);

    // Formatteur de date
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'Offre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projet.titre,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Carte Info Principales
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context, 
                    Icons.location_on, 
                    'Localisation', 
                    '${projet.localisation['ville'] ?? ''}, ${projet.localisation['quartier'] ?? ''}',
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildInfoRow(
                    context, 
                    Icons.account_balance_wallet, 
                    'Budget Prévu', 
                    '${projet.budgetPrevisionnel.toStringAsFixed(0)} FCFA',
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildInfoRow(
                    context, 
                    Icons.calendar_today, 
                    'Date de début', 
                    dateFormat.format(projet.dateDebut),
                  ),
                  const Divider(height: AppSpacing.xl),
                  _buildInfoRow(
                    context, 
                    Icons.event_available, 
                    'Date de fin estimée', 
                    dateFormat.format(projet.dateFinPrevue),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Description du Projet',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              projet.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            
            if (projet.listeDocuments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Documents Joints',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              ...projet.listeDocuments.map((docUrl) => 
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.filePdf, color: Colors.redAccent),
                  title: Text('Document attaché', style: theme.textTheme.bodyMedium),
                  trailing: const Icon(Icons.download),
                  onTap: () {
                    // TODO: Implémenter le téléchargement ou l'aperçu
                  },
                )
              ),
            ],
            
            const SizedBox(height: 100), // Espace pour la bottom bar
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: candidatureState.isLoading ? null : () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offre ignorée')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.colorScheme.error),
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: const Text('Rejeter'),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: candidatureState.isLoading ? null : () async {
                    try {
                      await ref.read(candidatureControllerProvider.notifier).accepterProjet(projet.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Candidature envoyée avec succès !')),
                        );
                        context.pop();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: candidatureState.isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Accepter le projet', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
