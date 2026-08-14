// Firestore Structure:
// Root collection: 'projects' -> Sub-collection: 'depenses'
// Document ID: id

import 'package:cloud_firestore/cloud_firestore.dart';

class DepenseModel {
  final String id;
  final String projectId;
  final String categorie; // materiaux, main_oeuvre, transport, autre
  final double montant;
  final String description;
  final String? justificatifUrl;
  final DateTime dateDeclaration;
  final String declarantId;
  final String statut; // en_attente, validee, contestee
  final Map<String, dynamic>? coordonneesGPS;

  DepenseModel({
    required this.id,
    required this.projectId,
    required this.categorie,
    required this.montant,
    required this.description,
    this.justificatifUrl,
    required this.dateDeclaration,
    required this.declarantId,
    required this.statut,
    this.coordonneesGPS,
  });

  factory DepenseModel.fromJson(Map<String, dynamic> json) {
    return DepenseModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      categorie: json['categorie'] as String,
      montant: (json['montant'] as num).toDouble(),
      description: json['description'] as String,
      justificatifUrl: json['justificatifUrl'] as String?,
      dateDeclaration: (json['dateDeclaration'] as Timestamp).toDate(),
      declarantId: json['declarantId'] as String,
      statut: json['statut'] as String,
      coordonneesGPS: json['coordonneesGPS'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'categorie': categorie,
      'montant': montant,
      'description': description,
      'justificatifUrl': justificatifUrl,
      'dateDeclaration': Timestamp.fromDate(dateDeclaration),
      'declarantId': declarantId,
      'statut': statut,
      'coordonneesGPS': coordonneesGPS,
    };
  }

  DepenseModel copyWith({
    String? id,
    String? projectId,
    String? categorie,
    double? montant,
    String? description,
    String? justificatifUrl,
    DateTime? dateDeclaration,
    String? declarantId,
    String? statut,
    Map<String, dynamic>? coordonneesGPS,
  }) {
    return DepenseModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      categorie: categorie ?? this.categorie,
      montant: montant ?? this.montant,
      description: description ?? this.description,
      justificatifUrl: justificatifUrl ?? this.justificatifUrl,
      dateDeclaration: dateDeclaration ?? this.dateDeclaration,
      declarantId: declarantId ?? this.declarantId,
      statut: statut ?? this.statut,
      coordonneesGPS: coordonneesGPS ?? this.coordonneesGPS,
    );
  }
}
