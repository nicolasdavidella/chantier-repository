import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/conversation_model.dart';
import '../../../../data/models/message_model.dart';
import '../../../../data/models/user_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantsIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final conversations = snapshot.docs.map((doc) => ConversationModel.fromJson(doc.data())).toList();
      // Tri local car on ne peut pas utiliser arrayContains + orderBy sans index
      conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return conversations;
    });
  }

  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('dateEnvoi', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromJson(doc.data())).toList();
    });
  }

  Future<void> sendMessage(String conversationId, String content, String senderId, {String type = 'texte'}) async {
    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    final message = MessageModel(
      id: messageRef.id,
      conversationId: conversationId,
      expediteurId: senderId,
      contenu: content,
      dateEnvoi: DateTime.now(),
      type: type,
      status: 'sent',
      lu: false,
    );

    // Run in a batch to update both message and conversation
    final batch = _firestore.batch();
    
    batch.set(messageRef, message.toJson());
    
    final convRef = _firestore.collection('conversations').doc(conversationId);
    // On met à jour le dernier message et on incrémente l'unreadCount pour l'autre participant
    // Comme on ne sait pas qui est l'autre sans le document, on utilise une transaction ou on lit la conv d'abord
    
    // Plutôt que de faire une transaction lourde pour un message, on va lire la conversation
    final convDoc = await convRef.get();
    if (convDoc.exists) {
      final conv = ConversationModel.fromJson(convDoc.data()!);
      final unreadCount = Map<String, int>.from(conv.unreadCount);
      
      for (final id in conv.participantsIds) {
        if (id != senderId) {
          unreadCount[id] = (unreadCount[id] ?? 0) + 1;
        }
      }

      batch.update(convRef, {
        'lastMessage': type == 'image' ? '📷 Image' : content,
        'lastMessageTime': Timestamp.now(),
        'unreadCount': unreadCount,
      });
    }

    await batch.commit();
  }

  Future<ConversationModel> getOrCreateConversation({
    required String currentUserId,
    required String targetUserId,
    required String currentUserName,
    required String targetUserName,
    String? currentUserAvatar,
    String? targetUserAvatar,
    String? projectId,
  }) async {
    // Check if conversation already exists between these two users
    final query = await _firestore
        .collection('conversations')
        .where('participantsIds', arrayContains: currentUserId)
        .get();

    for (final doc in query.docs) {
      final conv = ConversationModel.fromJson(doc.data());
      if (conv.participantsIds.contains(targetUserId)) {
        return conv;
      }
    }

    // Create new conversation
    final convRef = _firestore.collection('conversations').doc();
    final newConv = ConversationModel(
      id: convRef.id,
      participantsIds: [currentUserId, targetUserId],
      participantNames: {
        currentUserId: currentUserName,
        targetUserId: targetUserName,
      },
      participantAvatars: {
        currentUserId: currentUserAvatar,
        targetUserId: targetUserAvatar,
      },
      projectId: projectId,
      lastMessage: 'Nouvelle conversation',
      lastMessageTime: DateTime.now(),
      unreadCount: {
        currentUserId: 0,
        targetUserId: 0,
      },
    );

    await convRef.set(newConv.toJson());
    return newConv;
  }

  Future<void> markAsRead(String conversationId, String userId) async {
    final convRef = _firestore.collection('conversations').doc(conversationId);
    
    _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(convRef);
      if (snapshot.exists) {
        final conv = ConversationModel.fromJson(snapshot.data()!);
        if ((conv.unreadCount[userId] ?? 0) > 0) {
          final updatedUnreadCount = Map<String, int>.from(conv.unreadCount);
          updatedUnreadCount[userId] = 0;
          transaction.update(convRef, {'unreadCount': updatedUnreadCount});
        }
      }
    });

    // Optionnel: Mettre à jour le statut des messages à lu
    final messagesQuery = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('expediteurId', isNotEqualTo: userId)
        .where('lu', isEqualTo: false)
        .get();
        
    final batch = _firestore.batch();
    for (final doc in messagesQuery.docs) {
      batch.update(doc.reference, {'lu': true, 'status': 'read'});
    }
    await batch.commit();
  }
}
