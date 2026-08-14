import 'package:flutter_test/flutter_test.dart';
import 'package:chantier_track/core/utils/project_calculator.dart';
import 'package:chantier_track/data/models/tache_model.dart';
import 'package:chantier_track/data/models/depense_model.dart';
import 'package:chantier_track/data/models/entreprise_model.dart';

void main() {
  group('ProjectCalculator - calculateProjectProgress', () {
    test('retourne 0 si aucune tache', () {
      final progress = ProjectCalculator.calculateProjectProgress([]);
      expect(progress, 0.0);
    });

    test('calcule la moyenne correcte', () {
      final t1 = TacheModel(id: '1', projectId: 'p1', titre: '', description: '', statut: 'a_faire', dateDebutPrevue: DateTime.now(), dateFinPrevue: DateTime.now(), responsable: '', ordre: 1);
      final t2 = TacheModel(id: '2', projectId: 'p1', titre: '', description: '', statut: 'terminee', dateDebutPrevue: DateTime.now(), dateFinPrevue: DateTime.now(), responsable: '', ordre: 2);
      final t3 = TacheModel(id: '3', projectId: 'p1', titre: '', description: '', statut: 'terminee', dateDebutPrevue: DateTime.now(), dateFinPrevue: DateTime.now(), responsable: '', ordre: 3);
      final t4 = TacheModel(id: '4', projectId: 'p1', titre: '', description: '', statut: 'en_cours', dateDebutPrevue: DateTime.now(), dateFinPrevue: DateTime.now(), responsable: '', ordre: 4);

      final progress = ProjectCalculator.calculateProjectProgress([t1, t2, t3, t4]);
      expect(progress, 50.0);
    });
  });

  group('ProjectCalculator - calculateEngagedBudget', () {
    test('retourne 0 si aucune depense', () {
      final budget = ProjectCalculator.calculateEngagedBudget([]);
      expect(budget, 0.0);
    });

    test('somme uniquement les depenses validees', () {
      final d1 = DepenseModel(id: '1', projectId: 'p1', declarantId: '', montant: 1000, categorie: '', dateDeclaration: DateTime.now(), description: '', justificatifUrl: '', statut: 'validee');
      final d2 = DepenseModel(id: '2', projectId: 'p1', declarantId: '', montant: 500, categorie: '', dateDeclaration: DateTime.now(), description: '', justificatifUrl: '', statut: 'validée');
      final d3 = DepenseModel(id: '3', projectId: 'p1', declarantId: '', montant: 2000, categorie: '', dateDeclaration: DateTime.now(), description: '', justificatifUrl: '', statut: 'en_attente');
      final d4 = DepenseModel(id: '4', projectId: 'p1', declarantId: '', montant: 300, categorie: '', dateDeclaration: DateTime.now(), description: '', justificatifUrl: '', statut: 'refuse');

      final budget = ProjectCalculator.calculateEngagedBudget([d1, d2, d3, d4]);
      expect(budget, 1500.0);
    });
  });

  group('ProjectCalculator - calculateRecommendationScore', () {
    test('calcule le score max pour 5 étoiles et 20+ projets', () {
      final e = EntrepriseModel(id: '1', userId: '', raisonSociale: '', description: '', specialites: [], anneesExperience: 5, noteMoyenne: 5.0, nombreAvis: 10, realisations: List.filled(25, 'url'), zoneIntervention: [], certifie: true);
      
      final score = ProjectCalculator.calculateRecommendationScore(e);
      expect(score, 100.0);
    });

    test('calcule correctement pour un profil moyen', () {
      final e = EntrepriseModel(id: '1', userId: '', raisonSociale: '', description: '', specialites: [], anneesExperience: 2, noteMoyenne: 2.5, nombreAvis: 5, realisations: List.filled(10, 'url'), zoneIntervention: [], certifie: true);
      
      // note 2.5/5 -> 50% de 70 = 35
      // 10/20 projets -> 50% de 30 = 15
      // Total = 50
      final score = ProjectCalculator.calculateRecommendationScore(e);
      expect(score, 50.0);
    });
  });
}
