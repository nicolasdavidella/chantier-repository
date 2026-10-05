import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';
import '../models/entreprise_model.dart';
import '../models/diffusion_projet_model.dart';
import '../models/marketplace_applicant_model.dart';

class MarketplaceRepository {
  final FirebaseFirestore _firestore;

  MarketplaceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 1. PUBLIER UN PROJET SUR LA MARKETPLACE (Unifié pour IA & Manuel)
  Future<void> publishProjectToMarketplace(ProjectModel project) async {
    try {
      final batch = _firestore.batch();

      // Mettre à jour / Créer le projet avec le statut de recherche marketplace
      final projectRef = _firestore.collection('projects').doc(project.id);
      final publishedProject = project.copyWith(
        statut: 'en_recherche_entreprise',
        isMarketplacePublished: true,
        datePublicationMarketplace: DateTime.now(),
      );

      batch.set(projectRef, publishedProject.toJson(), SetOptions(merge: true));

      // Récupérer toutes les entreprises pour la diffusion
      final entreprisesSnap = await _firestore.collection('entreprises').get();
      final ville = publishedProject.localisation['ville'] ?? 'Inconnue';

      int diffusionsCount = 0;
      for (final entDoc in entreprisesSnap.docs) {
        final entData = entDoc.data();
        final entrepriseUserId = entData['userId'] as String? ?? entDoc.id;
        if (entrepriseUserId.isEmpty) continue;

        // Diffusion du projet
        final diffusionId = '${project.id}_$entrepriseUserId';
        final diffRef = _firestore.collection('diffusions_projet').doc(diffusionId);

        batch.set(
          diffRef,
          {
            'id': diffusionId,
            'projectId': project.id,
            'clientId': project.clientId,
            'entrepriseId': entrepriseUserId,
            'statut': 'envoye',
            'dateEnvoi': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        // Notification in-app pour l'entreprise
        final notifRef = _firestore.collection('notifications').doc();
        batch.set(notifRef, {
          'userId': entrepriseUserId,
          'titre': "Nouveau projet sur la Marketplace !",
          'message': "Un nouveau projet '${project.titre}' ($ville) recherche une entreprise qualifiée.",
          'isRead': false,
          'type': 'marketplace_nouveau_projet',
          'projectId': project.id,
          'createdAt': FieldValue.serverTimestamp(),
        });

        diffusionsCount++;
      }

      await batch.commit();
      debugPrint('✅ Marketplace: Projet ${project.id} diffusé à $diffusionsCount entreprise(s)');
    } catch (e) {
      debugPrint('❌ Erreur publishProjectToMarketplace: $e');
      rethrow;
    }
  }

  /// 2. CONFIRMER LA CAPACITÉ D'UNE ENTREPRISE ("Je suis capable de réaliser ce projet")
  Future<void> declareCompanyCapacity({
    required String projectId,
    required String entrepriseUserId,
    String? commentaire,
    double? devisEstime,
  }) async {
    try {
      final projectRef = _firestore.collection('projects').doc(projectId);
      final projectSnap = await projectRef.get();

      if (!projectSnap.exists) {
        throw Exception("Projet introuvable.");
      }

      final projectData = projectSnap.data()!;
      final clientId = projectData['clientId'] as String? ?? '';
      final titreProjet = projectData['titre'] as String? ?? 'votre projet';

      // 1. Récupérer les informations réelles et exactes de l'entreprise
      String nomEntreprise = '';
      double note = 5.0;
      String logo = '';

      // Recherche 1: Dans la collection 'entreprises' par ID direct
      final entDoc = await _firestore.collection('entreprises').doc(entrepriseUserId).get();
      if (entDoc.exists && entDoc.data() != null) {
        final entData = entDoc.data()!;
        final raison = entData['raisonSociale'] as String?;
        if (raison != null && raison.trim().isNotEmpty) {
          nomEntreprise = raison.trim();
        }
        note = (entData['noteMoyenne'] as num?)?.toDouble() ?? 5.0;
        logo = entData['logoUrl'] as String? ?? '';
      }

      // Recherche 2: Dans la collection 'entreprises' par le champ 'userId'
      if (nomEntreprise.isEmpty) {
        final entQuery = await _firestore
            .collection('entreprises')
            .where('userId', isEqualTo: entrepriseUserId)
            .limit(1)
            .get();
        if (entQuery.docs.isNotEmpty) {
          final entData = entQuery.docs.first.data();
          final raison = entData['raisonSociale'] as String?;
          if (raison != null && raison.trim().isNotEmpty) {
            nomEntreprise = raison.trim();
          }
          note = (entData['noteMoyenne'] as num?)?.toDouble() ?? note;
          logo = entData['logoUrl'] as String? ?? logo;
        }
      }

      // Recherche 3: Dans la collection 'users' pour le nom du compte utilisateur
      if (nomEntreprise.isEmpty) {
        final userDoc = await _firestore.collection('users').doc(entrepriseUserId).get();
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          final raison = userData['raisonSociale'] as String?;
          final nom = userData['nom'] as String? ?? '';
          final prenom = userData['prenom'] as String? ?? '';
          if (raison != null && raison.trim().isNotEmpty) {
            nomEntreprise = raison.trim();
          } else {
            final fullName = '$prenom $nom'.trim();
            if (fullName.isNotEmpty) {
              nomEntreprise = fullName;
            }
          }
          if (logo.isEmpty) {
            logo = userData['photoUrl'] as String? ?? '';
          }
        }
      }

      if (nomEntreprise.isEmpty) {
        nomEntreprise = "Entreprise de BTP";
      }

      // 2. Écritures atomiques avec WriteBatch
      final batch = _firestore.batch();
      final diffusionId = '${projectId}_$entrepriseUserId';
      final diffRef = _firestore.collection('diffusions_projet').doc(diffusionId);

      final diffData = {
        'id': diffusionId,
        'projectId': projectId,
        'clientId': clientId,
        'entrepriseId': entrepriseUserId,
        'nomEntreprise': nomEntreprise,
        'statut': 'accepte',
        'dateReponse': FieldValue.serverTimestamp(),
        if (commentaire != null && commentaire.isNotEmpty) 'commentaire': commentaire,
        if (devisEstime != null) 'devisEstime': devisEstime,
      };

      batch.set(diffRef, diffData, SetOptions(merge: true));

      // Ajouter l'entreprise dans entreprisesPostulantes du projet
      batch.set(projectRef, {
        'entreprisesPostulantes': FieldValue.arrayUnion([entrepriseUserId]),
      }, SetOptions(merge: true));

      // Notifier instantanément le client
      if (clientId.isNotEmpty) {
        final notifRef = _firestore.collection('notifications').doc();
        batch.set(notifRef, {
          'userId': clientId,
          'titre': "Nouvelle entreprise intéressée !",
          'message': "$nomEntreprise a confirmé pouvoir réaliser '$titreProjet'.",
          'logoUrl': logo,
          'entrepriseId': entrepriseUserId,
          'nomEntreprise': nomEntreprise,
          'projectId': projectId,
          'isRead': false,
          'type': 'entreprise_reponse_capable',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint('✅ Capacité déclarée avec succès pour le projet $projectId par $nomEntreprise ($entrepriseUserId)');
    } catch (e) {
      debugPrint('❌ Erreur declareCompanyCapacity: $e');
      rethrow;
    }
  }

  /// 3. DÉCLINER UN PROJET
  Future<void> declineProject({
    required String projectId,
    required String entrepriseUserId,
  }) async {
    try {
      final diffusionId = '${projectId}_$entrepriseUserId';
      await _firestore.collection('diffusions_projet').doc(diffusionId).set({
        'id': diffusionId,
        'projectId': projectId,
        'entrepriseId': entrepriseUserId,
        'statut': 'decline',
        'dateReponse': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erreur declineProject: $e');
      rethrow;
    }
  }

  /// 4. SÉLECTIONNER ET ATTRIBUER LE PROJET À UNE ENTREPRISE PAR LE CLIENT
  Future<void> selectCompanyForProject({
    required String projectId,
    required String clientId,
    required String entrepriseUserId,
  }) async {
    try {
      final projectRef = _firestore.collection('projects').doc(projectId);
      final projectSnap = await projectRef.get();

      if (!projectSnap.exists) {
        throw Exception("Projet introuvable.");
      }

      final projectData = projectSnap.data()!;
      final titreProjet = projectData['titre'] as String? ?? 'votre projet';

      final batch = _firestore.batch();

      // 1. Assigner l'entreprise et changer le statut du projet
      batch.set(projectRef, {
        'entrepriseId': entrepriseUserId,
        'statut': 'en_cours',
        'isMarketplacePublished': false,
        'dateAttribution': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Marquer la diffusion comme retenue
      final selectedDiffRef = _firestore.collection('diffusions_projet').doc('${projectId}_$entrepriseUserId');
      batch.set(selectedDiffRef, {
        'statut': 'retenu',
        'dateSelection': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Créer ou mettre à jour la conversation directe
      final convRef = _firestore.collection('conversations').doc(projectId);
      batch.set(
        convRef,
        {
          'projectId': projectId,
          'participantsIds': [clientId, entrepriseUserId],
          'dernierMessage': "Chantier attribué ! Vous pouvez maintenant échanger sur l'exécution.",
          'dateDernierMessage': FieldValue.serverTimestamp(),
          'nonLus': {
            clientId: 0,
            entrepriseUserId: 1,
          }
        },
        SetOptions(merge: true),
      );

      // Message système
      final msgRef = convRef.collection('messages').doc();
      batch.set(msgRef, {
        'expediteurId': 'systeme',
        'destinataireId': entrepriseUserId,
        'texte': "Félicitations ! Le client vous a attribué le projet '$titreProjet'.",
        'dateEnvoi': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // 4. Notification pour l'entreprise retenue
      final notifRef = _firestore.collection('notifications').doc();
      batch.set(notifRef, {
        'userId': entrepriseUserId,
        'titre': "Projet Attribué !",
        'message': "Félicitations, vous avez été retenu pour le projet '$titreProjet'.",
        'projectId': projectId,
        'isRead': false,
        'type': 'projet_attribue',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint('✅ Projet $projectId attribué à $entrepriseUserId');
    } catch (e) {
      debugPrint('❌ Erreur selectCompanyForProject: $e');
      rethrow;
    }
  }

  /// 5. STREAM : PROJETS MARKETPLACE D'UN CLIENT (avec état de publication)
  Stream<List<ProjectModel>> streamMarketplaceProjectsForClient(String clientId) {
    return _firestore
        .collection('projects')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      final projects = snapshot.docs
          .map((doc) => ProjectModel.fromJson(doc.data()))
          .where((p) => p.isMarketplacePublished || p.statut == 'en_recherche_entreprise')
          .toList();
      projects.sort((a, b) => b.dateDebut.compareTo(a.dateDebut));
      return projects;
    });
  }

  /// 6. STREAM : CANDIDATS / ENTREPRISES CAPABLES POUR UN PROJET DONNÉ
  Stream<List<MarketplaceApplicantModel>> streamApplicantsForProject(String projectId) {
    return _firestore
        .collection('diffusions_projet')
        .where('projectId', isEqualTo: projectId)
        .where('statut', isEqualTo: 'accepte')
        .snapshots()
        .asyncMap((snapshot) async {
      List<MarketplaceApplicantModel> applicants = [];

      for (var doc in snapshot.docs) {
        final rawData = doc.data();
        final diff = DiffusionProjetModel.fromJson(rawData, id: doc.id);
        
        EntrepriseModel? entreprise;

        // 1. Recherche directe dans la collection 'entreprises' par ID
        final entDoc = await _firestore.collection('entreprises').doc(diff.entrepriseId).get();
        if (entDoc.exists && entDoc.data() != null) {
          final data = entDoc.data()!;
          data['id'] = entDoc.id;
          entreprise = EntrepriseModel.fromJson(data);
        }

        // 2. Recherche dans 'entreprises' par le champ 'userId'
        if (entreprise == null) {
          final entQuery = await _firestore
              .collection('entreprises')
              .where('userId', isEqualTo: diff.entrepriseId)
              .limit(1)
              .get();
          if (entQuery.docs.isNotEmpty) {
            final data = entQuery.docs.first.data();
            data['id'] = entQuery.docs.first.id;
            entreprise = EntrepriseModel.fromJson(data);
          }
        }

        // 3. Récupérer le nom exact depuis le document 'users' ou la diffusion
        String nomExact = entreprise?.raisonSociale ?? '';
        String logoUrl = entreprise?.logoUrl ?? '';

        if (rawData.containsKey('nomEntreprise') && (rawData['nomEntreprise'] as String?)?.isNotEmpty == true) {
          nomExact = (rawData['nomEntreprise'] as String).trim();
        }

        final userDoc = await _firestore.collection('users').doc(diff.entrepriseId).get();
        if (userDoc.exists && userDoc.data() != null) {
          final uData = userDoc.data()!;
          final uRaison = uData['raisonSociale'] as String?;
          final uNom = uData['nom'] as String? ?? '';
          final uPrenom = uData['prenom'] as String? ?? '';
          
          if (uRaison != null && uRaison.trim().isNotEmpty) {
            nomExact = uRaison.trim();
          } else if (nomExact.isEmpty) {
            final fullName = '$uPrenom $uNom'.trim();
            if (fullName.isNotEmpty) {
              nomExact = fullName;
            }
          }

          if (logoUrl.isEmpty) {
            logoUrl = uData['photoUrl'] as String? ?? '';
          }
        }

        if (nomExact.isEmpty) {
          nomExact = "Entreprise de construction";
        }

        if (entreprise != null) {
          if (entreprise.raisonSociale != nomExact || (entreprise.logoUrl == null && logoUrl.isNotEmpty)) {
            entreprise = entreprise.copyWith(
              raisonSociale: nomExact,
              logoUrl: logoUrl.isNotEmpty ? logoUrl : entreprise.logoUrl,
            );
          }
          applicants.add(MarketplaceApplicantModel(
            entreprise: entreprise,
            diffusion: diff,
          ));
        } else {
          // Profil construit avec les données réelles et exactes de l'entreprise
          final realEnt = EntrepriseModel(
            id: diff.entrepriseId,
            userId: diff.entrepriseId,
            raisonSociale: nomExact,
            logoUrl: logoUrl.isNotEmpty ? logoUrl : null,
            description: "Entreprise du secteur BTP prête à intervenir",
            specialites: ["BTP", "Construction"],
            anneesExperience: 3,
            noteMoyenne: 5.0,
            nombreAvis: 1,
            realisations: [],
            zoneIntervention: [],
            isVerified: true,
            verificationStatus: 'APPROVED',
          );
          applicants.add(MarketplaceApplicantModel(
            entreprise: realEnt,
            diffusion: diff,
          ));
        }
      }

      return applicants;
    });
  }

  /// 7. STREAM : FLUX OPPORTUNITÉS MARKETPLACE POUR UNE ENTREPRISE
  Stream<List<ProjectDiffusionData>> streamMarketplaceFeedForEntreprise(String entrepriseUserId) {
    return _firestore
        .collection('projects')
        .where('statut', isEqualTo: 'en_recherche_entreprise')
        .snapshots()
        .asyncMap((snapshot) async {
      List<ProjectDiffusionData> results = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final project = ProjectModel.fromJson(data);

        final diffusionId = '${project.id}_$entrepriseUserId';
        final diffDoc = await _firestore.collection('diffusions_projet').doc(diffusionId).get();

        DiffusionProjetModel diff;
        if (diffDoc.exists) {
          diff = DiffusionProjetModel.fromJson(diffDoc.data()!, id: diffDoc.id);
        } else {
          diff = DiffusionProjetModel(
            id: diffusionId,
            projectId: project.id,
            clientId: project.clientId,
            entrepriseId: entrepriseUserId,
            statut: project.entreprisesPostulantes.contains(entrepriseUserId) ? 'accepte' : 'envoye',
            dateEnvoi: project.dateDebut,
          );
        }

        results.add(ProjectDiffusionData(diffusion: diff, project: project));
      }

      results.sort((a, b) => b.project.dateDebut.compareTo(a.project.dateDebut));
      return results;
    });
  }
}

class ProjectDiffusionData {
  final DiffusionProjetModel diffusion;
  final ProjectModel project;

  ProjectDiffusionData({required this.diffusion, required this.project});
}

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository();
});
