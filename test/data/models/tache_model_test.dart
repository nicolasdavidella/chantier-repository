import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/tache_model.dart';

void main() {
  group('TacheModel', () {
    final debut = DateTime(2023, 1, 1);
    final fin = DateTime(2023, 1, 10);
    final finReelle = DateTime(2023, 1, 12);
    
    final tache = TacheModel(
      id: 'tache1',
      projectId: 'proj1',
      titre: 'Fondations',
      description: 'Couler le béton',
      statut: 'en_cours',
      dateDebutPrevue: debut,
      dateFinPrevue: fin,
      dateFinReelle: finReelle,
      responsable: 'Entreprise A',
      ordre: 1,
    );

    test('toJson should return a valid map', () {
      final json = tache.toJson();

      expect(json['id'], 'tache1');
      expect(json['projectId'], 'proj1');
      expect(json['titre'], 'Fondations');
      expect(json['description'], 'Couler le béton');
      expect(json['statut'], 'en_cours');
      expect(json['dateDebutPrevue'], isA<Timestamp>());
      expect(json['dateFinPrevue'], isA<Timestamp>());
      expect(json['dateFinReelle'], isA<Timestamp>());
      expect(json['responsable'], 'Entreprise A');
      expect(json['ordre'], 1);
    });

    test('fromJson should return a valid TacheModel', () {
      final json = {
        'id': 'tache1',
        'projectId': 'proj1',
        'titre': 'Fondations',
        'description': 'Couler le béton',
        'statut': 'en_cours',
        'dateDebutPrevue': Timestamp.fromDate(debut),
        'dateFinPrevue': Timestamp.fromDate(fin),
        'dateFinReelle': Timestamp.fromDate(finReelle),
        'responsable': 'Entreprise A',
        'ordre': 1,
      };

      final result = TacheModel.fromJson(json);

      expect(result.id, 'tache1');
      expect(result.titre, 'Fondations');
      expect(result.dateDebutPrevue, debut);
      expect(result.dateFinReelle, finReelle);
      expect(result.ordre, 1);
    });

    test('copyWith should copy properties correctly', () {
      final copied = tache.copyWith(
        statut: 'terminee',
        ordre: 2,
      );

      expect(copied.id, 'tache1');
      expect(copied.statut, 'terminee');
      expect(copied.ordre, 2);
    });
  });
}
