import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/avis_model.dart';

void main() {
  group('AvisModel', () {
    final date = DateTime(2023, 1, 1);
    
    final avis = AvisModel(
      id: 'avis1',
      targetId: 'ent1',
      targetType: 'entreprise',
      clientId: 'client1',
      projectId: 'proj1',
      note: 4.5,
      criteres: {'qualite': 5, 'delais': 4},
      commentaire: 'Très bon travail',
      dateCreation: date,
      reponseEntreprise: 'Merci',
      signale: false,
    );

    test('toJson should return a valid map', () {
      final json = avis.toJson();

      expect(json['id'], 'avis1');
      expect(json['targetId'], 'ent1');
      expect(json['targetType'], 'entreprise');
      expect(json['clientId'], 'client1');
      expect(json['projectId'], 'proj1');
      expect(json['note'], 4.5);
      expect(json['criteres'], {'qualite': 5, 'delais': 4});
      expect(json['commentaire'], 'Très bon travail');
      expect(json['dateCreation'], isA<Timestamp>());
      expect(json['reponseEntreprise'], 'Merci');
      expect(json['signale'], false);
    });

    test('fromJson should return a valid AvisModel', () {
      final json = {
        'id': 'avis1',
        'targetId': 'ent1',
        'targetType': 'entreprise',
        'clientId': 'client1',
        'projectId': 'proj1',
        'note': 4.5,
        'criteres': {'qualite': 5, 'delais': 4},
        'commentaire': 'Très bon travail',
        'dateCreation': Timestamp.fromDate(date),
        'reponseEntreprise': 'Merci',
        'signale': false,
      };

      final result = AvisModel.fromJson(json);

      expect(result.id, 'avis1');
      expect(result.note, 4.5);
      expect(result.criteres, {'qualite': 5, 'delais': 4});
      expect(result.dateCreation, date);
    });

    test('copyWith should copy properties correctly', () {
      final copied = avis.copyWith(
        signale: true,
      );

      expect(copied.id, 'avis1');
      expect(copied.signale, true);
    });
  });
}
