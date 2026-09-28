import 'package:cloud_firestore/cloud_firestore.dart';

class CertificationDocument {
  final String type; // ex: 'RCCM', 'NIU', 'PIECE_IDENTITE'
  final String nom;
  final String url;
  final DateTime dateUpload;

  CertificationDocument({
    required this.type,
    required this.nom,
    required this.url,
    required this.dateUpload,
  });

  factory CertificationDocument.fromJson(Map<String, dynamic> json) {
    return CertificationDocument(
      type: json['type'] ?? '',
      nom: json['nom'] ?? '',
      url: json['url'] ?? '',
      dateUpload: (json['dateUpload'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'nom': nom,
      'url': url,
      'dateUpload': Timestamp.fromDate(dateUpload),
    };
  }
}

class CertificationRequestModel {
  final String entrepriseId; // ID of the document (same as entrepriseId)
  final String raisonSociale;
  final String rccm;
  final String niu;
  final List<String> villesZones;
  final List<String> specialites;
  final String contact;
  final List<CertificationDocument> documents;
  final String statut; // 'brouillon' | 'en_attente' | 'certifiee' | 'rejetee'
  final DateTime? dateSoumission;
  final DateTime? dateDecision;
  final String? adminId;
  final String? motifRejet;
  final int nombreSoumissions;

  CertificationRequestModel({
    required this.entrepriseId,
    required this.raisonSociale,
    required this.rccm,
    required this.niu,
    required this.villesZones,
    required this.specialites,
    required this.contact,
    required this.documents,
    required this.statut,
    this.dateSoumission,
    this.dateDecision,
    this.adminId,
    this.motifRejet,
    this.nombreSoumissions = 0,
  });

  factory CertificationRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return CertificationRequestModel(
      entrepriseId: id,
      raisonSociale: json['raisonSociale'] ?? '',
      rccm: json['rccm'] ?? '',
      niu: json['niu'] ?? '',
      villesZones: List<String>.from(json['villesZones'] ?? []),
      specialites: List<String>.from(json['specialites'] ?? []),
      contact: json['contact'] ?? '',
      documents: (json['documents'] as List<dynamic>?)
              ?.map((doc) => CertificationDocument.fromJson(doc as Map<String, dynamic>))
              .toList() ??
          [],
      statut: json['statut'] ?? 'brouillon',
      dateSoumission: (json['dateSoumission'] as Timestamp?)?.toDate(),
      dateDecision: (json['dateDecision'] as Timestamp?)?.toDate(),
      adminId: json['adminId'],
      motifRejet: json['motifRejet'],
      nombreSoumissions: json['nombreSoumissions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entrepriseId': entrepriseId,
      'raisonSociale': raisonSociale,
      'rccm': rccm,
      'niu': niu,
      'villesZones': villesZones,
      'specialites': specialites,
      'contact': contact,
      'documents': documents.map((d) => d.toJson()).toList(),
      'statut': statut,
      'dateSoumission': dateSoumission != null ? Timestamp.fromDate(dateSoumission!) : null,
      'dateDecision': dateDecision != null ? Timestamp.fromDate(dateDecision!) : null,
      'adminId': adminId,
      'motifRejet': motifRejet,
      'nombreSoumissions': nombreSoumissions,
    };
  }
}
