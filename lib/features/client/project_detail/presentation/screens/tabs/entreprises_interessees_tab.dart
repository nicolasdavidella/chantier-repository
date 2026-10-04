import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/project_model.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../widgets/devis_ia_simulator.dart';

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

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Bouton IA Simulator
            Card(
              elevation: 0,
              color: AppColors.primary.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: InkWell(
                onTap: () => DevisIASimulator.show(context, widget.project),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calculate_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Simuler une estimation de devis',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Text(
                              'Estimez le coût de votre projet instantanément',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            if (accepted.isEmpty && pending.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_center_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
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
                ),
              )
            else if (accepted.isEmpty) ...[
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

            if (pending.isNotEmpty || accepted.isNotEmpty)
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
        if (!snapshot.hasData) {
          return const Card(child: ListTile(title: Text('Chargement...')));
        }
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
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.warning,
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
                  style: TextStyle(color: AppColors.grey700),
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
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        return ListTile(
          leading: const Icon(Icons.hourglass_empty, color: AppColors.textSecondaryLight),
          title: Text(
            data['raisonSociale'] ?? 'Entreprise',
            style: const TextStyle(color: AppColors.textSecondaryLight),
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
      final firestore = FirebaseFirestore.instance;
      final projectId = widget.project.id;
      final clientId = widget.project.clientId;

      await firestore.runTransaction((transaction) async {
        final projectRef = firestore.collection('projects').doc(projectId);
        final projectDoc = await transaction.get(projectRef);

        if (!projectDoc.exists || projectDoc.data()?['statut'] != 'en_recherche_entreprise') {
          throw Exception("Ce projet n'est plus disponible pour l'attribution.");
        }

        // 1. Mettre à jour le projet
        transaction.update(projectRef, {
          'statut': 'en_cours',
          'entrepriseId': entrepriseId,
          'dateAttribution': FieldValue.serverTimestamp(),
        });

        // 2. Récupérer toutes les diffusions de ce projet
        final diffusionsQuery = await firestore
            .collection('diffusions_projet')
            .where('projectId', isEqualTo: projectId)
            .get();

        for (final diffDoc in diffusionsQuery.docs) {
          final diffData = diffDoc.data();
          final isChosen = diffData['entrepriseId'] == entrepriseId;
          
          // Mettre à jour le statut de la diffusion
          transaction.update(diffDoc.reference, {
            'statut': isChosen ? 'attribue' : 'rejete',
          });

          // Notifier l'entreprise
          final notifRef = firestore.collection('notifications').doc();
          transaction.set(notifRef, {
            'userId': diffData['entrepriseId'],
            'titre': isChosen ? "Projet attribué ! 🎉" : "Projet attribué à une autre entreprise",
            'message': isChosen 
                ? "Félicitations, le client vous a choisi pour le projet ${widget.project.titre} !"
                : "Le projet ${widget.project.titre} a été confié à une autre entreprise.",
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // 3. Créer une conversation de messagerie
        // Vérifier s'il existe déjà une conversation (optionnel, on va juste en créer une)
        final convRef = firestore.collection('conversations').doc();
        transaction.set(convRef, {
          'id': convRef.id,
          'projectId': projectId,
          'participantsIds': [clientId, entrepriseId],
          'participantNames': {
            clientId: "Client", // Simplification
            entrepriseId: "Entreprise", // Simplification
          },
          'participantAvatars': {},
          'lastMessage': "Conversation créée suite à l'attribution du projet",
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': {
            clientId: 0,
            entrepriseId: 0,
          },
        });
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
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChoosing = false);
      }
    }
  }
}
