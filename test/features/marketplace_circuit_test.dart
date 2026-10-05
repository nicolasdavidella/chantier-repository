import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/project_model.dart';
import 'package:chantier_track/data/models/diffusion_projet_model.dart';
import 'package:chantier_track/data/models/entreprise_model.dart';
import 'package:chantier_track/data/models/marketplace_applicant_model.dart';
import 'package:chantier_track/data/models/user_model.dart';

void main() {
  group('Marketplace End-to-End Circuit & Data Integrity Test', () {
    test('1. Creation & Serialization of AI-Generated Marketplace Project', () {
      final now = DateTime.now();
      final aiProject = ProjectModel(
        id: 'proj_ia_123',
        clientId: 'client_001',
        titre: 'Villa Moderne R+1 avec Piscine',
        description: 'Plan 3D et devis préliminaire générés par l\'Assistant IA',
        localisation: {'ville': 'Douala', 'quartier': 'Bonapriso'},
        budgetPrevisionnel: 45000000.0,
        budgetActuel: 0.0,
        dateDebut: now,
        dateFinPrevue: now.add(const Duration(days: 180)),
        statut: 'en_recherche_entreprise',
        listePlans: ['https://storage.chantier.com/plan_3d.obj'],
        listeDocuments: ['https://storage.chantier.com/devis_ia.pdf'],
        planChoisi: 'Variante Contemporaine',
        creationSource: 'ia_assistant',
        plan3DUrl: 'https://storage.chantier.com/plan_3d.obj',
        devisEstimeUrl: 'https://storage.chantier.com/devis_ia.pdf',
        isMarketplacePublished: true,
        datePublicationMarketplace: now,
      );

      final json = aiProject.toJson();
      expect(json['id'], equals('proj_ia_123'));
      expect(json['creationSource'], equals('ia_assistant'));
      expect(json['isMarketplacePublished'], isTrue);
      expect(json['statut'], equals('en_recherche_entreprise'));

      final parsed = ProjectModel.fromJson({
        ...json,
        'dateDebut': Timestamp.fromDate(now),
        'dateFinPrevue': Timestamp.fromDate(now.add(const Duration(days: 180))),
        'datePublicationMarketplace': Timestamp.fromDate(now),
      });

      expect(parsed.titre, equals('Villa Moderne R+1 avec Piscine'));
      expect(parsed.creationSource, equals('ia_assistant'));
      expect(parsed.isMarketplacePublished, isTrue);
      expect(parsed.planChoisi, equals('Variante Contemporaine'));
    });

    test('2. Resilient Parsing: String dates, null values and string budgets', () {
      final rawMap = {
        'id': 'proj_test_456',
        'clientId': 'user_abc',
        'titre': 'Duplex à Bastos',
        'description': 'Description du projet',
        'ville': 'Yaoundé',
        'quartier': 'Bastos',
        'budgetPrevisionnel': '35000000',
        'budgetActuel': '0',
        'dateDebut': '2026-10-05T12:00:00.000Z',
        'dateFinPrevue': '2027-04-05T12:00:00.000Z',
        'statut': 'en_recherche_entreprise',
        'isMarketplacePublished': true,
      };

      final project = ProjectModel.fromJson(rawMap);
      expect(project.id, equals('proj_test_456'));
      expect(project.budgetPrevisionnel, equals(35000000.0));
      expect(project.localisation['ville'], equals('Yaoundé'));
      expect(project.statut, equals('en_recherche_entreprise'));
      expect(project.isMarketplacePublished, isTrue);
    });

    test('3. Matching for Company Offers Feed', () {
      final p1 = ProjectModel.fromJson({
        'id': 'p1',
        'titre': 'Projet IA Validé',
        'statut': 'en_recherche_entreprise',
        'budgetPrevisionnel': 25000000,
        'dateDebut': Timestamp.now(),
      });

      final p2 = ProjectModel.fromJson({
        'id': 'p2',
        'titre': 'Projet Manuel Publié',
        'statut': 'brouillon',
        'isMarketplacePublished': true,
        'dateDebut': Timestamp.now(),
      });

      final p3 = ProjectModel.fromJson({
        'id': 'p3',
        'titre': 'Chantier Déjà Attribué',
        'statut': 'en_cours',
        'dateDebut': Timestamp.now(),
      });

      final allProjects = [p1, p2, p3];

      // Filter used in offresProvider and watchOpenProjects
      final openOffers = allProjects.where((p) {
        final isOpen = p.statut == 'en_recherche_entreprise' ||
            p.statut == 'plan_valide' ||
            p.isMarketplacePublished == true;
        return isOpen && p.statut != 'en_cours' && p.statut != 'termine';
      }).toList();

      expect(openOffers.length, equals(2));
      expect(openOffers.map((p) => p.id), containsAll(['p1', 'p2']));
      expect(openOffers.map((p) => p.id), isNot(contains('p3')));
    });

    test('4. Marketplace Diffusion & Capacity Declaration Flow', () {
      final now = DateTime.now();

      final diffusion = DiffusionProjetModel(
        id: 'proj_ia_123_ent_789',
        projectId: 'proj_ia_123',
        clientId: 'client_001',
        entrepriseId: 'ent_789',
        statut: 'envoye',
        dateEnvoi: now,
      );

      expect(diffusion.statut, equals('envoye'));
      expect(diffusion.dateReponse, isNull);

      final reponseDate = now.add(const Duration(minutes: 15));
      final acceptedDiffusion = diffusion.copyWith(
        statut: 'accepte',
        dateReponse: reponseDate,
        commentaire: 'Nous disposons des équipes et du matériel disponibles immédiatement.',
        devisEstime: 44000000.0,
      );

      expect(acceptedDiffusion.statut, equals('accepte'));
      expect(acceptedDiffusion.commentaire, contains('équipes et du matériel'));
      expect(acceptedDiffusion.devisEstime, equals(44000000.0));

      final entrepriseInfo = EntrepriseModel(
        id: 'ent_789',
        userId: 'ent_789',
        raisonSociale: 'BatiPro Cameroun SARL',
        description: 'Entreprise générale de bâtiment',
        specialites: ['Gros oeuvre', 'Finitions'],
        anneesExperience: 10,
        noteMoyenne: 4.8,
        nombreAvis: 24,
        realisations: [],
        zoneIntervention: ['Douala', 'Yaoundé'],
        isVerified: true,
        verificationStatus: 'APPROVED',
      );

      final applicant = MarketplaceApplicantModel(
        entreprise: entrepriseInfo,
        diffusion: acceptedDiffusion,
      );

      expect(applicant.entreprise.raisonSociale, equals('BatiPro Cameroun SARL'));
      expect(applicant.entreprise.isVerified, isTrue);
      expect(applicant.entreprise.verificationStatus, equals('APPROVED'));
    });

    test('5. Enterprise Certification Banner Disappearance Logic', () {
      final unverified = EntrepriseModel(
        id: 'e1',
        userId: 'u1',
        raisonSociale: 'Entreprise Non Certifiée',
        description: '',
        specialites: [],
        anneesExperience: 1,
        noteMoyenne: 0,
        nombreAvis: 0,
        realisations: [],
        zoneIntervention: [],
        isVerified: false,
        verificationStatus: 'SUBMITTED',
      );

      final verified = unverified.copyWith(
        isVerified: true,
        verificationStatus: 'APPROVED',
      );

      // Banner display condition
      bool shouldShowBanner(EntrepriseModel? ent) {
        if (ent == null) return false;
        return !ent.isVerified && ent.verificationStatus != 'APPROVED';
      }

      expect(shouldShowBanner(unverified), isTrue);
      expect(shouldShowBanner(verified), isFalse);
    });

    test('6. User Model Live Firestore Compatibility', () {
      final user = UserModel(
        uid: 'user_123',
        nom: 'Mbarga',
        prenom: 'Alain',
        email: 'alain.mbarga@gmail.com',
        telephone: '+237699001122',
        role: 'client',
        dateCreation: DateTime.now(),
        isActive: true,
        isVerified: false,
      );

      final json = user.toJson();
      expect(json['uid'], equals('user_123'));
      expect(json['isActive'], isTrue);

      final parsed = UserModel.fromJson(json);
      expect(parsed.prenom, equals('Alain'));
      expect(parsed.isActive, isTrue);
    });
  });
}
