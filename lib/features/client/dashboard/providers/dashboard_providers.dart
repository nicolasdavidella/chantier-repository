import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/project_model.dart';

// Provider that returns mock projects to test UI
final clientProjectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  // Simulate network delay for pull-to-refresh
  await Future.delayed(const Duration(seconds: 1));

  return [
    ProjectModel(
      id: 'p1',
      clientId: 'c1',
      titre: 'Villa Océane - Kribi',
      description: 'Construction d\'une villa R+1 avec piscine',
      localisation: {'ville': 'Kribi'},
      budgetPrevisionnel: 45000000,
      budgetActuel: 12500000,
      dateDebut: DateTime.now().subtract(const Duration(days: 30)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 120)),
      statut: 'en_cours',
      listePlans: [],
      listeDocuments: [],
    ),
    ProjectModel(
      id: 'p2',
      clientId: 'c1',
      titre: 'Rénovation Appartement',
      description: 'Réfection totale plomberie et électricité',
      localisation: {'ville': 'Douala'},
      budgetPrevisionnel: 8500000,
      budgetActuel: 7800000,
      dateDebut: DateTime.now().subtract(const Duration(days: 60)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 5)),
      statut: 'en_cours',
      listePlans: [],
      listeDocuments: [],
    ),
  ];
});

// Calculate total budget from all active projects
final totalBudgetProvider = Provider<double>((ref) {
  final projects = ref.watch(clientProjectsProvider).value ?? [];
  return projects.fold(0.0, (sum, p) => sum + p.budgetPrevisionnel);
});

// Count active projects
final activeProjectsCountProvider = Provider<int>((ref) {
  final projects = ref.watch(clientProjectsProvider).value ?? [];
  return projects.length;
});

// Temporary stat provider for tasks progress of a project
final projectProgressProvider = Provider.family<double, String>((ref, projectId) {
  if (projectId == 'p1') return 0.35; // 35%
  if (projectId == 'p2') return 0.85; // 85%
  return 0.0;
});
