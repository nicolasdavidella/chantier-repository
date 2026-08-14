import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/conversation_model.dart';
import '../../../../data/models/message_model.dart';
import '../../auth/providers/auth_provider.dart';

// --- Mock Data ---
final _mockConversations = [
  ConversationModel(
    id: 'conv_1',
    participantsIds: ['u_current', 'u_2'],
    participantNames: {'u_current': 'Moi', 'u_2': 'BatiPlus SARL'},
    participantAvatars: {'u_current': null, 'u_2': 'https://images.unsplash.com/photo-1541888081622-1db116fb837a?w=100&q=80'},
    projectId: 'proj_1',
    lastMessage: 'Bonjour, avez-vous reçu les plans modifiés ?',
    lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: {'u_current': 2},
  ),
  ConversationModel(
    id: 'conv_2',
    participantsIds: ['u_current', 'u_3'],
    participantNames: {'u_current': 'Moi', 'u_3': 'Paul (Chef de chantier)'},
    participantAvatars: {'u_current': null, 'u_3': null},
    projectId: 'proj_2',
    lastMessage: 'Le matériel a été livré sur le chantier.',
    lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: {'u_current': 0},
  ),
];

final Map<String, List<MessageModel>> _mockMessages = {
  'conv_1': [
    MessageModel(
      id: 'm1',
      conversationId: 'conv_1',
      expediteurId: 'u_current',
      contenu: 'Bonjour BatiPlus, je vous ai envoyé les nouveaux plans.',
      dateEnvoi: DateTime.now().subtract(const Duration(days: 1)),
      type: 'texte',
      status: 'read',
      lu: true,
    ),
    MessageModel(
      id: 'm2',
      conversationId: 'conv_1',
      expediteurId: 'u_2',
      contenu: 'Bonjour, avez-vous reçu les plans modifiés ?',
      dateEnvoi: DateTime.now().subtract(const Duration(minutes: 5)),
      type: 'texte',
      status: 'sent',
      lu: false,
    ),
  ],
  'conv_2': [
    MessageModel(
      id: 'm3',
      conversationId: 'conv_2',
      expediteurId: 'u_3',
      contenu: 'Le matériel a été livré sur le chantier.',
      dateEnvoi: DateTime.now().subtract(const Duration(days: 1)),
      type: 'texte',
      status: 'read',
      lu: true,
    ),
  ]
};

// --- Providers ---

class ChatMockService {
  final _conversationsController = StreamController<List<ConversationModel>>.broadcast();
  final Map<String, StreamController<List<MessageModel>>> _messagesControllers = {};
  
  ChatMockService() {
    // Initial emit
    Future.delayed(const Duration(milliseconds: 100), () {
      _conversationsController.add(List.from(_mockConversations));
    });
  }

  Stream<List<ConversationModel>> get conversationsStream => _conversationsController.stream;

  Stream<List<MessageModel>> messagesStream(String conversationId) {
    if (!_messagesControllers.containsKey(conversationId)) {
      _messagesControllers[conversationId] = StreamController<List<MessageModel>>.broadcast();
      Future.delayed(const Duration(milliseconds: 100), () {
        _messagesControllers[conversationId]?.add(List.from(_mockMessages[conversationId] ?? []));
      });
    }
    return _messagesControllers[conversationId]!.stream;
  }

  void sendMessage(String conversationId, String content, String senderId, {String type = 'texte'}) {
    final messages = _mockMessages[conversationId] ?? [];
    
    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      expediteurId: senderId,
      contenu: content,
      dateEnvoi: DateTime.now(),
      type: type,
      status: 'sent',
      lu: false,
    );

    messages.add(newMessage);
    _mockMessages[conversationId] = messages;
    
    // Update conversation last message
    final convIndex = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      _mockConversations[convIndex] = _mockConversations[convIndex].copyWith(
        lastMessage: type == 'image' ? '📷 Image' : content,
        lastMessageTime: DateTime.now(),
      );
      _conversationsController.add(List.from(_mockConversations));
    }

    _messagesControllers[conversationId]?.add(List.from(messages));

    // Simulate network delay and read receipt
    Future.delayed(const Duration(seconds: 1), () {
      final index = messages.indexWhere((m) => m.id == newMessage.id);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'delivered');
        _messagesControllers[conversationId]?.add(List.from(messages));
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      final index = messages.indexWhere((m) => m.id == newMessage.id);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'read');
        _messagesControllers[conversationId]?.add(List.from(messages));
      }
      
      // Simulate auto-reply if sent by me
      if (senderId == 'u_current') {
        _simulateAutoReply(conversationId);
      }
    });
  }

  void _simulateAutoReply(String conversationId) {
    final messages = _mockMessages[conversationId] ?? [];
    
    final reply = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      expediteurId: 'u_2', // Mock sender
      contenu: 'Message reçu ! Je traite ça rapidement.',
      dateEnvoi: DateTime.now(),
      type: 'texte',
      status: 'sent',
      lu: false,
    );
    messages.add(reply);
    _mockMessages[conversationId] = messages;
    _messagesControllers[conversationId]?.add(List.from(messages));
    
    final convIndex = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      final unread = Map<String, int>.from(_mockConversations[convIndex].unreadCount);
      unread['u_current'] = (unread['u_current'] ?? 0) + 1;
      _mockConversations[convIndex] = _mockConversations[convIndex].copyWith(
        lastMessage: reply.contenu,
        lastMessageTime: DateTime.now(),
        unreadCount: unread,
      );
      _conversationsController.add(List.from(_mockConversations));
    }
  }

  void markAsRead(String conversationId, String userId) {
    final convIndex = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      final unread = Map<String, int>.from(_mockConversations[convIndex].unreadCount);
      unread[userId] = 0;
      _mockConversations[convIndex] = _mockConversations[convIndex].copyWith(unreadCount: unread);
      _conversationsController.add(List.from(_mockConversations));
    }
  }
}

final chatServiceProvider = Provider((ref) => ChatMockService());

final conversationsStreamProvider = StreamProvider<List<ConversationModel>>((ref) {
  return ref.watch(chatServiceProvider).conversationsStream;
});

final messagesStreamProvider = StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return ref.watch(chatServiceProvider).messagesStream(conversationId);
});

// Simple typing indicator state
final typingStateProvider = StateProvider.family<bool, String>((ref, conversationId) => false);
