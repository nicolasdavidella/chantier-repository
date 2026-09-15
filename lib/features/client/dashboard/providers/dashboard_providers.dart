import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/repositories/project_repository.dart';
import '../../../auth/providers/auth_provider.dart';

// Stream des projets du client connecté (temps réel Firestore)
final clientProjectsProvider = StreamProvider<List<ProjectModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.value?.uid;
  if (uid == null) return const Stream.empty();

  final repo = ref.watch(projectRepositoryProvider);
  return repo.watchClientProjects(uid);
});

// Compter les projets actifs
final activeProjectsCountProvider = Provider<int>((ref) {
  final projects = ref.watch(clientProjectsProvider).value ?? [];
  return projects.where((p) => p.statut == 'en_cours').length;
});

// Budget total de tous les projets du client
final totalBudgetProvider = Provider<double>((ref) {
  final projects = ref.watch(clientProjectsProvider).value ?? [];
  return projects.fold(0.0, (sum, p) => sum + p.budgetPrevisionnel);
});

// Progression d'un projet (budgetActuel / budgetPrevisionnel)
final projectProgressProvider = Provider.family<double, ProjectModel>((ref, project) {
  if (project.budgetPrevisionnel == 0) return 0.0;
  return (project.budgetActuel / project.budgetPrevisionnel).clamp(0.0, 1.0);
});
