import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/admin_providers.dart';

class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flaggedReviews = ref.watch(moderationProvider);
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('dd MMM yyyy à HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modération des avis'),
        centerTitle: false,
      ),
      body: flaggedReviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 64, color: Colors.green[300]),
                  AppSpacing.vMd,
                  Text('Aucun signalement en attente', style: theme.textTheme.titleMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: flaggedReviews.length,
              itemBuilder: (context, index) {
                final flag = flaggedReviews[index];
                final review = flag.review;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            AppSpacing.hSm,
                            Text('Signalé pour : ${flag.reason}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            const Spacer(),
                            Text(dateFormatter.format(flag.flaggedAt), style: theme.textTheme.bodySmall),
                          ],
                        ),
                        AppSpacing.vMd,
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(review.clientNom, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < review.note ? Icons.star : Icons.star_border,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.vXs,
                              Text(review.commentaire),
                            ],
                          ),
                        ),
                        AppSpacing.vLg,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                ref.read(moderationProvider.notifier).ignoreFlag(flag.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signalement ignoré')));
                              },
                              child: const Text('Ignorer'),
                            ),
                            AppSpacing.hMd,
                            FilledButton.icon(
                              onPressed: () {
                                ref.read(moderationProvider.notifier).deleteReview(flag.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avis supprimé')));
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Supprimer l\'avis'),
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
