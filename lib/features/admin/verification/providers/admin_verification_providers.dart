import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/verification_request_model.dart';

import '../data/audit_log_repository.dart';

final adminVerificationListProvider = StreamProvider.family<List<VerificationRequestModel>, String>((ref, statusFilter) {
  Query query = FirebaseFirestore.instance.collection('verification_requests');
  
  if (statusFilter != 'ALL') {
    query = query.where('status', isEqualTo: statusFilter);
  }
  
  return query.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => VerificationRequestModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  });
});

final dashboardStatsProvider = StreamProvider<Map<String, int>>((ref) {
  return FirebaseFirestore.instance.collection('verification_requests').snapshots().map((snapshot) {
    int pending = 0;
    int underReview = 0;
    int approved = 0;
    int rejected = 0;

    for (var doc in snapshot.docs) {
      final status = doc.data()['status'] as String?;
      if (status == 'SUBMITTED') {
        pending++;
      } else if (status == 'UNDER_REVIEW') {
        underReview++;
      } else if (status == 'APPROVED') {
        approved++;
      } else if (status == 'REJECTED') {
        rejected++;
      }
    }

    return {
      'pending': pending,
      'under_review': underReview,
      'approved': approved,
      'rejected': rejected,
      'total': snapshot.docs.length,
    };
  });
});

class AdminVerificationController extends StateNotifier<AsyncValue<void>> {
  final AuditLogRepository _auditRepository;
  final FirebaseFirestore _firestore;

  AdminVerificationController(this._auditRepository, this._firestore) : super(const AsyncValue.data(null));

  Future<void> updateDocumentStatus(
    String requestId, 
    String entrepriseId, 
    String docType, 
    String status, 
    String? rejectionReason,
    String adminId,
  ) async {
    state = const AsyncValue.loading();
    try {
      final requestRef = _firestore.collection('verification_requests').doc(requestId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(requestRef);
        final request = VerificationRequestModel.fromJson(snapshot.data()!);
        
        final docs = List.of(request.documents);
        final index = docs.indexWhere((d) => d.type == docType);
        
        if (index != -1) {
          final oldStatus = docs[index].status;
          docs[index] = docs[index].copyWith(
            status: status, 
            rejectionReason: rejectionReason,
            reviewedAt: DateTime.now(),
          );
          
          transaction.update(requestRef, {
            'documents': docs.map((e) => e.toJson()).toList(),
          });

          // Log action
          _auditRepository.logAction(
            adminId: adminId,
            entrepriseId: entrepriseId,
            action: status == 'APPROVED' ? 'DOCUMENT_APPROVED' : 'DOCUMENT_REJECTED',
            oldStatus: oldStatus,
            newStatus: status,
            comment: rejectionReason,
          );
        }
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateRequestStatus(
    String requestId, 
    String entrepriseId, 
    String status, 
    String adminId,
    {String? globalFeedback}
  ) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.collection('verification_requests').doc(requestId).update({
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
        // ignore: use_null_aware_elements
        if (globalFeedback != null) 'globalFeedback': globalFeedback,
      });

      // Si approuvé, on met à jour l'entreprise
      if (status == 'APPROVED') {
        await _firestore.collection('entreprises').doc(entrepriseId).update({
          'verificationStatus': 'APPROVED',
          'isVerified': true,
          'verificationDate': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('entreprises').doc(entrepriseId).update({
          'verificationStatus': status,
        });
      }

      _auditRepository.logAction(
        adminId: adminId,
        entrepriseId: entrepriseId,
        action: 'REQUEST_STATUS_UPDATED',
        newStatus: status,
        comment: globalFeedback,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminVerificationControllerProvider = StateNotifierProvider<AdminVerificationController, AsyncValue<void>>((ref) {
  final auditRepo = ref.watch(auditLogRepositoryProvider);
  return AdminVerificationController(auditRepo, FirebaseFirestore.instance);
});
