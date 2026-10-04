import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../data/models/entreprise_model.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/search_entreprises_provider.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class EntrepriseCard extends ConsumerWidget {
  final EntrepriseModel entreprise;

  const EntrepriseCard({super.key, required this.entreprise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final comparisonList = ref.watch(comparisonListProvider);
    final isSelectedForCompare = comparisonList.contains(entreprise.id);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D2B).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/client/entreprise_profile', extra: entreprise),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image & Logo
            SizedBox(
              height: 130,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Hero(
                    tag: 'entreprise_cover_${entreprise.id}',
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFE8F5E9),
                      child: entreprise.realisations.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: entreprise.realisations.first,
                              fit: BoxFit.cover,
                              errorWidget: (c, e, s) => const Icon(Icons.business_rounded, color: Color(0xFF143D2B)),
                            )
                          : const Icon(Icons.business_center_rounded, size: 48, color: Color(0xFF143D2B)),
                    ),
                  ),
                  // Gradient overlay on cover
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black26, Colors.transparent, Colors.black45],
                        ),
                      ),
                    ),
                  ),
                  if (entreprise.isVerified)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '100% QUALITÉ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ).animate().scale(delay: 200.ms),
                    ),
                  Positioned(
                    bottom: -22,
                    left: 16,
                    child: Hero(
                      tag: 'entreprise_avatar_${entreprise.id}',
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF143D2B),
                          child: Text(
                            entreprise.raisonSociale.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Color(0xFF86EFAC), fontSize: 22, fontWeight: FontWeight.w900),
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
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF143D2B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              entreprise.noteMoyenne.toString(),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF92400E)),
                            ),
                            Text(
                              ' (${entreprise.nombreAvis})',
                              style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vXs,
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, size: 16, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        '${entreprise.anneesExperience} ans d\'expérience certifiée',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vMd,
                  // Specialites
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: entreprise.specialites.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF143D2B),
                        ),
                      ),
                    )).toList(),
                  ),
                  AppSpacing.vLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                entreprise.zoneIntervention.join(', '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondaryLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Comparer',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF143D2B),
                            ),
                          ),
                          Checkbox(
                            value: isSelectedForCompare,
                            activeColor: const Color(0xFF143D2B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
