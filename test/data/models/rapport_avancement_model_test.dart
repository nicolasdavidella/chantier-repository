import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/rapport_avancement_model.dart';

void main() {
  group('RapportAvancementModel', () {
    final date = DateTime(2023, 1, 1);
    
    final rapport = RapportAvancementModel(
      id: 'rap1',
      projectId: 'proj1',
      chefChantierId: 'chef1',
      date: date,
      photos: ['photo1.jpg'],
      videos: ['video1.mp4'],
      description: 'Tout avance bien',
      pourcentageAvancement: 50.0,
      tachesConcernees: ['tache1', 'tache2'],
    );

    test('toJson should return a valid map', () {
      final json = rapport.toJson();

      expect(json['id'], 'rap1');
      expect(json['projectId'], 'proj1');
      expect(json['chefChantierId'], 'chef1');
      expect(json['date'], isA<Timestamp>());
      expect(json['photos'], ['photo1.jpg']);
      expect(json['videos'], ['video1.mp4']);
      expect(json['description'], 'Tout avance bien');
      expect(json['pourcentageAvancement'], 50.0);
      expect(json['tachesConcernees'], ['tache1', 'tache2']);
    });

    test('fromJson should return a valid RapportAvancementModel', () {
      final json = {
        'id': 'rap1',
        'projectId': 'proj1',
        'chefChantierId': 'chef1',
        'date': Timestamp.fromDate(date),
        'photos': ['photo1.jpg'],
        'videos': ['video1.mp4'],
        'description': 'Tout avance bien',
        'pourcentageAvancement': 50.0,
        'tachesConcernees': ['tache1', 'tache2'],
      };

      final result = RapportAvancementModel.fromJson(json);

      expect(result.id, 'rap1');
      expect(result.date, date);
      expect(result.pourcentageAvancement, 50.0);
      expect(result.photos, ['photo1.jpg']);
    });

    test('copyWith should copy properties correctly', () {
      final copied = rapport.copyWith(
        pourcentageAvancement: 60.0,
      );

      expect(copied.id, 'rap1');
      expect(copied.pourcentageAvancement, 60.0);
    });
  });
}
