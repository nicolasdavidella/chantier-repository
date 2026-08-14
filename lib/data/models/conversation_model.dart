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

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participantsIds: List<String>.from(json['participantsIds']),
      participantNames: Map<String, String>.from(json['participantNames']),
      participantAvatars: Map<String, String?>.from(json['participantAvatars'] ?? {}),
      projectId: json['projectId'] as String?,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: (json['lastMessageTime'] as Timestamp).toDate(),
      unreadCount: Map<String, int>.from(json['unreadCount'] ?? {}),
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
