// Firestore Structure:
// Root collection: 'projects' -> Sub-collection: 'alertes'
// Document ID: id

import 'package:cloud_firestore/cloud_firestore.dart';

class AlerteIAModel {
  final String id;
  final String projectId;
  final String type; // anomalie_depense, risque_retard, depassement_budget
  final String gravite; // faible, moyenne, elevee
  final String description;
  final DateTime dateDetection;
  final String statut; // nouvelle, vue, traitee

  AlerteIAModel({
    required this.id,
    required this.projectId,
    required this.type,
    required this.gravite,
    required this.description,
    required this.dateDetection,
    required this.statut,
  });

  factory AlerteIAModel.fromJson(Map<String, dynamic> json) {
    return AlerteIAModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      type: json['type'] as String,
      gravite: json['gravite'] as String,
      description: json['description'] as String,
      dateDetection: (json['dateDetection'] as Timestamp).toDate(),
      statut: json['statut'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'type': type,
      'gravite': gravite,
      'description': description,
      'dateDetection': Timestamp.fromDate(dateDetection),
      'statut': statut,
    };
  }

  AlerteIAModel copyWith({
    String? id,
    String? projectId,
    String? type,
    String? gravite,
    String? description,
    DateTime? dateDetection,
    String? statut,
  }) {
    return AlerteIAModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      gravite: gravite ?? this.gravite,
      description: description ?? this.description,
      dateDetection: dateDetection ?? this.dateDetection,
      statut: statut ?? this.statut,
    );
  }
}
