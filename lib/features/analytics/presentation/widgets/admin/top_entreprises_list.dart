import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/analytics_provider.dart';
import '../../../../../core/theme/app_spacing.dart';

class TopEntreprisesList extends ConsumerWidget {
  const TopEntreprisesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(adminTopEntreprisesProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meilleures Entreprises', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.vLg,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final ent = data[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(ent['avatar'], style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                ),
                title: Text(ent['nom'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${ent['projets']} projets réalisés'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(ent['note'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
            },
          ),
        ],
      ),
    );
  }
}
