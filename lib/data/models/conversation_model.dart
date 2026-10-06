import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> participantsIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantAvatars;
  final String? projectId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount; // userId -> count

  ConversationModel({
    required this.id,
    required this.participantsIds,
    required this.participantNames,
    required this.participantAvatars,
    this.projectId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    // participantsIds fallback to 'participants'
    List<String> participants = [];
    if (json['participantsIds'] is List) {
      participants = (json['participantsIds'] as List).map((e) => e.toString()).toList();
    } else if (json['participants'] is List) {
      participants = (json['participants'] as List).map((e) => e.toString()).toList();
    }

    // participantNames
    Map<String, String> names = {};
    if (json['participantNames'] is Map) {
      (json['participantNames'] as Map).forEach((k, v) {
        if (k != null && v != null) {
          names[k.toString()] = v.toString();
        }
      });
    }

    // participantAvatars
    Map<String, String?> avatars = {};
    if (json['participantAvatars'] is Map) {
      (json['participantAvatars'] as Map).forEach((k, v) {
        if (k != null) {
          avatars[k.toString()] = v?.toString();
        }
      });
    }

    // unreadCount fallback to 'nonLus'
    Map<String, int> unread = {};
    if (json['unreadCount'] is Map) {
      (json['unreadCount'] as Map).forEach((k, v) {
        if (k != null && v != null) {
          unread[k.toString()] = int.tryParse(v.toString()) ?? 0;
        }
      });
    } else if (json['nonLus'] is Map) {
      (json['nonLus'] as Map).forEach((k, v) {
        if (k != null && v != null) {
          unread[k.toString()] = int.tryParse(v.toString()) ?? 0;
        }
      });
    }

    // lastMessage fallback to 'dernierMessage'
    final lastMsg = json['lastMessage']?.toString() ??
        json['dernierMessage']?.toString() ??
        '';

    // lastMessageTime fallback to 'dateDernierMessage'
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    final msgTime = parseDate(json['lastMessageTime'] ?? json['dateDernierMessage']);

    return ConversationModel(
      id: json['id']?.toString() ?? docId ?? '',
      participantsIds: participants,
      participantNames: names,
      participantAvatars: avatars,
      projectId: json['projectId']?.toString(),
      lastMessage: lastMsg,
      lastMessageTime: msgTime,
      unreadCount: unread,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantsIds': participantsIds,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'projectId': projectId,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
    };
  }

  ConversationModel copyWith({
    String? id,
    List<String>? participantsIds,
    Map<String, String>? participantNames,
    Map<String, String?>? participantAvatars,
    String? projectId,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participantsIds: participantsIds ?? this.participantsIds,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      projectId: projectId ?? this.projectId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
