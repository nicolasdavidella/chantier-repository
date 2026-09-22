import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore collection: 'audit_logs'
class AuditLogModel {
  final String id;
  final String adminId; // ID of the admin who performed the action
  final String entrepriseId; // ID of the target company
  final String action; // DOCUMENT_APPROVED, DOCUMENT_REJECTED, ENTREPRISE_APPROVED, ENTREPRISE_REJECTED, SUSPENDED, MORE_INFO_REQUESTED
  final String? documentId;
  final String? oldStatus;
  final String? newStatus;
  final String? comment;
  final DateTime timestamp;

  AuditLogModel({
    required this.id,
    required this.adminId,
    required this.entrepriseId,
    required this.action,
    this.documentId,
    this.oldStatus,
    this.newStatus,
    this.comment,
    required this.timestamp,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      adminId: json['adminId'] as String,
      entrepriseId: json['entrepriseId'] as String,
      action: json['action'] as String,
      documentId: json['documentId'] as String?,
      oldStatus: json['oldStatus'] as String?,
      newStatus: json['newStatus'] as String?,
      comment: json['comment'] as String?,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'entrepriseId': entrepriseId,
      'action': action,
      'documentId': documentId,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
