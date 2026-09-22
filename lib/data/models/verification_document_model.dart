import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationDocumentModel {
  final String id;
  final String type; // registre_commerce, identifiant_fiscal, statuts, cni, etc.
  final String url;
  final String status; // PENDING, APPROVED, REJECTED, EXPIRED
  final String? rejectionReason;
  final DateTime uploadedAt;
  final DateTime? reviewedAt;

  VerificationDocumentModel({
    required this.id,
    required this.type,
    required this.url,
    this.status = 'PENDING',
    this.rejectionReason,
    required this.uploadedAt,
    this.reviewedAt,
  });

  factory VerificationDocumentModel.fromJson(Map<String, dynamic> json) {
    return VerificationDocumentModel(
      id: json['id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      status: json['status'] as String? ?? 'PENDING',
      rejectionReason: json['rejectionReason'] as String?,
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
      reviewedAt: json['reviewedAt'] != null ? (json['reviewedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'status': status,
      'rejectionReason': rejectionReason,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }

  VerificationDocumentModel copyWith({
    String? id,
    String? type,
    String? url,
    String? status,
    String? rejectionReason,
    DateTime? uploadedAt,
    DateTime? reviewedAt,
  }) {
    return VerificationDocumentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
