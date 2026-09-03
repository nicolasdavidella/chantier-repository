import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../data/models/entreprise_model.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../data/models/avis_model.dart';
import '../../../../reviews/presentation/widgets/review_card.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../../chat/providers/chat_providers.dart';
import '../../../../chat/presentation/screens/chat_detail_screen.dart';

class EntrepriseProfileScreen extends ConsumerWidget {
  final EntrepriseModel entreprise;

  const EntrepriseProfileScreen({super.key, required this.entreprise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Colors from the design
    const Color darkBlue = Color(0xFF0F2C59);
    const Color accentBlue = Color(0xFF1A5D98);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // New Hero Section based on the provided image
          SliverToBoxAdapter(
            child: _buildHeroSection(context, darkBlue, accentBlue),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reviews & Rating Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Avis & Statistiques',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: darkBlue),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 28).animate().scale(delay: 200.ms),
                          AppSpacing.hXs,
                          Text(
                            entreprise.noteMoyenne.toString(),
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: darkBlue),
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
                      _buildStatColumn(context, Icons.work_history, '${entreprise.anneesExperience} ans', 'Expérience', darkBlue),
                      _buildStatColumn(context, Icons.map, entreprise.zoneIntervention.isNotEmpty ? entreprise.zoneIntervention.first : 'N/A', 'Zone', darkBlue),
                      if (entreprise.prixMoyen != null)
                        _buildStatColumn(context, Icons.payments, entreprise.prixMoyen!, 'Prix moyen', darkBlue),
                    ],
                  ).animate().fadeIn().slideY(begin: 0.2, curve: Curves.easeOut),
                  
                  AppSpacing.vXxl,
                  Text('À propos de nous', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: darkBlue)),
                  AppSpacing.vSm,
                  Text(
                    entreprise.description,
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade800, height: 1.5),
                  ),
                  
                  AppSpacing.vXxl,
                  Text('Nos Spécialités', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: darkBlue)),
                  AppSpacing.vSm,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entreprise.specialites.map((s) => Chip(
                      label: Text(s, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      backgroundColor: accentBlue.withOpacity(0.8),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    )).toList(),
                  ),
                  
                  AppSpacing.vXxl,
                  Text('Derniers avis clients', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: darkBlue)),
                  AppSpacing.vLg,
                  ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
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
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: () async {
                    final user = ref.read(authStateProvider).value;
                    if (user == null) return;
                    
                    try {
                      // Call getOrCreateConversation
                      final conv = await ref.read(chatRepositoryProvider).getOrCreateConversation(
                        currentUserId: user.uid,
                        targetUserId: entreprise.id,
                        currentUserName: user.displayName ?? 'Client',
                        targetUserName: entreprise.raisonSociale,
                        currentUserAvatar: user.photoURL,
                        targetUserAvatar: null,
                      );
                      
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              conversationId: conv.id,
                              otherUserName: entreprise.raisonSociale,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                      }
                    }
                  },
                  text: 'Discuter',
                  icon: Icons.chat_bubble_outline,
                  isOutlined: true,
                ).animate().slideY(begin: 1.0, curve: Curves.easeOutBack, duration: 500.ms),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Redirection vers la création de devis...')),
                    );
                  },
                  text: 'Devis',
                  icon: Icons.request_quote,
                ).animate().slideY(begin: 1.0, curve: Curves.easeOutBack, duration: 600.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Color darkBlue, Color accentBlue) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Top AppBar equivalent
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: darkBlue),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (entreprise.certifie)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Certifié', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Logo and Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apartment, size: 32, color: darkBlue),
                const SizedBox(width: 12),
                Text(
                  entreprise.raisonSociale.toUpperCase(),
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Headline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: darkBlue,
                      height: 1.1,
                    ),
                    children: [
                      const TextSpan(text: 'La Précision\n'),
                      const TextSpan(text: 'est notre '),
                      TextSpan(
                        text: 'signature',
                        style: TextStyle(
                          color: accentBlue,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Chaque structure que nous réalisons est\nconçue avec rigueur, soin et un standard\nqui parle avant même que nous.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Human-centric Image (Construction workers)
          SizedBox(
            height: 280,
            width: double.infinity,
            child: CachedNetworkImage(
              // URL to a nice Unsplash image of real construction workers building a wall
              imageUrl: 'https://images.unsplash.com/photo-1504307651254-35680f356f12?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade200),
              errorWidget: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: const Icon(Icons.engineering, size: 64, color: Colors.grey)),
            ),
          ),
          
          // Contact Footer Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            color: darkBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildContactItem(Icons.phone, '+225 07 78 59 22 13'),
                Container(width: 1, height: 30, color: Colors.white30),
                _buildContactItem(Icons.email_outlined, '${entreprise.raisonSociale.toLowerCase().replaceAll(' ', '')}@contact.com'),
                Container(width: 1, height: 30, color: Colors.white30),
                _buildContactItem(Icons.language, 'www.${entreprise.raisonSociale.toLowerCase().replaceAll(' ', '')}.com'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, IconData icon, String value, String label, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        AppSpacing.vXs,
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
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
