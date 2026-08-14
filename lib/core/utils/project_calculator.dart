import '../../data/models/tache_model.dart';
import '../../data/models/depense_model.dart';
import '../../data/models/entreprise_model.dart';

class ProjectCalculator {
  /// Calcule le pourcentage global d'avancement du projet (0 à 100)
  /// en faisant la moyenne de la progression de toutes les tâches.
  /// Si le tableau est vide, retourne 0.
  static double calculateProjectProgress(List<TacheModel> taches) {
    if (taches.isEmpty) return 0.0;

    double totalProgress = 0.0;
    for (final tache in taches) {
      if (tache.statut == 'terminee') {
        totalProgress += 100.0;
      }
    }

    return totalProgress / taches.length;
  }

  /// Calcule le total du budget engagé (dépenses validées uniquement).
  static double calculateEngagedBudget(List<DepenseModel> depenses) {
    if (depenses.isEmpty) return 0.0;

    double total = 0.0;
    for (final depense in depenses) {
      if (depense.statut == 'validee' || depense.statut == 'validée') {
        total += depense.montant;
      }
    }
    return total;
  }

  /// Calcule un score de recommandation pour une entreprise (0 à 100).
  /// Basé sur sa note globale (sur 5) et son nombre de projets réalisés.
  /// Ex: note de 5 = 70 points, >10 projets = 30 points.
  static double calculateRecommendationScore(EntrepriseModel entreprise) {
    double score = 0.0;
    
    // Poids de la note (70% du score)
    score += (entreprise.noteMoyenne / 5.0) * 70;

    // Poids de l'expérience (30% du score, plafond à 20 projets)
    final experience = entreprise.realisations.length > 20 ? 20 : entreprise.realisations.length;
    score += (experience / 20.0) * 30;

    return score;
  }
}
