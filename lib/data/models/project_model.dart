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
  final String creationSource; // 'ia_assistant' | 'manuel'
  final String? plan3DUrl;
  final String? devisEstimeUrl;
  final bool isMarketplacePublished;
  final DateTime? datePublicationMarketplace;

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
    this.creationSource = 'manuel',
    this.plan3DUrl,
    this.devisEstimeUrl,
    this.isMarketplacePublished = true,
    this.datePublicationMarketplace,
  });

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      clientId: (json['clientId'] ?? json['clientUserId'] ?? json['userId'] ?? json['proprietaireId'])?.toString() ?? '',
      entrepriseId: json['entrepriseId'] as String?,
      titre: json['titre'] as String? ?? 'Projet de construction',
      description: json['description'] as String? ?? '',
      localisation: json['localisation'] is Map
          ? Map<String, dynamic>.from(json['localisation'] as Map)
          : (json['ville'] != null ? {'ville': json['ville'], 'quartier': json['quartier'] ?? ''} : {}),
      budgetPrevisionnel: (json['budgetPrevisionnel'] is num)
          ? (json['budgetPrevisionnel'] as num).toDouble()
          : (double.tryParse(json['budgetPrevisionnel']?.toString() ?? '') ?? 0.0),
      budgetActuel: (json['budgetActuel'] is num)
          ? (json['budgetActuel'] as num).toDouble()
          : (double.tryParse(json['budgetActuel']?.toString() ?? '') ?? 0.0),
      dateDebut: _parseDate(json['dateDebut']),
      dateFinPrevue: _parseDate(json['dateFinPrevue']),
      statut: json['statut'] as String? ?? 'brouillon',
      listePlans: json['listePlans'] is List ? List<String>.from(json['listePlans']) : [],
      listeDocuments: json['listeDocuments'] is List ? List<String>.from(json['listeDocuments']) : [],
      entreprisesPostulantes: json['entreprisesPostulantes'] is List ? List<String>.from(json['entreprisesPostulantes']) : [],
      planChoisi: json['planChoisi'] as String?,
      creationSource: json['creationSource'] as String? ?? (json['planChoisi'] != null ? 'ia_assistant' : 'manuel'),
      plan3DUrl: json['plan3DUrl'] as String?,
      devisEstimeUrl: json['devisEstimeUrl'] as String?,
      isMarketplacePublished: json['isMarketplacePublished'] as bool? ?? (json['statut'] == 'en_recherche_entreprise'),
      datePublicationMarketplace: json['datePublicationMarketplace'] != null
          ? _parseDate(json['datePublicationMarketplace'])
          : null,
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
      'creationSource': creationSource,
      'plan3DUrl': plan3DUrl,
      'devisEstimeUrl': devisEstimeUrl,
      'isMarketplacePublished': isMarketplacePublished,
      'datePublicationMarketplace': datePublicationMarketplace != null
          ? Timestamp.fromDate(datePublicationMarketplace!)
          : null,
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
    String? creationSource,
    String? plan3DUrl,
    String? devisEstimeUrl,
    bool? isMarketplacePublished,
    DateTime? datePublicationMarketplace,
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
      creationSource: creationSource ?? this.creationSource,
      plan3DUrl: plan3DUrl ?? this.plan3DUrl,
      devisEstimeUrl: devisEstimeUrl ?? this.devisEstimeUrl,
      isMarketplacePublished: isMarketplacePublished ?? this.isMarketplacePublished,
      datePublicationMarketplace: datePublicationMarketplace ?? this.datePublicationMarketplace,
    );
  }
}
