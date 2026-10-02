// Firestore Structure:
// Root collection: 'entreprises'
// Document ID: id

import 'package:cloud_firestore/cloud_firestore.dart';

class EntrepriseModel {
  final String id;
  final String userId;
  final String raisonSociale;
  final String? nomCommercial;
  final String? numeroImmatriculation;
  final String? formeJuridique;
  final DateTime? dateCreation;
  final String? adresseSiege;
  final String? ville;
  final String? region;
  final String? telephone;
  final String? emailProfessionnel;
  final String? siteWeb;
  final String? responsableNom;
  final String? responsableFonction;
  final String? responsableTelephone;
  final String description;
  final List<String> specialites;
  final int anneesExperience;
  final double noteMoyenne;
  final int nombreAvis;
  final List<String> realisations;
  final List<String> zoneIntervention;
  
  // Verification System
  final bool isVerified;
  final String verificationStatus; // DRAFT, SUBMITTED, UNDER_REVIEW, ADDITIONAL_INFO_REQUIRED, APPROVED, REJECTED, SUSPENDED, EXPIRED
  final DateTime? verificationDate;
  
  final String? nifDocumentUrl;
  final String? rccmDocumentUrl;
  
  final String? logoUrl;
  
  final String? prixMoyen;
  final String? delaiMoyen;

  EntrepriseModel({
    required this.id,
    required this.userId,
    required this.raisonSociale,
    this.nomCommercial,
    this.numeroImmatriculation,
    this.formeJuridique,
    this.dateCreation,
    this.adresseSiege,
    this.ville,
    this.region,
    this.telephone,
    this.emailProfessionnel,
    this.siteWeb,
    this.responsableNom,
    this.responsableFonction,
    this.responsableTelephone,
    required this.description,
    required this.specialites,
    required this.anneesExperience,
    required this.noteMoyenne,
    required this.nombreAvis,
    required this.realisations,
    required this.zoneIntervention,
    this.isVerified = false,
    this.verificationStatus = 'DRAFT',
    this.verificationDate,
    this.nifDocumentUrl,
    this.rccmDocumentUrl,
    this.logoUrl,
    this.prixMoyen,
    this.delaiMoyen,
  });

  factory EntrepriseModel.fromJson(Map<String, dynamic> json) {
    return EntrepriseModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      raisonSociale: json['raisonSociale'] as String,
      nomCommercial: json['nomCommercial'] as String?,
      numeroImmatriculation: json['numeroImmatriculation'] as String?,
      formeJuridique: json['formeJuridique'] as String?,
      dateCreation: json['dateCreation'] != null ? (json['dateCreation'] as Timestamp).toDate() : null,
      adresseSiege: json['adresseSiege'] as String?,
      ville: json['ville'] as String?,
      region: json['region'] as String?,
      telephone: json['telephone'] as String?,
      emailProfessionnel: json['emailProfessionnel'] as String?,
      siteWeb: json['siteWeb'] as String?,
      responsableNom: json['responsableNom'] as String?,
      responsableFonction: json['responsableFonction'] as String?,
      responsableTelephone: json['responsableTelephone'] as String?,
      description: json['description'] as String,
      specialites: List<String>.from(json['specialites'] ?? []),
      anneesExperience: json['anneesExperience'] as int,
      noteMoyenne: (json['noteMoyenne'] as num).toDouble(),
      nombreAvis: json['nombreAvis'] as int,
      realisations: List<String>.from(json['realisations'] ?? []),
      zoneIntervention: List<String>.from(json['zoneIntervention'] ?? []),
      isVerified: json['isVerified'] as bool? ?? false,
      verificationStatus: json['verificationStatus'] as String? ?? 'DRAFT',
      verificationDate: json['verificationDate'] != null ? (json['verificationDate'] as Timestamp).toDate() : null,
      nifDocumentUrl: json['nifDocumentUrl'] as String?,
      rccmDocumentUrl: json['rccmDocumentUrl'] as String?,
      logoUrl: json['logoUrl'] as String?,
      prixMoyen: json['prixMoyen'] as String?,
      delaiMoyen: json['delaiMoyen'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'raisonSociale': raisonSociale,
      'nomCommercial': nomCommercial,
      'numeroImmatriculation': numeroImmatriculation,
      'formeJuridique': formeJuridique,
      'dateCreation': dateCreation != null ? Timestamp.fromDate(dateCreation!) : null,
      'adresseSiege': adresseSiege,
      'ville': ville,
      'region': region,
      'telephone': telephone,
      'emailProfessionnel': emailProfessionnel,
      'siteWeb': siteWeb,
      'responsableNom': responsableNom,
      'responsableFonction': responsableFonction,
      'responsableTelephone': responsableTelephone,
      'description': description,
      'specialites': specialites,
      'anneesExperience': anneesExperience,
      'noteMoyenne': noteMoyenne,
      'nombreAvis': nombreAvis,
      'realisations': realisations,
      'zoneIntervention': zoneIntervention,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'verificationDate': verificationDate != null ? Timestamp.fromDate(verificationDate!) : null,
      'nifDocumentUrl': nifDocumentUrl,
      'rccmDocumentUrl': rccmDocumentUrl,
      'logoUrl': logoUrl,
      'prixMoyen': prixMoyen,
      'delaiMoyen': delaiMoyen,
    };
  }

  EntrepriseModel copyWith({
    String? id,
    String? userId,
    String? raisonSociale,
    String? nomCommercial,
    String? numeroImmatriculation,
    String? formeJuridique,
    DateTime? dateCreation,
    String? adresseSiege,
    String? ville,
    String? region,
    String? telephone,
    String? emailProfessionnel,
    String? siteWeb,
    String? responsableNom,
    String? responsableFonction,
    String? responsableTelephone,
    String? description,
    List<String>? specialites,
    int? anneesExperience,
    double? noteMoyenne,
    int? nombreAvis,
    List<String>? realisations,
    List<String>? zoneIntervention,
    bool? isVerified,
    String? verificationStatus,
    DateTime? verificationDate,
    String? nifDocumentUrl,
    String? rccmDocumentUrl,
    String? logoUrl,
    String? prixMoyen,
    String? delaiMoyen,
  }) {
    return EntrepriseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      raisonSociale: raisonSociale ?? this.raisonSociale,
      nomCommercial: nomCommercial ?? this.nomCommercial,
      numeroImmatriculation: numeroImmatriculation ?? this.numeroImmatriculation,
      formeJuridique: formeJuridique ?? this.formeJuridique,
      dateCreation: dateCreation ?? this.dateCreation,
      adresseSiege: adresseSiege ?? this.adresseSiege,
      ville: ville ?? this.ville,
      region: region ?? this.region,
      telephone: telephone ?? this.telephone,
      emailProfessionnel: emailProfessionnel ?? this.emailProfessionnel,
      siteWeb: siteWeb ?? this.siteWeb,
      responsableNom: responsableNom ?? this.responsableNom,
      responsableFonction: responsableFonction ?? this.responsableFonction,
      responsableTelephone: responsableTelephone ?? this.responsableTelephone,
      description: description ?? this.description,
      specialites: specialites ?? this.specialites,
      anneesExperience: anneesExperience ?? this.anneesExperience,
      noteMoyenne: noteMoyenne ?? this.noteMoyenne,
      nombreAvis: nombreAvis ?? this.nombreAvis,
      realisations: realisations ?? this.realisations,
      zoneIntervention: zoneIntervention ?? this.zoneIntervention,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDate: verificationDate ?? this.verificationDate,
      nifDocumentUrl: nifDocumentUrl ?? this.nifDocumentUrl,
      rccmDocumentUrl: rccmDocumentUrl ?? this.rccmDocumentUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      prixMoyen: prixMoyen ?? this.prixMoyen,
      delaiMoyen: delaiMoyen ?? this.delaiMoyen,
    );
  }
}
