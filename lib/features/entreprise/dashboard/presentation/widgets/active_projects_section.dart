import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/entreprise_dashboard_provider.dart';

class ActiveProjectsSection extends ConsumerWidget {
  const ActiveProjectsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projects = ref.watch(activeProjectsProvider);

    if (projects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mes chantiers en cours', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('Gérer')),
          ],
        ),
        AppSpacing.vSm,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projects.length,
          separatorBuilder: (_, __) => AppSpacing.vMd,
          itemBuilder: (context, index) {
            final project = projects[index];
            final progress = (project.budgetActuel / project.budgetPrevisionnel).clamp(0.0, 1.0);

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    project.listePlans.isNotEmpty ? project.listePlans.first : 'https://picsum.photos/seed/projet-actif/60/60',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(project.titre, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.vXs,
                    Text(project.localisation['ville'], style: theme.textTheme.bodySmall),
                    AppSpacing.vSm,
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: progress > 0.8 ? Colors.green : theme.colorScheme.primary,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        AppSpacing.hSm,
                        Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    // Navigate to project details.
                    context.push('/entreprise/project_detail', extra: project);
                  },
                ),
              ),
            ).animate().slideY(begin: 0.1, curve: Curves.easeOut).fadeIn(delay: (index * 100).ms);
          },
        ),
      ],
    );
  }
}
