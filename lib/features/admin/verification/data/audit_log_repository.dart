import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/audit_log_model.dart';

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  return AuditLogRepository(firestore: FirebaseFirestore.instance);
});

class AuditLogRepository {
  final FirebaseFirestore _firestore;

  AuditLogRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<void> logAction({
    required String adminId,
    required String entrepriseId,
    required String action,
    String? documentId,
    String? oldStatus,
    String? newStatus,
    String? comment,
  }) async {
    final docRef = _firestore.collection('audit_logs').doc();
    final log = AuditLogModel(
      id: docRef.id,
      adminId: adminId,
      entrepriseId: entrepriseId,
      action: action,
      documentId: documentId,
      oldStatus: oldStatus,
      newStatus: newStatus,
      comment: comment,
      timestamp: DateTime.now(),
    );

    await docRef.set(log.toJson());
  }

  Stream<List<AuditLogModel>> watchEnterpriseAuditLogs(String entrepriseId) {
    return _firestore
        .collection('audit_logs')
        .where('entrepriseId', isEqualTo: entrepriseId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AuditLogModel.fromJson(doc.data())).toList());
  }
}
