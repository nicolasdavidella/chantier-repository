import 'package:cloud_firestore/cloud_firestore.dart';
import 'verification_document_model.dart';

// Firestore collection: 'verification_requests'
class VerificationRequestModel {
  final String id;
  final String entrepriseId;
  final String status; // DRAFT, SUBMITTED, UNDER_REVIEW, ADDITIONAL_INFO_REQUIRED, APPROVED, REJECTED
  final DateTime createdAt;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final List<VerificationDocumentModel> documents;
  final String? globalFeedback;

  VerificationRequestModel({
    required this.id,
    required this.entrepriseId,
    this.status = 'DRAFT',
    required this.createdAt,
    this.submittedAt,
    this.reviewedAt,
    this.documents = const [],
    this.globalFeedback,
  });

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      id: json['id'] as String,
      entrepriseId: json['entrepriseId'] as String,
      status: json['status'] as String? ?? 'DRAFT',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      submittedAt: json['submittedAt'] != null ? (json['submittedAt'] as Timestamp).toDate() : null,
      reviewedAt: json['reviewedAt'] != null ? (json['reviewedAt'] as Timestamp).toDate() : null,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((doc) => VerificationDocumentModel.fromJson(doc as Map<String, dynamic>))
              .toList() ??
          [],
      globalFeedback: json['globalFeedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entrepriseId': entrepriseId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'submittedAt': submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'globalFeedback': globalFeedback,
    };
  }

  VerificationRequestModel copyWith({
    String? id,
    String? entrepriseId,
    String? status,
    DateTime? createdAt,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    List<VerificationDocumentModel>? documents,
    String? globalFeedback,
  }) {
    return VerificationRequestModel(
      id: id ?? this.id,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      documents: documents ?? this.documents,
      globalFeedback: globalFeedback ?? this.globalFeedback,
    );
  }
}
