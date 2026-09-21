import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/project_detail_provider.dart';
import '../../../../../../core/theme/app_spacing.dart';

class DevisTab extends ConsumerWidget {
  final String projectId;

  const DevisTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devisList = ref.watch(projectDevisProvider(projectId));
    final theme = Theme.of(context);

    if (devisList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.request_quote_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aucun devis reçu pour le moment',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: devisList.length,
      itemBuilder: (context, index) {
        final devis = devisList[index];
        final numberFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Entreprise ${devis.entrepriseId}', // En vrai, récupérer le nom de l'entreprise
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(devis.statut).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(devis.statut),
                        style: TextStyle(
                          color: _getStatusColor(devis.statut),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Montant proposé: ${numberFormat.format(devis.montant)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Délai estimé: ${devis.delaiEstime}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(devis.description),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (devis.statut == 'en_attente') ...[
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Logique de refus
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Devis refusé')));
                        },
                        child: const Text('Refuser'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Logique d'acceptation (met à jour le statut du projet en_cours)
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Devis accepté ! Le projet démarre.')));
                        },
                        child: const Text('Accepter'),
                      ),
                    ] else ...[
                      TextButton.icon(
                        onPressed: () {
                          // Voir le devis en détail ou PDF
                        },
                        icon: const Icon(Icons.remove_red_eye),
                        label: const Text('Voir les détails'),
                      ),
                    ]
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'accepte':
        return Colors.green;
      case 'refuse':
        return Colors.red;
      case 'en_attente':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String statut) {
    switch (statut) {
      case 'accepte':
        return 'Accepté';
      case 'refuse':
        return 'Refusé';
      case 'en_attente':
      default:
        return 'En attente';
    }
  }
}
