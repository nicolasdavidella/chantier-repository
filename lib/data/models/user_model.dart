// Firestore Structure:
// Root collection: 'users'
// Document ID: uid

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String role; // client, chef_chantier, entreprise, admin
  final String? photoUrl;
  final DateTime dateCreation;
  final Map<String, dynamic>? localisation;

  final bool isActive;
  final bool isVerified;

  UserModel({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.role,
    this.photoUrl,
    required this.dateCreation,
    this.localisation,
    this.isActive = true,
    this.isVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      nom: json['nom'] as String? ?? 'Utilisateur',
      prenom: json['prenom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      photoUrl: json['photoUrl'] as String?,
      dateCreation: (json['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      localisation: json['localisation'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'role': role,
      'photoUrl': photoUrl,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'localisation': localisation,
      'isActive': isActive,
      'isVerified': isVerified,
    };
  }

  UserModel copyWith({
    String? uid,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? role,
    String? photoUrl,
    DateTime? dateCreation,
    Map<String, dynamic>? localisation,
    bool? isActive,
    bool? isVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      dateCreation: dateCreation ?? this.dateCreation,
      localisation: localisation ?? this.localisation,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
