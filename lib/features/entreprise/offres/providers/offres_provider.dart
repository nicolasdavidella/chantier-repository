import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/repositories/marketplace_repository.dart';
import '../../../auth/providers/auth_provider.dart';

// Represents a diffusion with its associated project
class ProjectDiffusion {
  final String diffusionId;
  final ProjectModel project;

  ProjectDiffusion({required this.diffusionId, required this.project});
}

final offresProvider = StreamProvider.autoDispose<List<ProjectDiffusion>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  final firestore = FirebaseFirestore.instance;

  // Stream tous les projets en recherche d'entreprise ou publiés sur la Marketplace
  return firestore
      .collection('projects')
      .snapshots()
      .map((snapshot) {
    List<ProjectDiffusion> result = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      final project = ProjectModel.fromJson(data);
      
      // Projets ouverts aux entreprises
      final isOpen = project.statut == 'en_recherche_entreprise' ||
          project.statut == 'plan_valide' ||
          project.isMarketplacePublished == true;

      if (isOpen && project.statut != 'en_cours' && project.statut != 'termine') {
        final diffusionId = '${project.id}_${user.uid}';
        result.add(ProjectDiffusion(
          diffusionId: diffusionId,
          project: project,
        ));
      }
    }

    result.sort((a, b) => b.project.dateDebut.compareTo(a.project.dateDebut));
    return result;
  });
});

class CandidatureController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CandidatureController(this.ref) : super(const AsyncData(null));

  Future<void> accepterProjet(String diffusionId, ProjectModel project, {String? commentaire, double? devisEstime}) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception("Utilisateur non connecté");

      final repo = ref.read(marketplaceRepositoryProvider);
      await repo.declareCompanyCapacity(
        projectId: project.id,
        entrepriseUserId: user.uid,
        commentaire: commentaire,
        devisEstime: devisEstime,
      );

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

final candidatureControllerProvider = StateNotifierProvider<CandidatureController, AsyncValue<void>>((ref) {
  return CandidatureController(ref);
});
