import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/devis_model.dart';

void main() {
  group('DevisModel', () {
    final dateEnvoi = DateTime(2023, 1, 1);
    
    final devis = DevisModel(
      id: 'devis1',
      projectId: 'proj1',
      entrepriseId: 'ent1',
      montant: 1500.50,
      delaiEstime: '3 semaines',
      description: 'Devis pour fondations',
      dateEnvoi: dateEnvoi,
      statut: 'en_attente',
      fichierPdfUrl: 'http://example.com/devis.pdf',
    );

    test('toJson should return a valid map', () {
      final json = devis.toJson();

      expect(json['id'], 'devis1');
      expect(json['projectId'], 'proj1');
      expect(json['entrepriseId'], 'ent1');
      expect(json['montant'], 1500.50);
      expect(json['delaiEstime'], '3 semaines');
      expect(json['description'], 'Devis pour fondations');
      expect(json['dateEnvoi'], isA<Timestamp>());
      expect(json['statut'], 'en_attente');
      expect(json['fichierPdfUrl'], 'http://example.com/devis.pdf');
    });

    test('fromJson should return a valid DevisModel', () {
      final json = {
        'id': 'devis1',
        'projectId': 'proj1',
        'entrepriseId': 'ent1',
        'montant': 1500.50,
        'delaiEstime': '3 semaines',
        'description': 'Devis pour fondations',
        'dateEnvoi': Timestamp.fromDate(dateEnvoi),
        'statut': 'en_attente',
        'fichierPdfUrl': 'http://example.com/devis.pdf',
      };

      final result = DevisModel.fromJson(json);

      expect(result.id, 'devis1');
      expect(result.montant, 1500.50);
      expect(result.dateEnvoi, dateEnvoi);
      expect(result.statut, 'en_attente');
    });

    test('copyWith should copy properties correctly', () {
      final copied = devis.copyWith(
        statut: 'accepte',
        montant: 1600.0,
      );

      expect(copied.id, 'devis1');
      expect(copied.statut, 'accepte');
      expect(copied.montant, 1600.0);
    });
  });
}
