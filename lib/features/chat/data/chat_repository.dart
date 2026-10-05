import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/conversation_model.dart';
import '../../../../data/models/message_model.dart';

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
      final conversations = snapshot.docs
          .map((doc) => ConversationModel.fromJson(doc.data(), docId: doc.id))
          .toList();
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
      return snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    });
  }

  Future<void> sendMessage(String conversationId, String content, String senderId, {String type = 'texte', Map<String, dynamic>? metadata}) async {
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
      metadata: metadata,
    );

    // Run in a batch to update both message and conversation
    final batch = _firestore.batch();
    
    batch.set(messageRef, message.toJson());
    
    final convRef = _firestore.collection('conversations').doc(conversationId);
    
    final convDoc = await convRef.get();
    if (convDoc.exists && convDoc.data() != null) {
      final conv = ConversationModel.fromJson(convDoc.data()!, docId: convDoc.id);
      final unreadCount = Map<String, int>.from(conv.unreadCount);
      
      for (final id in conv.participantsIds) {
        if (id != senderId) {
          unreadCount[id] = (unreadCount[id] ?? 0) + 1;
        }
      }

      batch.update(convRef, {
        'lastMessage': type == 'image' ? '📷 Image' : (type == 'pdf' ? '📄 Document PDF' : content),
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
    String? initialContextMessage,
  }) async {
    // 1. Chercher si une conversation existe déjà entre ces deux utilisateurs
    try {
      final query = await _firestore
          .collection('conversations')
          .where('participantsIds', arrayContains: currentUserId)
          .get();

      for (final doc in query.docs) {
        if (!doc.exists || doc.data().isEmpty) continue;
        final conv = ConversationModel.fromJson(doc.data(), docId: doc.id);
        if (conv.participantsIds.contains(targetUserId)) {
          // Mettre à jour les noms des participants si manquants ou génériques
          final names = Map<String, String>.from(conv.participantNames);
          bool needsUpdate = false;
          if (currentUserName.isNotEmpty && names[currentUserId] != currentUserName) {
            names[currentUserId] = currentUserName;
            needsUpdate = true;
          }
          if (targetUserName.isNotEmpty && names[targetUserId] != targetUserName) {
            names[targetUserId] = targetUserName;
            needsUpdate = true;
          }
          if (needsUpdate) {
            await _firestore.collection('conversations').doc(conv.id).update({'participantNames': names});
          }
          return conv.copyWith(participantNames: names);
        }
      }
    } catch (_) {}

    // 2. Créer une nouvelle conversation avec message initial contenant les besoins
    final convRef = _firestore.collection('conversations').doc();
    final firstMessage = (initialContextMessage != null && initialContextMessage.isNotEmpty)
        ? initialContextMessage
        : 'Nouvelle conversation';

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
      lastMessage: firstMessage,
      lastMessageTime: DateTime.now(),
      unreadCount: {
        currentUserId: 0,
        targetUserId: initialContextMessage != null ? 1 : 0,
      },
    );

    final batch = _firestore.batch();
    batch.set(convRef, newConv.toJson());

    // Si un message initial est spécifié, l'insérer dans la sous-collection messages
    if (initialContextMessage != null && initialContextMessage.isNotEmpty) {
      final messageRef = convRef.collection('messages').doc();
      final msg = MessageModel(
        id: messageRef.id,
        conversationId: convRef.id,
        expediteurId: currentUserId,
        contenu: initialContextMessage,
        dateEnvoi: DateTime.now(),
        type: 'texte',
        status: 'sent',
        lu: false,
      );
      batch.set(messageRef, msg.toJson());
    }

    await batch.commit();
    return newConv;
  }

  Future<void> markAsRead(String conversationId, String userId) async {
    final convRef = _firestore.collection('conversations').doc(conversationId);
    
    _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(convRef);
      if (snapshot.exists && snapshot.data() != null) {
        final conv = ConversationModel.fromJson(snapshot.data()!, docId: snapshot.id);
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
