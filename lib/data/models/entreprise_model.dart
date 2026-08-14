// Firestore Structure:
// Root collection: 'entreprises'
// Document ID: id

class EntrepriseModel {
  final String id;
  final String userId;
  final String raisonSociale;
  final String description;
  final List<String> specialites;
  final int anneesExperience;
  final double noteMoyenne;
  final int nombreAvis;
  final List<String> realisations;
  final List<String> zoneIntervention;
  final bool certifie;
  final String? prixMoyen;
  final String? delaiMoyen;

  EntrepriseModel({
    required this.id,
    required this.userId,
    required this.raisonSociale,
    required this.description,
    required this.specialites,
    required this.anneesExperience,
    required this.noteMoyenne,
    required this.nombreAvis,
    required this.realisations,
    required this.zoneIntervention,
    required this.certifie,
    this.prixMoyen,
    this.delaiMoyen,
  });

  factory EntrepriseModel.fromJson(Map<String, dynamic> json) {
    return EntrepriseModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      raisonSociale: json['raisonSociale'] as String,
      description: json['description'] as String,
      specialites: List<String>.from(json['specialites'] ?? []),
      anneesExperience: json['anneesExperience'] as int,
      noteMoyenne: (json['noteMoyenne'] as num).toDouble(),
      nombreAvis: json['nombreAvis'] as int,
      realisations: List<String>.from(json['realisations'] ?? []),
      zoneIntervention: List<String>.from(json['zoneIntervention'] ?? []),
      certifie: json['certifie'] as bool? ?? false,
      prixMoyen: json['prixMoyen'] as String?,
      delaiMoyen: json['delaiMoyen'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'raisonSociale': raisonSociale,
      'description': description,
      'specialites': specialites,
      'anneesExperience': anneesExperience,
      'noteMoyenne': noteMoyenne,
      'nombreAvis': nombreAvis,
      'realisations': realisations,
      'zoneIntervention': zoneIntervention,
      'certifie': certifie,
      'prixMoyen': prixMoyen,
      'delaiMoyen': delaiMoyen,
    };
  }

  EntrepriseModel copyWith({
    String? id,
    String? userId,
    String? raisonSociale,
    String? description,
    List<String>? specialites,
    int? anneesExperience,
    double? noteMoyenne,
    int? nombreAvis,
    List<String>? realisations,
    List<String>? zoneIntervention,
    bool? certifie,
    String? prixMoyen,
    String? delaiMoyen,
  }) {
    return EntrepriseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      raisonSociale: raisonSociale ?? this.raisonSociale,
      description: description ?? this.description,
      specialites: specialites ?? this.specialites,
      anneesExperience: anneesExperience ?? this.anneesExperience,
      noteMoyenne: noteMoyenne ?? this.noteMoyenne,
      nombreAvis: nombreAvis ?? this.nombreAvis,
      realisations: realisations ?? this.realisations,
      zoneIntervention: zoneIntervention ?? this.zoneIntervention,
      certifie: certifie ?? this.certifie,
      prixMoyen: prixMoyen ?? this.prixMoyen,
      delaiMoyen: delaiMoyen ?? this.delaiMoyen,
    );
  }
}
