import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:chantier_track/data/models/project_model.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';

class EntreprisesInteresseesTab extends ConsumerStatefulWidget {
  final ProjectModel project;

  const EntreprisesInteresseesTab({super.key, required this.project});

  @override
  ConsumerState<EntreprisesInteresseesTab> createState() =>
      _EntreprisesInteresseesTabState();
}

class _EntreprisesInteresseesTabState
    extends ConsumerState<EntreprisesInteresseesTab> {
  bool _isExpanded = false;
  bool _isChoosing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('diffusions_projet')
          .where('projectId', isEqualTo: widget.project.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final diffusions = snapshot.data?.docs ?? [];
        final accepted = diffusions
            .where((d) => d['statut'] == 'accepte')
            .toList();
        final pending = diffusions
            .where((d) => d['statut'] == 'envoye')
            .toList();

        if (accepted.isEmpty && pending.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business_center_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Aucune entreprise n\'a encore été sollicitée',
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
            if (accepted.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Text(
                    'Aucune réponse pour le moment, nous vous prévenons dès qu\'une entreprise accepte.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Entreprises Intéressées',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...accepted.map((doc) => _buildEntrepriseCard(doc)),
            ],

            const Divider(height: 32),

            if (pending.isNotEmpty)
              ExpansionTile(
                title: Text(
                  'En attente de réponse (${pending.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: _isExpanded,
                onExpansionChanged: (val) => setState(() => _isExpanded = val),
                children: pending.map((doc) => _buildPendingTile(doc)).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEntrepriseCard(QueryDocumentSnapshot diffusionDoc) {
    final entrepriseId = diffusionDoc['entrepriseId'];

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('entreprises')
          .doc(entrepriseId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Card(child: ListTile(title: Text('Chargement...')));
        if (!snapshot.data!.exists) return const SizedBox.shrink();

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 24, child: Icon(Icons.business)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['raisonSociale'] ?? 'Entreprise',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (data['certifie'] == true)
                                const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              Text(
                                ' ${data['noteMoyenne'] ?? 'N/A'} • ${data['anneesExperience'] ?? 0} ans d\'expérience',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Spécialités : ${(data['specialites'] as List<dynamic>?)?.join(", ") ?? "Général"}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // Voir le profil complet (navigation)
                      },
                      child: const Text('Voir le profil'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isChoosing
                          ? null
                          : () => _confirmChoice(
                              entrepriseId,
                              data['raisonSociale'] ?? 'Cette entreprise',
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isChoosing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Choisir cette entreprise'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingTile(QueryDocumentSnapshot diffusionDoc) {
    final entrepriseId = diffusionDoc['entrepriseId'];
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('entreprises')
          .doc(entrepriseId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists)
          return const SizedBox.shrink();
        final data = snapshot.data!.data() as Map<String, dynamic>;
        return ListTile(
          leading: const Icon(Icons.hourglass_empty, color: Colors.grey),
          title: Text(
            data['raisonSociale'] ?? 'Entreprise',
            style: const TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }

  void _confirmChoice(String entrepriseId, String nom) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          'Voulez-vous vraiment confier votre projet à "$nom" ? Ce choix est irréversible et créera une conversation avec l\'entreprise.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _choisirEntreprise(entrepriseId);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _choisirEntreprise(String entrepriseId) async {
    setState(() => _isChoosing = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'choisirEntreprise',
      );
      await callable.call({
        'projectId': widget.project.id,
        'entrepriseId': entrepriseId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('L\'entreprise a été choisie avec succès !'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChoosing = false);
      }
    }
  }
}
