import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/project_model.dart';
import '../../../providers/project_detail_provider.dart';
import '../../../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class DevisTab extends ConsumerWidget {
  final ProjectModel project;

  const DevisTab({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devisAsync = ref.watch(projectDevisProvider(project.id));
    final devisList = devisAsync.value ?? [];
    final theme = Theme.of(context);

    if (devisList.isEmpty && project.entreprisesPostulantes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.request_quote_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aucune candidature reçue pour le moment',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (project.entreprisesPostulantes.isNotEmpty) ...[
          Text('Entreprises Intéressées', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          ...project.entreprisesPostulantes.map((entrepriseId) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('entreprises').doc(entrepriseId).get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (!snapshot.data!.exists) return const SizedBox.shrink();

                final data = snapshot.data!.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.business)),
                    title: Row(
                      children: [
                        Expanded(child: Text(data['raisonSociale'] ?? 'Entreprise inconnue', style: const TextStyle(fontWeight: FontWeight.bold))),
                        if (data['isVerified'] == true) 
                          const Icon(Icons.verified, color: AppColors.primary, size: 16),
                      ],
                    ),
                    subtitle: Text('Note: ${data['noteMoyenne'] ?? 'N/A'} • Exp: ${data['anneesExperience'] ?? 0} ans'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Confirmer l'entreprise
                        _accepterEntreprise(context, ref, entrepriseId);
                      },
                      child: const Text('Choisir'),
                    ),
                  ),
                );
              }
            );
          }),
          const Divider(height: 32),

        ],
        if (devisList.isNotEmpty) ...[
          Text('Devis détaillés', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          ...devisList.map((devis) {
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
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 4),
                    Text('Délai estimé: ${devis.delaiEstime}', style: const TextStyle(color: AppColors.textSecondaryLight)),
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
          }),
        ],
        
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('diffusions_projet')
              .where('projectId', isEqualTo: project.id)
              .where('statut', isEqualTo: 'envoye')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('En attente de réponse', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight)),
                const SizedBox(height: AppSpacing.md),
                ...snapshot.data!.docs.map((doc) {
                  final entrepriseId = doc['entrepriseId'];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('entreprises').doc(entrepriseId).get(),
                    builder: (context, entSnapshot) {
                      if (!entSnapshot.hasData || !entSnapshot.data!.exists) return const SizedBox.shrink();
                      final data = entSnapshot.data!.data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(Icons.hourglass_empty, color: AppColors.textSecondaryLight),
                        title: Text(data['raisonSociale'] ?? 'Entreprise', style: const TextStyle(color: AppColors.textSecondaryLight)),
                      );
                    }
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _accepterEntreprise(BuildContext context, WidgetRef ref, String entrepriseId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
      
      await FirebaseFirestore.instance.collection('projects').doc(project.id).update({
        'entrepriseId': entrepriseId,
        'statut': 'en_cours',
      });
      
      if (context.mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entreprise choisie !')));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'accepte':
        return AppColors.success;
      case 'refuse':
        return AppColors.error;
      case 'en_attente':
      default:
        return AppColors.warning;
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
