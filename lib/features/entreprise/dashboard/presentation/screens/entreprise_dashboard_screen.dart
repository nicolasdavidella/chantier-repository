import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_badge.dart';

final diffusionsProvider = StreamProvider<List<QueryDocumentSnapshot>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  
  return FirebaseFirestore.instance
      .collection('diffusions_projet')
      .where('entrepriseId', isEqualTo: user.uid)
      .where('statut', isEqualTo: 'envoye') // pending ones
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

class EntrepriseDashboardScreen extends ConsumerWidget {
  const EntrepriseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final diffusionsAsync = ref.watch(diffusionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Entreprise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Projets reçus', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: diffusionsAsync.when(
                  data: (docs) {
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun nouveau projet pour le moment.',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        return _ProjectCard(diffusion: docs[index], ref: ref);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Erreur: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final QueryDocumentSnapshot diffusion;
  final WidgetRef ref;

  const _ProjectCard({required this.diffusion, required this.ref});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isLoading = false;
  String _message = '';

  Future<void> _repondre(String reponse) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final projectId = widget.diffusion['projectId'];
      final functions = FirebaseFunctions.instance;
      // In dev mode, ensure it points to the emulator (handled in main.dart)
      final callable = functions.httpsCallable('repondreProjet');
      
      await callable.call({
        'projectId': projectId,
        'reponse': reponse,
      });

      if (mounted) {
        setState(() {
          _message = reponse == 'accepte' ? 'Réponse envoyée' : 'Décliné';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reponse == 'accepte' ? 'Projet accepté !' : 'Projet décliné')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectId = widget.diffusion['projectId'];

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('projects').doc(projectId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (!snapshot.data!.exists) return const SizedBox.shrink();

        final projectData = snapshot.data!.data() as Map<String, dynamic>;
        
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
                    Expanded(
                      child: Text(
                        projectData['titre'] ?? 'Projet sans titre',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const AppBadge(label: 'Nouveau', status: AppBadgeStatus.inProgress),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${projectData['localisation']?['ville'] ?? ''}, ${projectData['localisation']?['quartier'] ?? ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${projectData['budgetPrevisionnel']} FCFA'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  projectData['description'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                if (_message.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_message, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => _repondre('decline'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(color: theme.colorScheme.error),
                          ),
                          child: const Text('Décliner'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _repondre('accepte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Je peux réaliser'),
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
}
