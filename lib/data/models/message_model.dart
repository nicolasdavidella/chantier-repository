import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String expediteurId;
  final String contenu;
  final DateTime dateEnvoi;
  final String type; // texte, image, fichier
  final String status; // sent, delivered, read
  final bool lu;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.expediteurId,
    required this.contenu,
    required this.dateEnvoi,
    required this.type,
    this.status = 'sent',
    required this.lu,
    this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    Map<String, dynamic>? parsedMetadata;
    try {
      if (json['metadata'] is Map) {
        parsedMetadata = Map<String, dynamic>.from(json['metadata'] as Map);
      }
    } catch (_) {}

    return MessageModel(
      id: json['id']?.toString() ?? docId ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      expediteurId: json['expediteurId']?.toString() ?? json['senderId']?.toString() ?? '',
      contenu: json['contenu']?.toString() ?? json['texte']?.toString() ?? json['content']?.toString() ?? '',
      dateEnvoi: parseDate(json['dateEnvoi'] ?? json['timestamp'] ?? json['createdAt']),
      type: json['type']?.toString() ?? 'texte',
      status: json['status']?.toString() ?? 'sent',
      lu: json['lu'] == true || json['isRead'] == true,
      metadata: parsedMetadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'expediteurId': expediteurId,
      'contenu': contenu,
      'dateEnvoi': Timestamp.fromDate(dateEnvoi),
      'type': type,
      'status': status,
      'lu': lu,
      'metadata': metadata,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? expediteurId,
    String? contenu,
    DateTime? dateEnvoi,
    String? type,
    String? status,
    bool? lu,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      expediteurId: expediteurId ?? this.expediteurId,
      contenu: contenu ?? this.contenu,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      type: type ?? this.type,
      status: status ?? this.status,
      lu: lu ?? this.lu,
      metadata: metadata ?? this.metadata,
    );
  }
}
