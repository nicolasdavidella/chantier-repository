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
  final String? projectTitle;
  final String? clientName;
  final String? clientId;

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
    this.projectTitle,
    this.clientName,
    this.clientId,
  });

  factory DevisModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return DevisModel(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      entrepriseId: json['entrepriseId']?.toString() ?? '',
      montant: (json['montant'] is num)
          ? (json['montant'] as num).toDouble()
          : (double.tryParse(json['montant']?.toString() ?? '') ?? 0.0),
      delaiEstime: json['delaiEstime']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dateEnvoi: parseDate(json['dateEnvoi']),
      statut: json['statut']?.toString() ?? 'en_attente',
      fichierPdfUrl: json['fichierPdfUrl']?.toString(),
      projectTitle: json['projectTitle']?.toString() ?? json['titreProjet']?.toString(),
      clientName: json['clientName']?.toString() ?? json['nomClient']?.toString(),
      clientId: json['clientId']?.toString(),
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
      if (projectTitle != null) 'projectTitle': projectTitle,
      if (clientName != null) 'clientName': clientName,
      if (clientId != null) 'clientId': clientId,
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
    String? projectTitle,
    String? clientName,
    String? clientId,
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
      projectTitle: projectTitle ?? this.projectTitle,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
    );
  }
}
