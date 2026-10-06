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
      final conversations = <ConversationModel>[];
      for (final doc in snapshot.docs) {
        final conv = ConversationModel.fromJson(doc.data(), docId: doc.id);
        if (_isFictiveConversation(conv)) {
          // Supprimer automatiquement la conversation fictive de Firestore
          _deleteConversationQuietly(doc.reference);
        } else {
          conversations.add(conv);
        }
      }
      // Tri local car on ne peut pas utiliser arrayContains + orderBy sans index
      conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return conversations;
    });
  }

  bool _isFictiveConversation(ConversationModel conv) {
    final names = conv.participantNames.values.map((n) => n.toLowerCase().trim()).toList();
    for (final name in names) {
      if (name.contains('bitcam') ||
          name.contains('baticam') ||
          name.contains('electricit') ||
          name.contains('électricité') ||
          name.contains('bois et toit') ||
          name.contains('renove plus') ||
          name.contains('rénove plus')) {
        return true;
      }
    }
    return false;
  }

  void _deleteConversationQuietly(DocumentReference docRef) {
    docRef.collection('messages').get().then((msgsSnapshot) {
      final batch = _firestore.batch();
      for (final mDoc in msgsSnapshot.docs) {
        batch.delete(mDoc.reference);
      }
      batch.delete(docRef);
      return batch.commit();
    }).catchError((_) {
      docRef.delete().catchError((_) {});
    });
  }

  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    _ensureConversationMessagesExist(conversationId);

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      final messages = <MessageModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          messages.add(MessageModel.fromJson(data, docId: doc.id));
        } catch (_) {}
      }
      messages.sort((a, b) => a.dateEnvoi.compareTo(b.dateEnvoi));
      return messages;
    });
  }

  Future<void> _ensureConversationMessagesExist(String conversationId) async {
    try {
      final msgs = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .limit(1)
          .get();
      if (msgs.docs.isEmpty) {
        final convDoc = await _firestore.collection('conversations').doc(conversationId).get();
        if (convDoc.exists && convDoc.data() != null) {
          final data = convDoc.data()!;
          final lastMsg = data['lastMessage']?.toString() ?? '';
          final participants = (data['participantsIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
          final firstSenderId = participants.isNotEmpty ? participants.first : 'system';
          
          final content = lastMsg.trim().isNotEmpty
              ? lastMsg.trim()
              : 'Bonjour, échangeons concernant votre chantier !';
              
          final newMsgRef = _firestore.collection('conversations').doc(conversationId).collection('messages').doc();
          await newMsgRef.set({
            'id': newMsgRef.id,
            'conversationId': conversationId,
            'expediteurId': firstSenderId,
            'contenu': content,
            'dateEnvoi': data['lastMessageTime'] ?? Timestamp.now(),
            'type': 'texte',
            'status': 'sent',
            'lu': true,
          });
        }
      }
    } catch (_) {}
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
    
    try {
      final convDoc = await convRef.get();
      if (convDoc.exists && convDoc.data() != null) {
        final conv = ConversationModel.fromJson(convDoc.data()!, docId: convDoc.id);
        final unreadCount = Map<String, int>.from(conv.unreadCount);
        
        for (final id in conv.participantsIds) {
          if (id != senderId) {
            unreadCount[id] = (unreadCount[id] ?? 0) + 1;
          }
        }

        batch.set(convRef, {
          'lastMessage': type == 'image' ? '📷 Image' : (type == 'pdf' ? '📄 Document PDF' : content),
          'lastMessageTime': Timestamp.now(),
          'unreadCount': unreadCount,
        }, SetOptions(merge: true));
      } else {
        batch.set(convRef, {
          'id': conversationId,
          'participantsIds': [senderId],
          'participantNames': {},
          'participantAvatars': {},
          'lastMessage': type == 'image' ? '📷 Image' : (type == 'pdf' ? '📄 Document PDF' : content),
          'lastMessageTime': Timestamp.now(),
          'unreadCount': {},
        }, SetOptions(merge: true));
      }
    } catch (_) {}

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

          // Si un message initial est spécifié, vérifier si on doit l'envoyer dans la conversation existante
          if (initialContextMessage != null && initialContextMessage.trim().isNotEmpty) {
            final existingMsgs = await _firestore
                .collection('conversations')
                .doc(conv.id)
                .collection('messages')
                .limit(1)
                .get();
            if (existingMsgs.docs.isEmpty) {
              await sendMessage(conv.id, initialContextMessage.trim(), currentUserId);
            }
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
