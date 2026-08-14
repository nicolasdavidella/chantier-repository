import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chantier_track/data/models/user_model.dart';
import 'package:chantier_track/data/models/project_model.dart';
import 'package:chantier_track/data/models/tache_model.dart';
import 'package:chantier_track/data/models/depense_model.dart';

void main() {
  group('UserModel Tests', () {
    final now = DateTime.now();
    final json = {
      'uid': 'u1',
      'email': 'test@test.com',
      'nom': 'Doe',
      'prenom': 'John',
      'role': 'client',
      'telephone': '+33600000000',
      'dateCreation': Timestamp.fromDate(now),
    };

    test('fromJson & toJson', () {
      final user = UserModel.fromJson(json);
      expect(user.uid, 'u1');
      expect(user.nom, 'Doe');
      
      final serialized = user.toJson();
      expect(serialized['uid'], 'u1');
      expect((serialized['dateCreation'] as Timestamp).toDate().millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('copyWith', () {
      final user = UserModel.fromJson(json);
      final updatedUser = user.copyWith(nom: 'Smith', role: 'admin');
      
      expect(updatedUser.nom, 'Smith');
      expect(updatedUser.role, 'admin');
      expect(updatedUser.uid, 'u1'); // Unchanged
    });
  });

  group('ProjectModel Tests', () {
    final now = DateTime.now();
    final json = {
      'id': 'p1',
      'clientId': 'c1',
      'entrepriseId': 'e1',
      'titre': 'Villa',
      'description': 'Construc',
      'localisation': {'ville': 'Douala'},
      'budgetPrevisionnel': 10000,
      'budgetActuel': 2000,
      'dateDebut': Timestamp.fromDate(now),
      'dateFinPrevue': Timestamp.fromDate(now.add(const Duration(days: 30))),
      'statut': 'en_cours',
      'listePlans': [],
      'listeDocuments': [],
    };

    test('fromJson & toJson', () {
      final project = ProjectModel.fromJson(json);
      expect(project.id, 'p1');
      expect(project.budgetPrevisionnel, 10000.0);
      expect(project.localisation['ville'], 'Douala');
      
      final serialized = project.toJson();
      expect(serialized['budgetActuel'], 2000.0);
    });

    test('copyWith', () {
      final project = ProjectModel.fromJson(json);
      final updated = project.copyWith(statut: 'termine', budgetActuel: 5000);
      
      expect(updated.statut, 'termine');
      expect(updated.budgetActuel, 5000.0);
      expect(updated.titre, 'Villa');
    });
  });

  group('TacheModel Tests', () {
    final now = DateTime.now();
    final json = {
      'id': 't1',
      'projectId': 'p1',
      'titre': 'Fondation',
      'description': 'Creuser',
      'statut': 'a_faire',
      'dateDebutPrevue': Timestamp.fromDate(now),
      'dateFinPrevue': Timestamp.fromDate(now.add(const Duration(days: 5))),
      'responsable': 'Chef',
      'ordre': 1,
    };

    test('fromJson & toJson', () {
      final tache = TacheModel.fromJson(json);
      expect(tache.ordre, 1);
      
      final serialized = tache.toJson();
      expect(serialized['titre'], 'Fondation');
    });

    test('copyWith', () {
      final tache = TacheModel.fromJson(json);
      final updated = tache.copyWith(ordre: 2);
      
      expect(updated.ordre, 2);
      expect(updated.statut, 'a_faire');
    });
  });

  group('DepenseModel Tests', () {
    final now = DateTime.now();
    final json = {
      'id': 'd1',
      'projectId': 'p1',
      'declarantId': 'c1',
      'montant': 1500,
      'categorie': 'Materiaux',
      'dateDeclaration': Timestamp.fromDate(now),
      'description': 'Ciment',
      'justificatifUrl': 'url_facture',
      'statut': 'en_attente',
    };

    test('fromJson & toJson', () {
      final depense = DepenseModel.fromJson(json);
      expect(depense.montant, 1500.0);
      expect(depense.categorie, 'Materiaux');
      
      final serialized = depense.toJson();
      expect(serialized['statut'], 'en_attente');
    });

    test('copyWith', () {
      final depense = DepenseModel.fromJson(json);
      final updated = depense.copyWith(statut: 'validee');
      
      expect(updated.statut, 'validee');
      expect(updated.montant, 1500.0);
    });
  });
}
