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

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.expediteurId,
    required this.contenu,
    required this.dateEnvoi,
    required this.type,
    this.status = 'sent',
    required this.lu,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      expediteurId: json['expediteurId'] as String,
      contenu: json['contenu'] as String,
      dateEnvoi: (json['dateEnvoi'] as Timestamp).toDate(),
      type: json['type'] as String,
      status: json['status'] as String? ?? 'sent',
      lu: json['lu'] as bool? ?? false,
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
    );
  }
}
