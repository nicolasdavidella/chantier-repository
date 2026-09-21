// Firestore Structure:
// Root collection: 'projects' -> Sub-collection: 'incidents'
// Document ID: id

import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentModel {
  final String id;
  final String projectId;
  final String titre;
  final String description;
  final String type; // intemperie, materiel, personnel, autre
  final String statut; // nouveau, en_cours, resolu
  final DateTime dateSignalement;
  final DateTime? dateResolution;
  final List<String> photosUrl;
  final String signalePar; // userId de l'entreprise ou du chef de chantier

  IncidentModel({
    required this.id,
    required this.projectId,
    required this.titre,
    required this.description,
    required this.type,
    required this.statut,
    required this.dateSignalement,
    this.dateResolution,
    this.photosUrl = const [],
    required this.signalePar,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      statut: json['statut'] as String,
      dateSignalement: (json['dateSignalement'] as Timestamp).toDate(),
      dateResolution: json['dateResolution'] != null ? (json['dateResolution'] as Timestamp).toDate() : null,
      photosUrl: (json['photosUrl'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      signalePar: json['signalePar'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'titre': titre,
      'description': description,
      'type': type,
      'statut': statut,
      'dateSignalement': Timestamp.fromDate(dateSignalement),
      'dateResolution': dateResolution != null ? Timestamp.fromDate(dateResolution!) : null,
      'photosUrl': photosUrl,
      'signalePar': signalePar,
    };
  }

  IncidentModel copyWith({
    String? id,
    String? projectId,
    String? titre,
    String? description,
    String? type,
    String? statut,
    DateTime? dateSignalement,
    DateTime? dateResolution,
    List<String>? photosUrl,
    String? signalePar,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      type: type ?? this.type,
      statut: statut ?? this.statut,
      dateSignalement: dateSignalement ?? this.dateSignalement,
      dateResolution: dateResolution ?? this.dateResolution,
      photosUrl: photosUrl ?? this.photosUrl,
      signalePar: signalePar ?? this.signalePar,
    );
  }
}
