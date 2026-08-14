// Firestore Structure:
// Root collection: 'projects' -> Sub-collection: 'rapports'
// Document ID: id

import 'package:cloud_firestore/cloud_firestore.dart';

class RapportAvancementModel {
  final String id;
  final String projectId;
  final String chefChantierId;
  final DateTime date;
  final List<String> photos;
  final List<String> videos;
  final String description;
  final double pourcentageAvancement;
  final List<String> tachesConcernees;

  RapportAvancementModel({
    required this.id,
    required this.projectId,
    required this.chefChantierId,
    required this.date,
    required this.photos,
    required this.videos,
    required this.description,
    required this.pourcentageAvancement,
    required this.tachesConcernees,
  });

  factory RapportAvancementModel.fromJson(Map<String, dynamic> json) {
    return RapportAvancementModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      chefChantierId: json['chefChantierId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      photos: List<String>.from(json['photos'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      description: json['description'] as String,
      pourcentageAvancement: (json['pourcentageAvancement'] as num).toDouble(),
      tachesConcernees: List<String>.from(json['tachesConcernees'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'chefChantierId': chefChantierId,
      'date': Timestamp.fromDate(date),
      'photos': photos,
      'videos': videos,
      'description': description,
      'pourcentageAvancement': pourcentageAvancement,
      'tachesConcernees': tachesConcernees,
    };
  }

  RapportAvancementModel copyWith({
    String? id,
    String? projectId,
    String? chefChantierId,
    DateTime? date,
    List<String>? photos,
    List<String>? videos,
    String? description,
    double? pourcentageAvancement,
    List<String>? tachesConcernees,
  }) {
    return RapportAvancementModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      chefChantierId: chefChantierId ?? this.chefChantierId,
      date: date ?? this.date,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      description: description ?? this.description,
      pourcentageAvancement: pourcentageAvancement ?? this.pourcentageAvancement,
      tachesConcernees: tachesConcernees ?? this.tachesConcernees,
    );
  }
}
