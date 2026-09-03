import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/chat_providers.dart';
import '../../auth/providers/auth_provider.dart';
import 'chat_detail_screen.dart';

class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsStreamProvider);
    final theme = Theme.of(context);
    final timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
        centerTitle: false,
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(child: Text('Aucune conversation.'));
          }
          final user = ref.read(authStateProvider).value;
          final currentUserId = user?.uid ?? '';

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              // Find the other participant's name
              final otherUserId = conv.participantsIds.firstWhere((id) => id != currentUserId, orElse: () => '');
              final otherUserName = conv.participantNames[otherUserId] ?? 'Inconnu';
              final otherUserAvatar = conv.participantAvatars[otherUserId];
              final unreadCount = conv.unreadCount[currentUserId] ?? 0;

              return ListTile(
                onTap: () {
                  ref.read(chatRepositoryProvider).markAsRead(conv.id, currentUserId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        conversationId: conv.id,
                        otherUserName: otherUserName,
                      ),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: otherUserAvatar != null ? NetworkImage(otherUserAvatar) : null,
                  child: otherUserAvatar == null ? Text(otherUserName[0].toUpperCase()) : null,
                ),
                title: Text(otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  conv.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: unreadCount > 0 ? theme.colorScheme.onSurface : Colors.grey,
                    fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeFormatter.format(conv.lastMessageTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: unreadCount > 0 ? theme.colorScheme.primary : Colors.grey,
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      AppSpacing.vXs,
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 500.ms),
                    ]
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
