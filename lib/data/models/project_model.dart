// Firestore Structure:
// Root collection: 'projects'
// Document ID: id
// Sub-collections: 'taches', 'depenses', 'rapports', 'devis', 'alertes'

import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String clientId;
  final String? entrepriseId;
  final String titre;
  final String description;
  final Map<String, dynamic> localisation; // {ville, quartier, coordonnées GPS}
  final double budgetPrevisionnel;
  final double budgetActuel;
  final DateTime dateDebut;
  final DateTime dateFinPrevue;
  final String statut; // brouillon, en_recherche_entreprise, en_cours, en_pause, termine
  final List<String> listePlans;
  final List<String> listeDocuments;
  final List<String> entreprisesPostulantes;
  final String? planChoisi;

  ProjectModel({
    required this.id,
    required this.clientId,
    this.entrepriseId,
    required this.titre,
    required this.description,
    required this.localisation,
    required this.budgetPrevisionnel,
    required this.budgetActuel,
    required this.dateDebut,
    required this.dateFinPrevue,
    required this.statut,
    required this.listePlans,
    required this.listeDocuments,
    this.entreprisesPostulantes = const [],
    this.planChoisi,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      clientId: json['clientId'] as String? ?? '',
      entrepriseId: json['entrepriseId'] as String?,
      titre: json['titre'] as String? ?? 'Projet sans titre',
      description: json['description'] as String? ?? '',
      localisation: json['localisation'] != null ? Map<String, dynamic>.from(json['localisation']) : {},
      budgetPrevisionnel: (json['budgetPrevisionnel'] as num?)?.toDouble() ?? 0.0,
      budgetActuel: (json['budgetActuel'] as num?)?.toDouble() ?? 0.0,
      dateDebut: json['dateDebut'] != null ? (json['dateDebut'] as Timestamp).toDate() : DateTime.now(),
      dateFinPrevue: json['dateFinPrevue'] != null ? (json['dateFinPrevue'] as Timestamp).toDate() : DateTime.now(),
      statut: json['statut'] as String? ?? 'brouillon',
      listePlans: List<String>.from(json['listePlans'] ?? []),
      listeDocuments: List<String>.from(json['listeDocuments'] ?? []),
      entreprisesPostulantes: List<String>.from(json['entreprisesPostulantes'] ?? []),
      planChoisi: json['planChoisi'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'entrepriseId': entrepriseId,
      'titre': titre,
      'description': description,
      'localisation': localisation,
      'budgetPrevisionnel': budgetPrevisionnel,
      'budgetActuel': budgetActuel,
      'dateDebut': Timestamp.fromDate(dateDebut),
      'dateFinPrevue': Timestamp.fromDate(dateFinPrevue),
      'statut': statut,
      'listePlans': listePlans,
      'listeDocuments': listeDocuments,
      'entreprisesPostulantes': entreprisesPostulantes,
      'planChoisi': planChoisi,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? clientId,
    String? entrepriseId,
    String? titre,
    String? description,
    Map<String, dynamic>? localisation,
    double? budgetPrevisionnel,
    double? budgetActuel,
    DateTime? dateDebut,
    DateTime? dateFinPrevue,
    String? statut,
    List<String>? listePlans,
    List<String>? listeDocuments,
    List<String>? entreprisesPostulantes,
    String? planChoisi,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      localisation: localisation ?? this.localisation,
      budgetPrevisionnel: budgetPrevisionnel ?? this.budgetPrevisionnel,
      budgetActuel: budgetActuel ?? this.budgetActuel,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFinPrevue: dateFinPrevue ?? this.dateFinPrevue,
      statut: statut ?? this.statut,
      listePlans: listePlans ?? this.listePlans,
      listeDocuments: listeDocuments ?? this.listeDocuments,
      entreprisesPostulantes: entreprisesPostulantes ?? this.entreprisesPostulantes,
      planChoisi: planChoisi ?? this.planChoisi,
    );
  }
}
