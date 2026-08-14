import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/project_model.dart';

void main() {
  group('ProjectModel', () {
    final debut = DateTime(2023, 1, 1);
    final fin = DateTime(2023, 12, 31);
    
    final project = ProjectModel(
      id: 'proj1',
      clientId: 'client1',
      entrepriseId: 'ent1',
      titre: 'Maison',
      description: 'Construction',
      localisation: {'ville': 'Paris', 'lat': 48.8, 'lng': 2.3},
      budgetPrevisionnel: 100000.0,
      budgetActuel: 50000.0,
      dateDebut: debut,
      dateFinPrevue: fin,
      statut: 'en_cours',
      listePlans: ['plan1.pdf'],
      listeDocuments: ['doc1.pdf'],
    );

    test('toJson should return a valid map', () {
      final json = project.toJson();

      expect(json['id'], 'proj1');
      expect(json['clientId'], 'client1');
      expect(json['entrepriseId'], 'ent1');
      expect(json['titre'], 'Maison');
      expect(json['description'], 'Construction');
      expect(json['localisation'], {'ville': 'Paris', 'lat': 48.8, 'lng': 2.3});
      expect(json['budgetPrevisionnel'], 100000.0);
      expect(json['budgetActuel'], 50000.0);
      expect(json['dateDebut'], isA<Timestamp>());
      expect(json['dateFinPrevue'], isA<Timestamp>());
      expect(json['statut'], 'en_cours');
      expect(json['listePlans'], ['plan1.pdf']);
      expect(json['listeDocuments'], ['doc1.pdf']);
    });

    test('fromJson should return a valid ProjectModel', () {
      final json = {
        'id': 'proj1',
        'clientId': 'client1',
        'entrepriseId': 'ent1',
        'titre': 'Maison',
        'description': 'Construction',
        'localisation': {'ville': 'Paris', 'lat': 48.8, 'lng': 2.3},
        'budgetPrevisionnel': 100000.0,
        'budgetActuel': 50000.0,
        'dateDebut': Timestamp.fromDate(debut),
        'dateFinPrevue': Timestamp.fromDate(fin),
        'statut': 'en_cours',
        'listePlans': ['plan1.pdf'],
        'listeDocuments': ['doc1.pdf'],
      };

      final result = ProjectModel.fromJson(json);

      expect(result.id, 'proj1');
      expect(result.titre, 'Maison');
      expect(result.budgetPrevisionnel, 100000.0);
      expect(result.dateDebut, debut);
      expect(result.listePlans, ['plan1.pdf']);
    });

    test('copyWith should copy properties correctly', () {
      final copied = project.copyWith(
        statut: 'termine',
        budgetActuel: 100000.0,
      );

      expect(copied.id, 'proj1');
      expect(copied.statut, 'termine');
      expect(copied.budgetActuel, 100000.0);
    });
  });
}
