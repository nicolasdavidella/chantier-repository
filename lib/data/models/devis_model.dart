// Firestore Structure:
// Root collection: 'projects' -> Sub-collection: 'devis'
// Document ID: id

import 'package:cloud_firestore/cloud_firestore.dart';

class DevisModel {
  final String id;
  final String projectId;
  final String entrepriseId;
  final double montant;
  final String delaiEstime;
  final String description;
  final DateTime dateEnvoi;
  final String statut; // en_attente, accepte, refuse
  final String? fichierPdfUrl;

  DevisModel({
    required this.id,
    required this.projectId,
    required this.entrepriseId,
    required this.montant,
    required this.delaiEstime,
    required this.description,
    required this.dateEnvoi,
    required this.statut,
    this.fichierPdfUrl,
  });

  factory DevisModel.fromJson(Map<String, dynamic> json) {
    return DevisModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      entrepriseId: json['entrepriseId'] as String,
      montant: (json['montant'] as num).toDouble(),
      delaiEstime: json['delaiEstime'] as String,
      description: json['description'] as String,
      dateEnvoi: (json['dateEnvoi'] as Timestamp).toDate(),
      statut: json['statut'] as String,
      fichierPdfUrl: json['fichierPdfUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'entrepriseId': entrepriseId,
      'montant': montant,
      'delaiEstime': delaiEstime,
      'description': description,
      'dateEnvoi': Timestamp.fromDate(dateEnvoi),
      'statut': statut,
      'fichierPdfUrl': fichierPdfUrl,
    };
  }

  DevisModel copyWith({
    String? id,
    String? projectId,
    String? entrepriseId,
    double? montant,
    String? delaiEstime,
    String? description,
    DateTime? dateEnvoi,
    String? statut,
    String? fichierPdfUrl,
  }) {
    return DevisModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      montant: montant ?? this.montant,
      delaiEstime: delaiEstime ?? this.delaiEstime,
      description: description ?? this.description,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      statut: statut ?? this.statut,
      fichierPdfUrl: fichierPdfUrl ?? this.fichierPdfUrl,
    );
  }
}
