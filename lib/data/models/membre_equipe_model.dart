// Firestore Structure:
// Root collection: 'membres_equipe'
// Document ID: id
// Filtré par entrepriseId

import 'package:cloud_firestore/cloud_firestore.dart';

class MembreEquipeModel {
  final String id;
  final String entrepriseId;
  final String nom;
  final String prenom;
  final String metier; // Chef de chantier, Architecte, Électricien, Plombier, Peintre, Maçon, Autre
  final String telephone;
  final String? email;
  final String? photoUrl;
  final String statut; // actif, inactif
  final DateTime dateAjout;
  final List<String> projetsAssignes; // liste de projectId

  MembreEquipeModel({
    required this.id,
    required this.entrepriseId,
    required this.nom,
    required this.prenom,
    required this.metier,
    required this.telephone,
    this.email,
    this.photoUrl,
    this.statut = 'actif',
    required this.dateAjout,
    this.projetsAssignes = const [],
  });

  factory MembreEquipeModel.fromJson(Map<String, dynamic> json) {
    return MembreEquipeModel(
      id: json['id'] as String,
      entrepriseId: json['entrepriseId'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      metier: json['metier'] as String,
      telephone: json['telephone'] as String,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      statut: json['statut'] as String? ?? 'actif',
      dateAjout: (json['dateAjout'] as Timestamp).toDate(),
      projetsAssignes: List<String>.from(json['projetsAssignes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entrepriseId': entrepriseId,
      'nom': nom,
      'prenom': prenom,
      'metier': metier,
      'telephone': telephone,
      'email': email,
      'photoUrl': photoUrl,
      'statut': statut,
      'dateAjout': Timestamp.fromDate(dateAjout),
      'projetsAssignes': projetsAssignes,
    };
  }

  MembreEquipeModel copyWith({
    String? id,
    String? entrepriseId,
    String? nom,
    String? prenom,
    String? metier,
    String? telephone,
    String? email,
    String? photoUrl,
    String? statut,
    DateTime? dateAjout,
    List<String>? projetsAssignes,
  }) {
    return MembreEquipeModel(
      id: id ?? this.id,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      metier: metier ?? this.metier,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      statut: statut ?? this.statut,
      dateAjout: dateAjout ?? this.dateAjout,
      projetsAssignes: projetsAssignes ?? this.projetsAssignes,
    );
  }
}
