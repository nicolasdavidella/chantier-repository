import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/features/admin/providers/admin_providers.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class ActivityLogsScreen extends ConsumerWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(activityLogsStreamProvider);
    final dateFormatter = DateFormat('dd MMM yyyy HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal d\'Activité'),
        centerTitle: false,
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text("Aucune activité enregistrée."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                leading: const Icon(Icons.history, color: AppColors.textSecondaryLight),
                title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Par ${log.user} - ${dateFormatter.format(log.timestamp)}'),
              );
            },
          );
        },
      ),
    );
  }
}
