import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    final date = DateTime(2023, 1, 1);
    
    final notif = NotificationModel(
      id: 'notif1',
      userId: 'user1',
      titre: 'Nouveau message',
      corps: 'Vous avez reçu un message',
      type: 'message',
      dateEnvoi: date,
      lu: false,
    );

    test('toJson should return a valid map', () {
      final json = notif.toJson();

      expect(json['id'], 'notif1');
      expect(json['userId'], 'user1');
      expect(json['titre'], 'Nouveau message');
      expect(json['corps'], 'Vous avez reçu un message');
      expect(json['type'], 'message');
      expect(json['dateEnvoi'], isA<Timestamp>());
      expect(json['lu'], false);
    });

    test('fromJson should return a valid NotificationModel', () {
      final json = {
        'id': 'notif1',
        'userId': 'user1',
        'titre': 'Nouveau message',
        'corps': 'Vous avez reçu un message',
        'type': 'message',
        'dateEnvoi': Timestamp.fromDate(date),
        'lu': false,
      };

      final result = NotificationModel.fromJson(json);

      expect(result.id, 'notif1');
      expect(result.dateEnvoi, date);
      expect(result.lu, false);
    });

    test('copyWith should copy properties correctly', () {
      final copied = notif.copyWith(
        lu: true,
      );

      expect(copied.id, 'notif1');
      expect(copied.lu, true);
    });
  });
}
