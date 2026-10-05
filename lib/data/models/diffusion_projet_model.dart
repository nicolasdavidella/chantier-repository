import 'package:cloud_firestore/cloud_firestore.dart';

class DiffusionProjetModel {
  final String id;
  final String projectId;
  final String clientId;
  final String entrepriseId;
  final String statut; // 'envoye', 'accepte', 'capable', 'decline', 'retenu'
  final DateTime dateEnvoi;
  final DateTime? dateReponse;
  final String? commentaire;
  final double? devisEstime;

  DiffusionProjetModel({
    required this.id,
    required this.projectId,
    required this.clientId,
    required this.entrepriseId,
    required this.statut,
    required this.dateEnvoi,
    this.dateReponse,
    this.commentaire,
    this.devisEstime,
  });

  factory DiffusionProjetModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return DiffusionProjetModel(
      id: id ?? (json['id'] as String? ?? ''),
      projectId: json['projectId'] as String? ?? '',
      clientId: json['clientId'] as String? ?? '',
      entrepriseId: json['entrepriseId'] as String? ?? '',
      statut: json['statut'] as String? ?? 'envoye',
      dateEnvoi: json['dateEnvoi'] != null
          ? (json['dateEnvoi'] as Timestamp).toDate()
          : DateTime.now(),
      dateReponse: json['dateReponse'] != null
          ? (json['dateReponse'] as Timestamp).toDate()
          : null,
      commentaire: json['commentaire'] as String?,
      devisEstime: (json['devisEstime'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'clientId': clientId,
      'entrepriseId': entrepriseId,
      'statut': statut,
      'dateEnvoi': Timestamp.fromDate(dateEnvoi),
      'dateReponse': dateReponse != null ? Timestamp.fromDate(dateReponse!) : null,
      'commentaire': commentaire,
      'devisEstime': devisEstime,
    };
  }

  DiffusionProjetModel copyWith({
    String? id,
    String? projectId,
    String? clientId,
    String? entrepriseId,
    String? statut,
    DateTime? dateEnvoi,
    DateTime? dateReponse,
    String? commentaire,
    double? devisEstime,
  }) {
    return DiffusionProjetModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      clientId: clientId ?? this.clientId,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      statut: statut ?? this.statut,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      dateReponse: dateReponse ?? this.dateReponse,
      commentaire: commentaire ?? this.commentaire,
      devisEstime: devisEstime ?? this.devisEstime,
    );
  }
}
