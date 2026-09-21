// Firestore Structure:
// Root collection: 'reclamations'
// Document ID: id

import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamationModel {
  final String id;
  final String projectId;
  final String titre;
  final String description;
  final String statut; // ouverte, en_traitement, resolue
  final DateTime dateCreation;
  final DateTime? dateResolution;
  final String clientUserId;
  final String? entrepriseId;
  final String? reponseAdmin;
  final List<String> piecesJointes;

  ReclamationModel({
    required this.id,
    required this.projectId,
    required this.titre,
    required this.description,
    required this.statut,
    required this.dateCreation,
    this.dateResolution,
    required this.clientUserId,
    this.entrepriseId,
    this.reponseAdmin,
    this.piecesJointes = const [],
  });

  factory ReclamationModel.fromJson(Map<String, dynamic> json) {
    return ReclamationModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      statut: json['statut'] as String,
      dateCreation: (json['dateCreation'] as Timestamp).toDate(),
      dateResolution: json['dateResolution'] != null ? (json['dateResolution'] as Timestamp).toDate() : null,
      clientUserId: json['clientUserId'] as String,
      entrepriseId: json['entrepriseId'] as String?,
      reponseAdmin: json['reponseAdmin'] as String?,
      piecesJointes: (json['piecesJointes'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'titre': titre,
      'description': description,
      'statut': statut,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateResolution': dateResolution != null ? Timestamp.fromDate(dateResolution!) : null,
      'clientUserId': clientUserId,
      'entrepriseId': entrepriseId,
      'reponseAdmin': reponseAdmin,
      'piecesJointes': piecesJointes,
    };
  }

  ReclamationModel copyWith({
    String? id,
    String? projectId,
    String? titre,
    String? description,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateResolution,
    String? clientUserId,
    String? entrepriseId,
    String? reponseAdmin,
    List<String>? piecesJointes,
  }) {
    return ReclamationModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateResolution: dateResolution ?? this.dateResolution,
      clientUserId: clientUserId ?? this.clientUserId,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      reponseAdmin: reponseAdmin ?? this.reponseAdmin,
      piecesJointes: piecesJointes ?? this.piecesJointes,
    );
  }
}
