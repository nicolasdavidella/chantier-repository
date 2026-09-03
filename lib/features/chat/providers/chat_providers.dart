import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/conversation_model.dart';
import '../../../../data/models/message_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final conversationsStreamProvider = StreamProvider<List<ConversationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(chatRepositoryProvider).getConversationsStream(user.uid);
});

final messagesStreamProvider = StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).getMessagesStream(conversationId);
});

// Simple typing indicator state
final typingStateProvider = StateProvider.family<bool, String>((ref, conversationId) => false);
