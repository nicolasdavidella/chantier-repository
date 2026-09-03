import 'package:cloud_firestore/cloud_firestore.dart';

class CandidatureModel {
  final String id;
  final String projectId;
  final String entrepriseId;
  final DateTime dateCandidature;
  final String statut; // en_attente, accepte, refuse

  CandidatureModel({
    required this.id,
    required this.projectId,
    required this.entrepriseId,
    required this.dateCandidature,
    required this.statut,
  });

  factory CandidatureModel.fromJson(Map<String, dynamic> json) {
    return CandidatureModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      entrepriseId: json['entrepriseId'] as String,
      dateCandidature: (json['dateCandidature'] as Timestamp).toDate(),
      statut: json['statut'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'entrepriseId': entrepriseId,
      'dateCandidature': Timestamp.fromDate(dateCandidature),
      'statut': statut,
    };
  }

  CandidatureModel copyWith({
    String? id,
    String? projectId,
    String? entrepriseId,
    DateTime? dateCandidature,
    String? statut,
  }) {
    return CandidatureModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      dateCandidature: dateCandidature ?? this.dateCandidature,
      statut: statut ?? this.statut,
    );
  }
}
