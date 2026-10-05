import 'package:flutter_test/flutter_test.dart';
import 'package:chantier_track/data/models/conversation_model.dart';
import 'package:chantier_track/data/models/message_model.dart';
import 'package:chantier_track/data/models/entreprise_model.dart';
import 'package:chantier_track/data/models/diffusion_projet_model.dart';
import 'package:chantier_track/data/models/marketplace_applicant_model.dart';

void main() {
  group('Chat & Marketplace Models & Logic Tests', () {
    test('ConversationModel creates and serializes participant names and initial project message', () {
      final now = DateTime.now();
      final conv = ConversationModel(
        id: 'conv_123',
        participantsIds: ['client_uid_1', 'entreprise_uid_2'],
        participantNames: {
          'client_uid_1': 'Marc Dubois',
          'entreprise_uid_2': 'Construction Piolo',
        },
        participantAvatars: {
          'client_uid_1': null,
          'entreprise_uid_2': 'https://example.com/logo.png',
        },
        projectId: 'proj_villa_123',
        lastMessage: 'Bonjour Construction Piolo, je vous contacte au sujet du projet Villa Moderne.',
        lastMessageTime: now,
        unreadCount: {
          'client_uid_1': 0,
          'entreprise_uid_2': 1,
        },
      );

      final json = conv.toJson();
      expect(json['id'], equals('conv_123'));
      expect(json['participantsIds'], containsAll(['client_uid_1', 'entreprise_uid_2']));
      expect(json['participantNames']['client_uid_1'], equals('Marc Dubois'));
      expect(json['participantNames']['entreprise_uid_2'], equals('Construction Piolo'));
      expect(json['projectId'], equals('proj_villa_123'));
      expect(json['unreadCount']['entreprise_uid_2'], equals(1));

      final restored = ConversationModel.fromJson(json);
      expect(restored.id, equals(conv.id));
      expect(restored.participantNames['client_uid_1'], equals('Marc Dubois'));
      expect(restored.participantNames['entreprise_uid_2'], equals('Construction Piolo'));
      expect(restored.projectId, equals('proj_villa_123'));
    });

    test('MessageModel serializes and deserializes properly', () {
      final now = DateTime.now();
      final msg = MessageModel(
        id: 'msg_001',
        conversationId: 'conv_123',
        expediteurId: 'client_uid_1',
        contenu: 'Voici les spécifications pour la toiture en tuile.',
        dateEnvoi: now,
        type: 'texte',
        status: 'sent',
        lu: false,
      );

      final json = msg.toJson();
      expect(json['id'], equals('msg_001'));
      expect(json['expediteurId'], equals('client_uid_1'));
      expect(json['contenu'], equals('Voici les spécifications pour la toiture en tuile.'));

      final restored = MessageModel.fromJson(json);
      expect(restored.id, equals(msg.id));
      expect(restored.contenu, equals(msg.contenu));
      expect(restored.expediteurId, equals('client_uid_1'));
    });

    test('MarketplaceApplicantModel preserves real entreprise name and details', () {
      final entreprise = EntrepriseModel(
        id: 'ent_001',
        userId: 'ent_user_uid',
        raisonSociale: 'Construction Piolo & Frères',
        description: 'BTP et gros œuvre',
        specialites: ['Maçonnerie', 'Béton armé'],
        anneesExperience: 8,
        noteMoyenne: 4.9,
        nombreAvis: 12,
        realisations: [],
        zoneIntervention: ['Yaoundé', 'Douala'],
        isVerified: true,
        verificationStatus: 'APPROVED',
      );

      final diffusion = DiffusionProjetModel(
        id: 'proj_1_ent_user_uid',
        projectId: 'proj_1',
        clientId: 'client_uid',
        entrepriseId: 'ent_user_uid',
        statut: 'accepte',
        dateEnvoi: DateTime.now(),
        commentaire: 'Équipe prête à démarrer',
        devisEstime: 35000000.0,
      );

      final applicant = MarketplaceApplicantModel(
        entreprise: entreprise,
        diffusion: diffusion,
      );

      expect(applicant.entreprise.raisonSociale, equals('Construction Piolo & Frères'));
      expect(applicant.diffusion.statut, equals('accepte'));
      expect(applicant.diffusion.devisEstime, equals(35000000.0));
      expect(applicant.entreprise.isVerified, isTrue);
    });
  });
}
