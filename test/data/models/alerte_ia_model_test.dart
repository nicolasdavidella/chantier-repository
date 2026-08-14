import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/alerte_ia_model.dart';

void main() {
  group('AlerteIAModel', () {
    final date = DateTime(2023, 1, 1);
    
    final alerte = AlerteIAModel(
      id: 'alerte1',
      projectId: 'proj1',
      type: 'risque_retard',
      gravite: 'elevee',
      description: 'Retard possible sur les fondations',
      dateDetection: date,
      statut: 'nouvelle',
    );

    test('toJson should return a valid map', () {
      final json = alerte.toJson();

      expect(json['id'], 'alerte1');
      expect(json['projectId'], 'proj1');
      expect(json['type'], 'risque_retard');
      expect(json['gravite'], 'elevee');
      expect(json['description'], 'Retard possible sur les fondations');
      expect(json['dateDetection'], isA<Timestamp>());
      expect(json['statut'], 'nouvelle');
    });

    test('fromJson should return a valid AlerteIAModel', () {
      final json = {
        'id': 'alerte1',
        'projectId': 'proj1',
        'type': 'risque_retard',
        'gravite': 'elevee',
        'description': 'Retard possible sur les fondations',
        'dateDetection': Timestamp.fromDate(date),
        'statut': 'nouvelle',
      };

      final result = AlerteIAModel.fromJson(json);

      expect(result.id, 'alerte1');
      expect(result.dateDetection, date);
      expect(result.type, 'risque_retard');
    });

    test('copyWith should copy properties correctly', () {
      final copied = alerte.copyWith(
        statut: 'traitee',
      );

      expect(copied.id, 'alerte1');
      expect(copied.statut, 'traitee');
    });
  });
}
