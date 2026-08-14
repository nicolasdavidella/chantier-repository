import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/project_model.dart';

// --- Models for Dashboard Stats ---
class EntrepriseStats {
  final int activeProjects;
  final int pendingQuotes;
  final double averageRating;
  final double monthlyRevenue;

  EntrepriseStats({
    required this.activeProjects,
    required this.pendingQuotes,
    required this.averageRating,
    required this.monthlyRevenue,
  });
}

// --- Providers ---
final entrepriseStatsProvider = Provider<EntrepriseStats>((ref) {
  return EntrepriseStats(
    activeProjects: 3,
    pendingQuotes: 5,
    averageRating: 4.8,
    monthlyRevenue: 12500000.0, // 12.5M FCFA
  );
});

final projectRequestsProvider = Provider<List<ProjectModel>>((ref) {
  return [
    ProjectModel(
      id: 'req1',
      clientId: 'c1',
      titre: 'Construction Villa F4 à Kribi',
      description: 'Projet de construction d\'une villa avec piscine. Cherche entreprise gros oeuvre et finitions.',
      localisation: {'ville': 'Kribi', 'quartier': 'Mpangou'},
      budgetPrevisionnel: 45000000.0,
      budgetActuel: 0,
      dateDebut: DateTime.now().add(const Duration(days: 30)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 180)),
      statut: 'en_recherche_entreprise',
      listePlans: [],
      listeDocuments: [],
    ),
    ProjectModel(
      id: 'req2',
      clientId: 'c2',
      titre: 'Rénovation toiture et peinture',
      description: 'Refonte complète de la toiture d\'un immeuble R+2 et ravalement de façade.',
      localisation: {'ville': 'Douala', 'quartier': 'Bonapriso'},
      budgetPrevisionnel: 8500000.0,
      budgetActuel: 0,
      dateDebut: DateTime.now().add(const Duration(days: 14)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 45)),
      statut: 'en_recherche_entreprise',
      listePlans: [],
      listeDocuments: [],
    ),
  ];
});

final activeProjectsProvider = Provider<List<ProjectModel>>((ref) {
  return [
    ProjectModel(
      id: 'act1',
      clientId: 'c3',
      entrepriseId: 'me',
      titre: 'Immeuble Commercial R+4',
      description: 'Construction d\'un immeuble de bureaux au centre ville.',
      localisation: {'ville': 'Yaoundé', 'quartier': 'Bastos'},
      budgetPrevisionnel: 120000000.0,
      budgetActuel: 45000000.0, // Used for progress
      dateDebut: DateTime.now().subtract(const Duration(days: 60)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 200)),
      statut: 'en_cours',
      listePlans: ['https://images.unsplash.com/photo-1541888081622-1db116fb837a?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60'],
      listeDocuments: [],
    ),
    ProjectModel(
      id: 'act2',
      clientId: 'c4',
      entrepriseId: 'me',
      titre: 'Maison Individuelle Moderne',
      description: 'Construction clé en main.',
      localisation: {'ville': 'Douala', 'quartier': 'Makepe'},
      budgetPrevisionnel: 35000000.0,
      budgetActuel: 31000000.0, // Almost done
      dateDebut: DateTime.now().subtract(const Duration(days: 120)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 10)),
      statut: 'en_cours',
      listePlans: ['https://images.unsplash.com/photo-1503387762-592deb58ef4e?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60'],
      listeDocuments: [],
    ),
  ];
});
