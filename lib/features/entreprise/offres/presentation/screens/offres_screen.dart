import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/data/models/project_model.dart';
import 'package:chantier_track/features/entreprise/offres/providers/offres_provider.dart';

class OffresScreen extends ConsumerWidget {
  const OffresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final offresAsync = ref.watch(offresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appels d\'Offres'),
      ),
      body: offresAsync.when(
        data: (projets) {
          if (projets.isEmpty) {
            return _buildEmptyState(theme);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: projets.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) {
              final projet = projets[index];
              return _buildOffreCard(context, theme, projet);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Aucun appel d\'offres pour le moment',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Revenez plus tard pour découvrir de nouveaux projets.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOffreCard(BuildContext context, ThemeData theme, ProjectModel projet) {
    return InkWell(
      onTap: () {
        context.push('/entreprise/offres/detail', extra: projet);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    projet.titre,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Nouveau',
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.locationDot, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${projet.localisation['ville'] ?? ''}, ${projet.localisation['quartier'] ?? ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.wallet, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${projet.budgetPrevisionnel.toStringAsFixed(0)} FCFA',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              projet.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/entreprise/offres/detail', extra: projet);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Voir les détails'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
