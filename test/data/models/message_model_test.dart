import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/message_model.dart';

void main() {
  group('MessageModel', () {
    final date = DateTime(2023, 1, 1);
    
    final message = MessageModel(
      id: 'msg1',
      conversationId: 'conv1',
      expediteurId: 'user1',
      contenu: 'Bonjour',
      dateEnvoi: date,
      type: 'texte',
      status: 'sent',
      lu: false,
    );

    test('toJson should return a valid map', () {
      final json = message.toJson();

      expect(json['id'], 'msg1');
      expect(json['conversationId'], 'conv1');
      expect(json['expediteurId'], 'user1');
      expect(json['contenu'], 'Bonjour');
      expect(json['dateEnvoi'], isA<Timestamp>());
      expect(json['type'], 'texte');
      expect(json['status'], 'sent');
      expect(json['lu'], false);
    });

    test('fromJson should return a valid MessageModel', () {
      final json = {
        'id': 'msg1',
        'conversationId': 'conv1',
        'expediteurId': 'user1',
        'contenu': 'Bonjour',
        'dateEnvoi': Timestamp.fromDate(date),
        'type': 'texte',
        'status': 'sent',
        'lu': false,
      };

      final result = MessageModel.fromJson(json);

      expect(result.id, 'msg1');
      expect(result.dateEnvoi, date);
      expect(result.lu, false);
      expect(result.type, 'texte');
    });

    test('copyWith should copy properties correctly', () {
      final copied = message.copyWith(
        lu: true,
        status: 'read',
      );

      expect(copied.id, 'msg1');
      expect(copied.lu, true);
      expect(copied.status, 'read');
    });
  });
}
