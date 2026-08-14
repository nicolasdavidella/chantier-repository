import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/depense_model.dart';

void main() {
  group('DepenseModel', () {
    final dateDeclaration = DateTime(2023, 1, 1);
    
    final depense = DepenseModel(
      id: 'dep1',
      projectId: 'proj1',
      categorie: 'materiaux',
      montant: 500.0,
      description: 'Achat de ciment',
      justificatifUrl: 'http://example.com/facture.jpg',
      dateDeclaration: dateDeclaration,
      declarantId: 'user1',
      statut: 'en_attente',
      coordonneesGPS: {'lat': 10.0, 'lng': 20.0},
    );

    test('toJson should return a valid map', () {
      final json = depense.toJson();

      expect(json['id'], 'dep1');
      expect(json['projectId'], 'proj1');
      expect(json['categorie'], 'materiaux');
      expect(json['montant'], 500.0);
      expect(json['description'], 'Achat de ciment');
      expect(json['justificatifUrl'], 'http://example.com/facture.jpg');
      expect(json['dateDeclaration'], isA<Timestamp>());
      expect(json['declarantId'], 'user1');
      expect(json['statut'], 'en_attente');
      expect(json['coordonneesGPS'], {'lat': 10.0, 'lng': 20.0});
    });

    test('fromJson should return a valid DepenseModel', () {
      final json = {
        'id': 'dep1',
        'projectId': 'proj1',
        'categorie': 'materiaux',
        'montant': 500.0,
        'description': 'Achat de ciment',
        'justificatifUrl': 'http://example.com/facture.jpg',
        'dateDeclaration': Timestamp.fromDate(dateDeclaration),
        'declarantId': 'user1',
        'statut': 'en_attente',
        'coordonneesGPS': {'lat': 10.0, 'lng': 20.0},
      };

      final result = DepenseModel.fromJson(json);

      expect(result.id, 'dep1');
      expect(result.montant, 500.0);
      expect(result.dateDeclaration, dateDeclaration);
      expect(result.statut, 'en_attente');
      expect(result.coordonneesGPS, {'lat': 10.0, 'lng': 20.0});
    });

    test('copyWith should copy properties correctly', () {
      final copied = depense.copyWith(
        statut: 'validee',
      );

      expect(copied.id, 'dep1');
      expect(copied.statut, 'validee');
      expect(copied.montant, 500.0);
    });
  });
}
