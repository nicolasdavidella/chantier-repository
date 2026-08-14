// Firestore Structure:
// Root collection: 'projects' -> Sub-collection: 'taches'
// Document ID: id

import 'package:cloud_firestore/cloud_firestore.dart';

class TacheModel {
  final String id;
  final String projectId;
  final String titre;
  final String description;
  final String statut; // a_faire, en_cours, terminee, en_retard
  final DateTime dateDebutPrevue;
  final DateTime dateFinPrevue;
  final DateTime? dateFinReelle;
  final String responsable;
  final int ordre;

  TacheModel({
    required this.id,
    required this.projectId,
    required this.titre,
    required this.description,
    required this.statut,
    required this.dateDebutPrevue,
    required this.dateFinPrevue,
    this.dateFinReelle,
    required this.responsable,
    required this.ordre,
  });

  factory TacheModel.fromJson(Map<String, dynamic> json) {
    return TacheModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      statut: json['statut'] as String,
      dateDebutPrevue: (json['dateDebutPrevue'] as Timestamp).toDate(),
      dateFinPrevue: (json['dateFinPrevue'] as Timestamp).toDate(),
      dateFinReelle: json['dateFinReelle'] != null ? (json['dateFinReelle'] as Timestamp).toDate() : null,
      responsable: json['responsable'] as String,
      ordre: json['ordre'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'titre': titre,
      'description': description,
      'statut': statut,
      'dateDebutPrevue': Timestamp.fromDate(dateDebutPrevue),
      'dateFinPrevue': Timestamp.fromDate(dateFinPrevue),
      'dateFinReelle': dateFinReelle != null ? Timestamp.fromDate(dateFinReelle!) : null,
      'responsable': responsable,
      'ordre': ordre,
    };
  }

  TacheModel copyWith({
    String? id,
    String? projectId,
    String? titre,
    String? description,
    String? statut,
    DateTime? dateDebutPrevue,
    DateTime? dateFinPrevue,
    DateTime? dateFinReelle,
    String? responsable,
    int? ordre,
  }) {
    return TacheModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      statut: statut ?? this.statut,
      dateDebutPrevue: dateDebutPrevue ?? this.dateDebutPrevue,
      dateFinPrevue: dateFinPrevue ?? this.dateFinPrevue,
      dateFinReelle: dateFinReelle ?? this.dateFinReelle,
      responsable: responsable ?? this.responsable,
      ordre: ordre ?? this.ordre,
    );
  }
}
