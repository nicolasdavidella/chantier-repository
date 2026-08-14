import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final date = DateTime(2023, 1, 1);
    final user = UserModel(
      uid: 'user123',
      nom: 'Doe',
      prenom: 'John',
      email: 'john.doe@example.com',
      telephone: '0102030405',
      role: 'client',
      photoUrl: 'http://example.com/photo.jpg',
      dateCreation: date,
      localisation: {'lat': 48.8566, 'lng': 2.3522},
    );

    test('toJson should return a valid map', () {
      final json = user.toJson();

      expect(json['uid'], 'user123');
      expect(json['nom'], 'Doe');
      expect(json['prenom'], 'John');
      expect(json['email'], 'john.doe@example.com');
      expect(json['telephone'], '0102030405');
      expect(json['role'], 'client');
      expect(json['photoUrl'], 'http://example.com/photo.jpg');
      expect(json['dateCreation'], isA<Timestamp>());
      expect(json['localisation'], {'lat': 48.8566, 'lng': 2.3522});
    });

    test('fromJson should return a valid UserModel', () {
      final json = {
        'uid': 'user123',
        'nom': 'Doe',
        'prenom': 'John',
        'email': 'john.doe@example.com',
        'telephone': '0102030405',
        'role': 'client',
        'photoUrl': 'http://example.com/photo.jpg',
        'dateCreation': Timestamp.fromDate(date),
        'localisation': {'lat': 48.8566, 'lng': 2.3522},
      };

      final result = UserModel.fromJson(json);

      expect(result.uid, 'user123');
      expect(result.nom, 'Doe');
      expect(result.prenom, 'John');
      expect(result.email, 'john.doe@example.com');
      expect(result.telephone, '0102030405');
      expect(result.role, 'client');
      expect(result.photoUrl, 'http://example.com/photo.jpg');
      expect(result.dateCreation, date);
      expect(result.localisation, {'lat': 48.8566, 'lng': 2.3522});
    });

    test('copyWith should copy properties correctly', () {
      final copied = user.copyWith(
        nom: 'Smith',
        role: 'admin',
      );

      expect(copied.uid, 'user123'); // Unchanged
      expect(copied.nom, 'Smith'); // Changed
      expect(copied.prenom, 'John'); // Unchanged
      expect(copied.role, 'admin'); // Changed
    });
  });
}
