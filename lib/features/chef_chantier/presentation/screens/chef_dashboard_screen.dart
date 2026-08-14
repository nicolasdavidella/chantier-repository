import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/chef_chantier_providers.dart';
import 'add_report_screen.dart';
import 'add_expense_screen.dart';
import 'widgets/sync_queue_indicator.dart';
import '../../../../core/connectivity/sync_queue_provider.dart';

class ChefDashboardScreen extends ConsumerWidget {
  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final syncQueue = ref.watch(syncQueueProvider);
    final projects = ref.watch(chefProjectsProvider);
    final tasks = ref.watch(chefTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Chantiers'),
        actions: [
          if (syncQueue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Synchronisation manuelle déclenchée...')),
                  );
                  ref.read(syncQueueProvider.notifier).simulateSync();
                },
                child: Row(
                  children: [
                    const Icon(Icons.cloud_upload, color: Colors.orange),
                    AppSpacing.hXs,
                    Text('${syncQueue.length}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(duration: 1.seconds, begin: 0.5, end: 1),
              ),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: SyncQueueIndicator(),
          ),
          
          // Project Card
          if (projects.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (projects[0].listePlans.isNotEmpty)
                        Image.network(
                          projects[0].listePlans.first,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(projects[0].titre, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            AppSpacing.vXs,
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                AppSpacing.hXs,
                                Text('${projects[0].localisation['ville']} - ${projects[0].localisation['quartier']}', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.1, curve: Curves.easeOut).fadeIn(),
              ),
            ),

          // Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      title: 'Rapport',
                      icon: Icons.add_a_photo,
                      color: theme.colorScheme.primary,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AddReportScreen(projectId: projects[0].id)));
                      },
                    ),
                  ),
                  AppSpacing.hLg,
                  Expanded(
                    child: _buildActionButton(
                      context,
                      title: 'Dépense',
                      icon: Icons.receipt_long,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(projectId: projects[0].id)));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: AppSpacing.vXxl),
          
          // Tasks List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text('Tâches de la semaine', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ),
          
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = tasks[index];
                final isDone = task.statut == 'terminee';
                final isDoing = task.statut == 'en_cours';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: InkWell(
                    onTap: () => ref.read(chefTasksProvider.notifier).cycleTaskStatus(task.id),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: isDone ? Colors.green : (isDoing ? theme.colorScheme.primary : theme.colorScheme.outlineVariant)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDone ? Colors.green : (isDoing ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent),
                              border: Border.all(color: isDone ? Colors.green : (isDoing ? theme.colorScheme.primary : Colors.grey)),
                              shape: BoxShape.circle,
                            ),
                            child: isDone
                                ? const Icon(Icons.check, color: Colors.white, size: 20).animate().scale()
                                : (isDoing ? Icon(Icons.play_arrow, color: theme.colorScheme.primary, size: 20) : null),
                          ),
                          AppSpacing.hMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.titre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    color: isDone ? Colors.grey : null,
                                  ),
                                ),
                                AppSpacing.vXs,
                                Text(
                                  isDone ? 'Terminée' : (isDoing ? 'En cours' : 'À faire'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDone ? Colors.green : (isDoing ? theme.colorScheme.primary : Colors.grey),
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 100).ms),
                );
              },
              childCount: tasks.length,
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            AppSpacing.vSm,
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms);
  }
}
