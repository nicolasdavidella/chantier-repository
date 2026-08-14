import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/notification_providers.dart';
import '../screens/notifications_screen.dart';

class NotificationBadge extends ConsumerWidget {
  final Color? iconColor;

  const NotificationBadge({super.key, this.iconColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: iconColor),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 800.ms),
          ),
      ],
    );
  }
}
