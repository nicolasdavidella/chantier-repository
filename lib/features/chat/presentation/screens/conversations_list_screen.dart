import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/chat_providers.dart';
import '../../../auth/providers/auth_provider.dart';
import 'chat_detail_screen.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsStreamProvider);
    final timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF143D2B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messagerie & Échanges',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Background ambient glow
          Positioned(
            top: -40,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8F5E9).withValues(alpha: 0.8),
                    const Color(0xFFE8F5E9).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          conversationsAsync.when(
            data: (conversations) {
              final user = ref.read(authStateProvider).value;
              final currentUserId = user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

              final validConversations = conversations.where((conv) {
                final names = conv.participantNames.values.map((n) => n.toLowerCase().trim()).toList();
                for (final name in names) {
                  if (name.contains('bitcam') ||
                      name.contains('baticam') ||
                      name.contains('electricit') ||
                      name.contains('électricité') ||
                      name.contains('bois et toit') ||
                      name.contains('renove plus') ||
                      name.contains('rénove plus')) {
                    return false;
                  }
                }
                return true;
              }).toList();

              if (validConversations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chat_bubble_outline_rounded, size: 54, color: Color(0xFF143D2B)),
                      ),
                      AppSpacing.vMd,
                      const Text(
                        'Aucune conversation',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF143D2B)),
                      ),
                      AppSpacing.vXs,
                      const Text(
                        'Vos échanges avec les entreprises apparaîtront ici.',
                        style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: validConversations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final conv = validConversations[index];
                  final otherUserId = conv.participantsIds.firstWhere((id) => id != currentUserId, orElse: () => '');
                  String otherUserName = conv.participantNames[otherUserId] ?? '';
                  if (otherUserName.isEmpty) {
                    for (final entry in conv.participantNames.entries) {
                      if (entry.key != currentUserId && entry.value.trim().isNotEmpty) {
                        otherUserName = entry.value.trim();
                        break;
                      }
                    }
                  }
                  if (otherUserName.isEmpty) {
                    otherUserName = 'Interlocuteur';
                  }
                  final otherUserAvatar = conv.participantAvatars[otherUserId];
                  final unreadCount = conv.unreadCount[currentUserId] ?? 0;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: unreadCount > 0 ? const Color(0xFF10B981) : const Color(0xFFC8E6C9),
                        width: unreadCount > 0 ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF143D2B).withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF143D2B),
                        backgroundImage: otherUserAvatar != null ? NetworkImage(otherUserAvatar) : null,
                        child: otherUserAvatar == null
                            ? Text(
                                otherUserName[0].toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF86EFAC)),
                              )
                            : null,
                      ),
                      title: Text(
                        otherUserName,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF143D2B)),
                      ),
                      subtitle: Text(
                        conv.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: unreadCount > 0 ? const Color(0xFF143D2B) : AppColors.textSecondaryLight,
                          fontWeight: unreadCount > 0 ? FontWeight.w800 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeFormatter.format(conv.lastMessageTime),
                            style: TextStyle(
                              fontSize: 11,
                              color: unreadCount > 0 ? const Color(0xFF10B981) : AppColors.textSecondaryLight,
                              fontWeight: unreadCount > 0 ? FontWeight.w900 : FontWeight.w500,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 500.ms),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF143D2B))),
            error: (err, stack) => Center(child: Text('Erreur: $err')),
          ),
        ],
      ),
    );
  }
}
