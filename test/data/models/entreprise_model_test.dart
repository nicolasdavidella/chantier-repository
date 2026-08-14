import 'package:flutter_test/flutter_test.dart';
import 'package:chantier_track/data/models/entreprise_model.dart';

void main() {
  group('EntrepriseModel', () {
    final entreprise = EntrepriseModel(
      id: 'ent1',
      userId: 'user2',
      raisonSociale: 'SuperBTP',
      description: 'Entreprise de construction',
      specialites: ['Maçonnerie', 'Plomberie'],
      anneesExperience: 10,
      noteMoyenne: 4.5,
      nombreAvis: 20,
      realisations: ['projet1', 'projet2'],
      zoneIntervention: ['Paris', 'Lyon'],
      certifie: true,
      prixMoyen: '\$\$',
    );

    test('toJson should return a valid map', () {
      final json = entreprise.toJson();

      expect(json['id'], 'ent1');
      expect(json['userId'], 'user2');
      expect(json['raisonSociale'], 'SuperBTP');
      expect(json['description'], 'Entreprise de construction');
      expect(json['specialites'], ['Maçonnerie', 'Plomberie']);
      expect(json['anneesExperience'], 10);
      expect(json['noteMoyenne'], 4.5);
      expect(json['nombreAvis'], 20);
      expect(json['realisations'], ['projet1', 'projet2']);
      expect(json['zoneIntervention'], ['Paris', 'Lyon']);
      expect(json['certifie'], true);
      expect(json['prixMoyen'], '\$\$');
    });

    test('fromJson should return a valid EntrepriseModel', () {
      final json = {
        'id': 'ent1',
        'userId': 'user2',
        'raisonSociale': 'SuperBTP',
        'description': 'Entreprise de construction',
        'specialites': ['Maçonnerie', 'Plomberie'],
        'anneesExperience': 10,
        'noteMoyenne': 4.5,
        'nombreAvis': 20,
        'realisations': ['projet1', 'projet2'],
        'zoneIntervention': ['Paris', 'Lyon'],
        'certifie': true,
        'prixMoyen': '\$\$',
      };

      final result = EntrepriseModel.fromJson(json);

      expect(result.id, 'ent1');
      expect(result.raisonSociale, 'SuperBTP');
      expect(result.anneesExperience, 10);
      expect(result.noteMoyenne, 4.5);
      expect(result.specialites, ['Maçonnerie', 'Plomberie']);
    });

    test('copyWith should copy properties correctly', () {
      final copied = entreprise.copyWith(
        noteMoyenne: 4.8,
        nombreAvis: 21,
      );

      expect(copied.id, 'ent1');
      expect(copied.noteMoyenne, 4.8);
      expect(copied.nombreAvis, 21);
    });
  });
}
