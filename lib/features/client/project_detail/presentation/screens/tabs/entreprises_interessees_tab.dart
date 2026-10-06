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
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
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
                          color: AppColors.primary.withValues(alpha: 0.1),
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
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
    final diffData = diffusionDoc.data() as Map<String, dynamic>;
    final entrepriseId = diffData['entrepriseId'] as String? ?? '';

    return FutureBuilder<Map<String, dynamic>?>(
      future: () async {
        // 1. Chercher dans 'entreprises' par ID direct
        final doc = await FirebaseFirestore.instance.collection('entreprises').doc(entrepriseId).get();
        if (doc.exists && doc.data() != null) return doc.data()!;

        // 2. Chercher dans 'entreprises' par userId
        final q = await FirebaseFirestore.instance.collection('entreprises').where('userId', isEqualTo: entrepriseId).limit(1).get();
        if (q.docs.isNotEmpty) return q.docs.first.data();

        // 3. Chercher dans 'users'
        final uDoc = await FirebaseFirestore.instance.collection('users').doc(entrepriseId).get();
        if (uDoc.exists && uDoc.data() != null) {
          final uData = uDoc.data()!;
          return {
            'raisonSociale': uData['raisonSociale'] ?? '${uData['prenom'] ?? ''} ${uData['nom'] ?? ''}'.trim(),
            'noteMoyenne': 5.0,
            'anneesExperience': 3,
            'certifie': uData['isVerified'] ?? false,
            'specialites': ['BTP', 'Construction'],
          };
        }

        return {
          'raisonSociale': diffData['nomEntreprise'] ?? 'Entreprise',
          'noteMoyenne': 5.0,
          'anneesExperience': 1,
          'specialites': ['BTP'],
        };
      }(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: ListTile(title: Text('Chargement...')));
        }
        final data = snapshot.data!;
        final nomEntreprise = (data['raisonSociale'] as String?)?.isNotEmpty == true
            ? data['raisonSociale'] as String
            : (diffData['nomEntreprise'] as String? ?? 'Entreprise');

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
                                  nomEntreprise,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (data['certifie'] == true) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppColors.warning,
                                  size: 16,
                                ),
                                Text(
                                  ' ${data['noteMoyenne'] ?? '5.0'} • ${data['anneesExperience'] ?? 1} ans d\'expérience',
                                ),
                              ],
                            ),
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
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Voir le profil complet (navigation)
                        },
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Voir le profil'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isChoosing
                            ? null
                            : () => _confirmChoice(
                                entrepriseId,
                                nomEntreprise,
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
                            : const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('Choisir cette entreprise'),
                              ),
                      ),
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
    final diffData = diffusionDoc.data() as Map<String, dynamic>;
    final entrepriseId = diffData['entrepriseId'] as String? ?? '';

    return FutureBuilder<String>(
      future: _getEntrepriseName(entrepriseId, diffData['nomEntreprise'] as String?),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'Entreprise sollicitée';
        return ListTile(
          leading: const Icon(Icons.hourglass_empty, color: AppColors.textSecondaryLight),
          title: Text(
            name,
            style: const TextStyle(color: AppColors.textSecondaryLight),
          ),
        );
      },
    );
  }

  Future<String> _getEntrepriseName(String entrepriseId, String? fallback) async {
    final doc = await FirebaseFirestore.instance.collection('entreprises').doc(entrepriseId).get();
    if (doc.exists && doc.data() != null && doc.data()?['raisonSociale'] != null) {
      return doc.data()!['raisonSociale'] as String;
    }
    final q = await FirebaseFirestore.instance.collection('entreprises').where('userId', isEqualTo: entrepriseId).limit(1).get();
    if (q.docs.isNotEmpty && q.docs.first.data()['raisonSociale'] != null) {
      return q.docs.first.data()['raisonSociale'] as String;
    }
    final uDoc = await FirebaseFirestore.instance.collection('users').doc(entrepriseId).get();
    if (uDoc.exists && uDoc.data() != null) {
      final uData = uDoc.data()!;
      final r = uData['raisonSociale'] as String?;
      if (r != null && r.trim().isNotEmpty) return r.trim();
      final fullName = '${uData['prenom'] ?? ''} ${uData['nom'] ?? ''}'.trim();
      if (fullName.isNotEmpty) return fullName;
    }
    return fallback ?? 'Entreprise';
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
              _choisirEntreprise(entrepriseId, nom);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _choisirEntreprise(String entrepriseId, String entrepriseNom) async {
    setState(() => _isChoosing = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final projectId = widget.project.id;
      final clientId = widget.project.clientId;

      String clientNom = "Client";
      try {
        final userDoc = await firestore.collection('users').doc(clientId).get();
        if (userDoc.exists && userDoc.data() != null) {
          final u = userDoc.data()!;
          final fullName = '${u['prenom'] ?? ''} ${u['nom'] ?? ''}'.trim();
          if (fullName.isNotEmpty) clientNom = fullName;
        }
      } catch (_) {}

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

        // 3. Créer une conversation de messagerie avec message initial
        final convRef = firestore.collection('conversations').doc();
        final firstMsgRef = convRef.collection('messages').doc();
        final initialContent = "Bonjour $entrepriseNom, nous sommes ravis de vous confier le projet \"${widget.project.titre}\". Nous pouvons échanger ici sur tous les détails et l'avancement du chantier.";

        transaction.set(convRef, {
          'id': convRef.id,
          'projectId': projectId,
          'participantsIds': [clientId, entrepriseId],
          'participantNames': {
            clientId: clientNom,
            entrepriseId: entrepriseNom,
          },
          'participantAvatars': {},
          'lastMessage': initialContent,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': {
            clientId: 0,
            entrepriseId: 1,
          },
        });

        transaction.set(firstMsgRef, {
          'id': firstMsgRef.id,
          'conversationId': convRef.id,
          'expediteurId': clientId,
          'contenu': initialContent,
          'dateEnvoi': FieldValue.serverTimestamp(),
          'type': 'texte',
          'status': 'sent',
          'lu': false,
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
