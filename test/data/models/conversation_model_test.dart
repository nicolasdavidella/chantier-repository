import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/conversation_model.dart';

void main() {
  group('ConversationModel', () {
    final date = DateTime(2023, 1, 1);
    
    final conv = ConversationModel(
      id: 'conv1',
      participantsIds: ['user1', 'user2'],
      participantNames: {'user1': 'John', 'user2': 'Jane'},
      participantAvatars: {'user1': 'url1', 'user2': null},
      projectId: 'proj1',
      lastMessage: 'Hello',
      lastMessageTime: date,
      unreadCount: {'user1': 0, 'user2': 1},
    );

    test('toJson should return a valid map', () {
      final json = conv.toJson();

      expect(json['id'], 'conv1');
      expect(json['participantsIds'], ['user1', 'user2']);
      expect(json['participantNames'], {'user1': 'John', 'user2': 'Jane'});
      expect(json['participantAvatars'], {'user1': 'url1', 'user2': null});
      expect(json['projectId'], 'proj1');
      expect(json['lastMessage'], 'Hello');
      expect(json['lastMessageTime'], isA<Timestamp>());
      expect(json['unreadCount'], {'user1': 0, 'user2': 1});
    });

    test('fromJson should return a valid ConversationModel', () {
      final json = {
        'id': 'conv1',
        'participantsIds': ['user1', 'user2'],
        'participantNames': {'user1': 'John', 'user2': 'Jane'},
        'participantAvatars': {'user1': 'url1', 'user2': null},
        'projectId': 'proj1',
        'lastMessage': 'Hello',
        'lastMessageTime': Timestamp.fromDate(date),
        'unreadCount': {'user1': 0, 'user2': 1},
      };

      final result = ConversationModel.fromJson(json);

      expect(result.id, 'conv1');
      expect(result.lastMessage, 'Hello');
      expect(result.lastMessageTime, date);
      expect(result.participantsIds, ['user1', 'user2']);
      expect(result.unreadCount, {'user1': 0, 'user2': 1});
    });

    test('copyWith should copy properties correctly', () {
      final copied = conv.copyWith(
        lastMessage: 'Bye',
      );

      expect(copied.id, 'conv1');
      expect(copied.lastMessage, 'Bye');
    });
  });
}
