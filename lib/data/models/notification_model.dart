// Firestore Structure:
// Root collection: 'notifications' (Or 'users' -> 'notifications')
// Document ID: id

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String titre;
  final String corps;
  final String type;
  final String? lienVersEcran;
  final DateTime dateEnvoi;
  final bool lu;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.titre,
    required this.corps,
    required this.type,
    this.lienVersEcran,
    required this.dateEnvoi,
    required this.lu,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      titre: json['titre'] as String,
      corps: json['corps'] as String,
      type: json['type'] as String,
      lienVersEcran: json['lienVersEcran'] as String?,
      dateEnvoi: (json['dateEnvoi'] as Timestamp).toDate(),
      lu: json['lu'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'titre': titre,
      'corps': corps,
      'type': type,
      'lienVersEcran': lienVersEcran,
      'dateEnvoi': Timestamp.fromDate(dateEnvoi),
      'lu': lu,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? titre,
    String? corps,
    String? type,
    String? lienVersEcran,
    DateTime? dateEnvoi,
    bool? lu,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titre: titre ?? this.titre,
      corps: corps ?? this.corps,
      type: type ?? this.type,
      lienVersEcran: lienVersEcran ?? this.lienVersEcran,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      lu: lu ?? this.lu,
    );
  }
}
