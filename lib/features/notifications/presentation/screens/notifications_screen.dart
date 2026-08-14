import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/notification_model.dart';
import '../../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final theme = Theme.of(context);

    // Group notifications by date category
    final grouped = _groupNotifications(notifications);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.any((n) => !n.lu))
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text('Tout marquer comme lu'),
            ),
        ],
      ),
      body: grouped.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
                  AppSpacing.vMd,
                  Text('Aucune notification', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            )
          : CustomScrollView(
              slivers: grouped.entries.map((entry) {
                return SliverMainAxisGroup(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: false,
                      delegate: _HeaderDelegate(entry.key, theme),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final notif = entry.value[index];
                          return _buildNotificationItem(context, ref, notif, theme).animate().fadeIn().slideX();
                        },
                        childCount: entry.value.length,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Map<String, List<NotificationModel>> _groupNotifications(List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    // Sort by date descending first
    final sorted = List<NotificationModel>.from(notifications)..sort((a, b) => b.dateEnvoi.compareTo(a.dateEnvoi));

    for (var n in sorted) {
      final notifDate = DateTime(n.dateEnvoi.year, n.dateEnvoi.month, n.dateEnvoi.day);
      
      String category = '';
      if (notifDate == today) {
        category = "Aujourd'hui";
      } else if (notifDate == yesterday) {
        category = 'Hier';
      } else if (notifDate.isAfter(startOfWeek) || notifDate == startOfWeek) {
        category = 'Cette semaine';
      } else {
        category = 'Plus ancien';
      }

      if (!grouped.containsKey(category)) grouped[category] = [];
      grouped[category]!.add(n);
    }

    return grouped;
  }

  Widget _buildNotificationItem(BuildContext context, WidgetRef ref, NotificationModel notif, ThemeData theme) {
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case 'alerte_ia':
        icon = Icons.warning_rounded;
        iconColor = Colors.red;
        break;
      case 'message':
        icon = Icons.chat_bubble_outline;
        iconColor = Colors.blue;
        break;
      case 'statut_devis':
        icon = Icons.request_quote;
        iconColor = Colors.orange;
        break;
      case 'rapport':
        icon = Icons.assignment;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        iconColor = theme.colorScheme.primary;
    }

    final timeFormatter = DateFormat('HH:mm');

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(notificationsProvider.notifier).dismissNotification(notif.id);
      },
      child: ListTile(
        onTap: () {
          if (!notif.lu) {
            ref.read(notificationsProvider.notifier).markAsRead(notif.id);
          }
          // Normally would navigate to the relevant screen based on notif.type and notif.referenceId
        },
        tileColor: notif.lu ? null : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          notif.titre,
          style: TextStyle(fontWeight: notif.lu ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.vXs,
            Text(notif.corps, style: TextStyle(color: notif.lu ? Colors.grey : theme.colorScheme.onSurface)),
            AppSpacing.vXs,
            Text(timeFormatter.format(notif.dateEnvoi), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final ThemeData theme;

  _HeaderDelegate(this.title, this.theme);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
      ),
    );
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
