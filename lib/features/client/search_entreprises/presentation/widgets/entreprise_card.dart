import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../data/models/entreprise_model.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/search_entreprises_provider.dart';

class EntrepriseCard extends ConsumerWidget {
  final EntrepriseModel entreprise;

  const EntrepriseCard({super.key, required this.entreprise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final comparisonList = ref.watch(comparisonListProvider);
    final isSelectedForCompare = comparisonList.contains(entreprise.id);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      child: InkWell(
        onTap: () => context.push('/client/entreprise_profile', extra: entreprise),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image & Logo
            SizedBox(
              height: 120,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Hero(
                    tag: 'entreprise_cover_${entreprise.id}',
                    child: Container(
                      width: double.infinity,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: entreprise.realisations.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: entreprise.realisations.first,
                              fit: BoxFit.cover,
                              errorWidget: (c, e, s) => const Icon(Icons.business),
                            )
                          : const Icon(Icons.business_center, size: 48, color: Colors.grey),
                    ),
                  ),
                  if (entreprise.certifie)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Certifié', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ).animate().scale(delay: 200.ms),
                    ),
                  Positioned(
                    bottom: -20,
                    left: 16,
                    child: Hero(
                      tag: 'entreprise_avatar_${entreprise.id}',
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        child: CircleAvatar(
                          radius: 27,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Text(
                            entreprise.raisonSociale.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: theme.colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entreprise.raisonSociale,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20).animate().scale(delay: 300.ms),
                          const SizedBox(width: 4),
                          Text(
                            entreprise.noteMoyenne.toString(),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' (${entreprise.nombreAvis})',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppSpacing.vXs,
                  Text(
                    '${entreprise.anneesExperience} ans d\'expérience',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                  ),
                  AppSpacing.vMd,
                  // Specialites
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: entreprise.specialites.map((s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      side: BorderSide.none,
                    )).toList(),
                  ),
                  AppSpacing.vLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            entreprise.zoneIntervention.join(', '),
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Comparer', style: theme.textTheme.bodySmall),
                          Checkbox(
                            value: isSelectedForCompare,
                            onChanged: (val) {
                              final success = ref.read(comparisonListProvider.notifier).toggle(entreprise.id);
                              if (!success && val == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vous ne pouvez comparer que 3 entreprises maximum.')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
