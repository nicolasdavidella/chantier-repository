import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/models/tache_model.dart';

// --- Projects Provider ---
final chefProjectsProvider = Provider<List<ProjectModel>>((ref) {
  return [
    ProjectModel(
      id: 'proj_1',
      clientId: 'c1',
      entrepriseId: 'e1',
      titre: 'Villa Océan - Kribi',
      description: 'Construction d\'une villa R+1 avec piscine',
      localisation: {'ville': 'Kribi', 'quartier': 'Mpangou'},
      budgetPrevisionnel: 45000000,
      budgetActuel: 12000000,
      dateDebut: DateTime.now().subtract(const Duration(days: 30)),
      dateFinPrevue: DateTime.now().add(const Duration(days: 150)),
      statut: 'en_cours',
      listePlans: ['https://images.unsplash.com/photo-1541888081622-1db116fb837a?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60'],
      listeDocuments: [],
    )
  ];
});

// --- Tasks Provider ---
class ChefTasksNotifier extends StateNotifier<List<TacheModel>> {
  ChefTasksNotifier() : super([]) {
    _loadMockTasks();
  }

  void _loadMockTasks() {
    state = [
      TacheModel(
        id: 't1',
        projectId: 'proj_1',
        titre: 'Coulage fondations',
        description: 'Couler le béton pour les semelles filantes.',
        statut: 'terminee',
        dateDebutPrevue: DateTime.now().subtract(const Duration(days: 10)),
        dateFinPrevue: DateTime.now().subtract(const Duration(days: 5)),
        responsable: 'Chef Equipe A',
        ordre: 1,
      ),
      TacheModel(
        id: 't2',
        projectId: 'proj_1',
        titre: 'Élévation murs RDC',
        description: 'Montage des agglos pour le rez-de-chaussée.',
        statut: 'en_cours',
        dateDebutPrevue: DateTime.now().subtract(const Duration(days: 2)),
        dateFinPrevue: DateTime.now().add(const Duration(days: 14)),
        responsable: 'Chef Equipe B',
        ordre: 2,
      ),
      TacheModel(
        id: 't3',
        projectId: 'proj_1',
        titre: 'Coffrage dalle',
        description: 'Préparation du coffrage pour la dalle haute du RDC.',
        statut: 'a_faire',
        dateDebutPrevue: DateTime.now().add(const Duration(days: 15)),
        dateFinPrevue: DateTime.now().add(const Duration(days: 20)),
        responsable: 'Chef Equipe A',
        ordre: 3,
      ),
    ];
  }

  void cycleTaskStatus(String taskId) {
    state = state.map((t) {
      if (t.id == taskId) {
        String nextStatus;
        if (t.statut == 'a_faire') {
          nextStatus = 'en_cours';
        } else if (t.statut == 'en_cours') {
          nextStatus = 'terminee';
        } else {
          nextStatus = 'a_faire'; // cycle back or we can leave it as terminee
        }
        return t.copyWith(statut: nextStatus);
      }
      return t;
    }).toList();
  }
}

final chefTasksProvider = StateNotifierProvider<ChefTasksNotifier, List<TacheModel>>((ref) {
  return ChefTasksNotifier();
});
