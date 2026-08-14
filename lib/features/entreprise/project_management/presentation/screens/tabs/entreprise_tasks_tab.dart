import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_spacing.dart';

// Placeholder mock data provider
final mockTasksProvider = Provider((ref) => [
  {'id': '1', 'titre': 'Fondations', 'completed': true},
  {'id': '2', 'titre': 'Murs', 'completed': false},
  {'id': '3', 'titre': 'Toiture', 'completed': false},
]);

class EntrepriseTasksTab extends ConsumerStatefulWidget {
  final String projectId;
  const EntrepriseTasksTab({super.key, required this.projectId});

  @override
  ConsumerState<EntrepriseTasksTab> createState() => _EntrepriseTasksTabState();
}

class _EntrepriseTasksTabState extends ConsumerState<EntrepriseTasksTab> {
  // Temporary state for UI testing
  final Map<String, bool> _localTaskState = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(mockTasksProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: tasks.length + 1,
      separatorBuilder: (_, __) => AppSpacing.vSm,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              'Cochez les tâches terminées pour mettre à jour l\'avancement :',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }
        
        final task = tasks[index - 1];
        final id = task['id'] as String;
        final title = task['titre'] as String;
        final initialCompleted = task['completed'] as bool;
        final isCompleted = _localTaskState[id] ?? initialCompleted;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: CheckboxListTile(
            title: Text(
              title,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
                fontWeight: isCompleted ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            value: isCompleted,
            activeColor: theme.colorScheme.primary,
            onChanged: (val) {
              setState(() {
                _localTaskState[id] = val ?? false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tâche "$title" mise à jour')),
              );
            },
          ),
        );
      },
    );
  }
}
