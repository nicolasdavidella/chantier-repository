import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../providers/entreprise_dashboard_provider.dart';

class ProjectRequestsSection extends ConsumerWidget {
  const ProjectRequestsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final requests = ref.watch(projectRequestsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');

    if (requests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Demandes pertinentes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('Voir tout')),
          ],
        ),
        AppSpacing.vSm,
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: requests.length,
            separatorBuilder: (_, __) => AppSpacing.hMd,
            itemBuilder: (context, index) {
              final project = requests[index];

              return Container(
                width: 280,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.maps_home_work, color: theme.colorScheme.primary, size: 20),
                          ),
                          AppSpacing.hSm,
                          Expanded(
                            child: Text(
                              project.titre,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          AppSpacing.hXs,
                          Text('${project.localisation['ville']} - ${project.localisation['quartier']}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                        ],
                      ),
                      AppSpacing.vXs,
                      Text(
                        currencyFormatter.format(project.budgetPrevisionnel),
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture du formulaire de devis...')));
                          },
                          text: 'Postuler avec un devis',
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().slideX(begin: 0.2, curve: Curves.easeOut).fadeIn(delay: (index * 150).ms);
            },
          ),
        ),
      ],
    );
  }
}
