import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_spacing.dart';

// Liste des phases inspirée de l'image (traduite en français)
final mockTasksProvider = Provider((ref) => [
  {'id': '1', 'titre': 'Études architecturales', 'completed': true},
  {'id': '2', 'titre': 'Design d\'intérieur', 'completed': false},
  {'id': '3', 'titre': 'Construction', 'completed': false},
  {'id': '4', 'titre': 'Améliorations de l\'habitat', 'completed': false},
  {'id': '5', 'titre': 'Rénovations', 'completed': false},
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planning de Construction',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Cochez les différentes phases pour mettre à jour l\'état d\'avancement du projet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: List.generate(tasks.length, (index) {
                  final task = tasks[index];
                  final id = task['id'] as String;
                  final title = task['titre'] as String;
                  final initialCompleted = task['completed'] as bool;
                  final isCompleted = _localTaskState[id] ?? initialCompleted;

                  return _buildChecklistItem(
                    context: context,
                    title: title,
                    isCompleted: isCompleted,
                    isLast: index == tasks.length - 1,
                    onTap: () {
                      setState(() {
                        _localTaskState[id] = !isCompleted;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Phase "$title" mise à jour')),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem({
    required BuildContext context,
    required String title,
    required bool isCompleted,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
          // Léger effet de fond pour les éléments terminés
          color: isCompleted 
              ? Colors.orange.withOpacity(0.05) 
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Icône de validation personnalisée inspirée de l'image (doré/orange)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFFF59E0B) : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? const Color(0xFFF59E0B) : theme.colorScheme.outline.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
                  color: isCompleted ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.8),
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: theme.colorScheme.onSurfaceVariant,
                ),
                child: Text(title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
