import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../data/models/reclamation_model.dart';

// Mock Provider for Reclamations
final reclamationsProvider = Provider<List<ReclamationModel>>((ref) {
  return [
    ReclamationModel(
      id: 'r1',
      projectId: 'p1',
      titre: 'Retard inexpliqué',
      description: 'L\'entreprise n\'est pas venue sur le chantier depuis 3 jours sans donner de nouvelles.',
      statut: 'ouverte',
      dateCreation: DateTime.now().subtract(const Duration(days: 2)),
      clientUserId: 'client1',
      entrepriseId: 'ent1',
    ),
    ReclamationModel(
      id: 'r2',
      projectId: 'p2',
      titre: 'Malfaçon carrelage',
      description: 'Le carrelage du salon est mal posé, plusieurs carreaux sont fissurés.',
      statut: 'en_traitement',
      dateCreation: DateTime.now().subtract(const Duration(days: 5)),
      clientUserId: 'client2',
      entrepriseId: 'ent2',
      reponseAdmin: 'Contact pris avec l\'entreprise pour un constat amiable.',
    ),
  ];
});

class ReclamationsScreen extends ConsumerWidget {
  const ReclamationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reclamations = ref.watch(reclamationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Réclamations'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: reclamations.length,
        itemBuilder: (context, index) {
          final reclamation = reclamations[index];
          
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          reclamation.titre,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStatusChip(reclamation.statut),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Date : ${DateFormat('dd MMM yyyy').format(reclamation.dateCreation)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(reclamation.description),
                  const SizedBox(height: AppSpacing.md),
                  if (reclamation.reponseAdmin != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.admin_panel_settings, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Admin: ${reclamation.reponseAdmin}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Afficher les détails du projet et du client
                        },
                        child: const Text('Détails'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showResponseDialog(context, reclamation);
                        },
                        child: const Text('Traiter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String statut) {
    Color color;
    String label;
    switch (statut) {
      case 'resolue':
        color = Colors.green;
        label = 'Résolue';
        break;
      case 'en_traitement':
        color = Colors.orange;
        label = 'En traitement';
        break;
      case 'ouverte':
      default:
        color = Colors.red;
        label = 'Ouverte';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showResponseDialog(BuildContext context, ReclamationModel reclamation) {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Traiter la réclamation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Saisissez votre réponse ou action...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Réponse envoyée !')));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }
}
