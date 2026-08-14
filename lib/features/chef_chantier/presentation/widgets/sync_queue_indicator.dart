import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/connectivity/sync_queue_provider.dart';
import '../../../../core/connectivity/connectivity_provider.dart';
import '../../../../core/theme/app_spacing.dart';

class SyncQueueIndicator extends ConsumerWidget {
  const SyncQueueIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(syncQueueProvider);
    final isOnlineAsync = ref.watch(connectivityProvider);
    final isOnline = isOnlineAsync.value ?? true;
    final theme = Theme.of(context);

    if (queue.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isOnline ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isOnline ? Colors.blue.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (isOnline)
            const Icon(Icons.sync, color: Colors.blue)
                .animate(onPlay: (c) => c.repeat())
                .rotate(duration: 2.seconds)
          else
            const Icon(Icons.cloud_off, color: Colors.orange),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${queue.length} action(s) en attente',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOnline ? Colors.blue[700] : Colors.orange[700],
                  ),
                ),
                Text(
                  isOnline ? 'Synchronisation en cours...' : 'En attente de connexion réseau',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOnline ? Colors.blue[600] : Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }
}
