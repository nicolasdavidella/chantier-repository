// Firestore Structure:
// Root collection: 'avis'
// Document ID: id

import 'package:cloud_firestore/cloud_firestore.dart';

class AvisModel {
  final String id;
  final String targetId; // ID de l'entreprise ou du chef de chantier
  final String targetType; // 'entreprise' ou 'chef_chantier'
  final String clientId;
  final String projectId;
  
  // Note globale moyenne calculée
  final double note;
  
  // Détail par critères
  final Map<String, int> criteres; // ex: {'qualite': 5, 'delais': 4, 'communication': 5, 'prix': 4}
  
  final String commentaire;
  final DateTime dateCreation;
  
  final String? reponseEntreprise;
  final bool signale;

  AvisModel({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.clientId,
    required this.projectId,
    required this.note,
    required this.criteres,
    required this.commentaire,
    required this.dateCreation,
    this.reponseEntreprise,
    this.signale = false,
  });

  factory AvisModel.fromJson(Map<String, dynamic> json) {
    return AvisModel(
      id: json['id'] as String,
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      clientId: json['clientId'] as String,
      projectId: json['projectId'] as String,
      note: (json['note'] as num).toDouble(),
      criteres: Map<String, int>.from(json['criteres'] as Map),
      commentaire: json['commentaire'] as String,
      dateCreation: (json['dateCreation'] as Timestamp).toDate(),
      reponseEntreprise: json['reponseEntreprise'] as String?,
      signale: json['signale'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetId': targetId,
      'targetType': targetType,
      'clientId': clientId,
      'projectId': projectId,
      'note': note,
      'criteres': criteres,
      'commentaire': commentaire,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'reponseEntreprise': reponseEntreprise,
      'signale': signale,
    };
  }

  AvisModel copyWith({
    String? id,
    String? targetId,
    String? targetType,
    String? clientId,
    String? projectId,
    double? note,
    Map<String, int>? criteres,
    String? commentaire,
    DateTime? dateCreation,
    String? reponseEntreprise,
    bool? signale,
  }) {
    return AvisModel(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      note: note ?? this.note,
      criteres: criteres ?? this.criteres,
      commentaire: commentaire ?? this.commentaire,
      dateCreation: dateCreation ?? this.dateCreation,
      reponseEntreprise: reponseEntreprise ?? this.reponseEntreprise,
      signale: signale ?? this.signale,
    );
  }
}
