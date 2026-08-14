import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/avis_model.dart';
import '../../../../core/theme/app_spacing.dart';

class ReviewCard extends StatelessWidget {
  final AvisModel avis;
  final VoidCallback? onReport;

  const ReviewCard({super.key, required this.avis, this.onReport});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat('dd MMM yyyy', 'fr_FR').format(avis.dateCreation);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: const Icon(Icons.person, size: 20),
                    ),
                    AppSpacing.hSm,
                    Text(
                      'Client', // Dans une vraie app, on fetch le nom via clientId
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (val) {
                    if (val == 'report' && onReport != null) {
                      onReport!();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Signaler comme abusif', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            
            AppSpacing.vSm,
            
            Row(
              children: [
                ...List.generate(5, (index) => Icon(
                  index < avis.note.round() ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                )),
                AppSpacing.hSm,
                Text(
                  dateFormatted,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            
            AppSpacing.vSm,
            
            if (avis.commentaire.isNotEmpty)
              Text(
                avis.commentaire,
                style: theme.textTheme.bodyMedium,
              ),

            if (avis.reponseEntreprise != null && avis.reponseEntreprise!.isNotEmpty) ...[
              AppSpacing.vMd,
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.reply, size: 16, color: Colors.grey),
                        AppSpacing.hXs,
                        Text('Réponse de l\'entreprise', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    AppSpacing.vXs,
                    Text(avis.reponseEntreprise!, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
