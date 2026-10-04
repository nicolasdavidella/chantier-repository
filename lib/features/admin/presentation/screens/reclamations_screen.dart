import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../data/models/reclamation_model.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore Provider for Reclamations
final reclamationsStreamProvider = StreamProvider.autoDispose<List<ReclamationModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('reclamations')
      .orderBy('dateCreation', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = doc.data();
            return ReclamationModel(
              id: doc.id,
              projectId: data['projectId'] ?? '',
              titre: data['titre'] ?? 'Sans titre',
              description: data['description'] ?? '',
              statut: data['statut'] ?? 'ouverte',
              dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
              clientUserId: data['clientUserId'] ?? '',
              entrepriseId: data['entrepriseId'] ?? '',
              reponseAdmin: data['reponseAdmin'],
            );
          }).toList());
});

final pendingReclamationsBadgeProvider = Provider.autoDispose<int>((ref) {
  final reclamations = ref.watch(reclamationsStreamProvider).value ?? [];
  return reclamations.where((r) => r.statut == 'ouverte').length;
});

class ReclamationsScreen extends ConsumerWidget {
  const ReclamationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reclamationsAsync = ref.watch(reclamationsStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Réclamations'),
      ),
      body: reclamationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (reclamations) {
          if (reclamations.isEmpty) {
            return const Center(child: Text("Aucune réclamation."));
          }
          return ListView.builder(
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
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
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
                            onPressed: () {},
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
        color = AppColors.success;
        label = 'Résolue';
        break;
      case 'en_traitement':
        color = AppColors.warning;
        label = 'En traitement';
        break;
      case 'ouverte':
      default:
        color = AppColors.error;
        label = 'Ouverte';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
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
