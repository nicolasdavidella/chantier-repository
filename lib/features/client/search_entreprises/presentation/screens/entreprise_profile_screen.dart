import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../data/models/entreprise_model.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../data/models/avis_model.dart';
import '../../../../reviews/presentation/widgets/review_card.dart';

class EntrepriseProfileScreen extends ConsumerWidget {
  final EntrepriseModel entreprise;

  const EntrepriseProfileScreen({super.key, required this.entreprise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'entreprise_cover_${entreprise.id}',
                child: entreprise.realisations.isNotEmpty
                    ? PageView.builder(
                        itemCount: entreprise.realisations.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: entreprise.realisations[index],
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) => const Icon(Icons.business),
                          );
                        },
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(child: Icon(Icons.business, size: 64, color: Colors.grey)),
                      ),
              ),
            ),
            actions: [
              if (entreprise.certifie)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Chip(
                    label: const Text('Certifié', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    backgroundColor: Colors.green,
                    side: BorderSide.none,
                    avatar: const Icon(Icons.verified, color: Colors.white, size: 16),
                  ),
                )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entreprise.raisonSociale,
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 28).animate().scale(delay: 200.ms),
                          AppSpacing.hXs,
                          Text(
                            entreprise.noteMoyenne.toString(),
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' (${entreprise.nombreAvis})',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppSpacing.vLg,
                  
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(context, Icons.work_history, '${entreprise.anneesExperience} ans', 'Expérience'),
                      _buildStatColumn(context, Icons.map, entreprise.zoneIntervention.join(', '), 'Zone'),
                      if (entreprise.prixMoyen != null)
                        _buildStatColumn(context, Icons.payments, entreprise.prixMoyen!, 'Prix moyen'),
                    ],
                  ).animate().fadeIn().slideY(begin: 0.2, curve: Curves.easeOut),
                  
                  AppSpacing.vXxl,
                  Text('À propos', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  AppSpacing.vSm,
                  Text(
                    entreprise.description,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                  ),
                  
                  AppSpacing.vXxl,
                  Text('Spécialités', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  AppSpacing.vSm,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entreprise.specialites.map((s) => Chip(
                      label: Text(s),
                      backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                      side: BorderSide.none,
                    )).toList(),
                  ),
                  
                  AppSpacing.vXxl,
                  Text('Derniers avis clients', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  AppSpacing.vLg,
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (context, index) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      return _buildReviewTile(context, index);
                    },
                  ),
                  AppSpacing.vXxl,
                  AppSpacing.vXxl,
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirection vers la création de devis...')),
              );
              // In a real flow, this would go to a quote request screen pre-filled with this enterprise ID.
            },
            text: 'Demander un devis',
            icon: Icons.request_quote,
          ).animate().slideY(begin: 1.0, curve: Curves.easeOutBack, duration: 500.ms),
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        AppSpacing.vXs,
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildReviewTile(BuildContext context, int index) {
    // Dans une vraie app, on ferait un ref.watch(entrepriseReviewsProvider(entreprise.id))
    final mockReviews = [
      AvisModel(
        id: '1', targetId: entreprise.id, targetType: 'entreprise', clientId: 'c1', projectId: 'p1',
        note: 5, criteres: {'qualite': 5, 'delais': 5},
        commentaire: 'Travail impeccable, délais respectés. Je recommande vivement.',
        dateCreation: DateTime.now().subtract(const Duration(days: 14)),
      ),
      AvisModel(
        id: '2', targetId: entreprise.id, targetType: 'entreprise', clientId: 'c2', projectId: 'p2',
        note: 4, criteres: {'qualite': 4, 'communication': 4},
        commentaire: 'Très bonne communication, l\'équipe est professionnelle.',
        dateCreation: DateTime.now().subtract(const Duration(days: 30)),
        reponseEntreprise: 'Merci pour votre confiance !',
      ),
      AvisModel(
        id: '3', targetId: entreprise.id, targetType: 'entreprise', clientId: 'c3', projectId: 'p3',
        note: 5, criteres: {'qualite': 5, 'prix': 5},
        commentaire: 'Le résultat dépasse nos attentes. Superbe finition.',
        dateCreation: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
    
    final review = mockReviews[index];

    return ReviewCard(
      avis: review,
      onReport: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avis signalé aux modérateurs.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
        );
      },
    );
  }
}
