import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/models/candidature_model.dart';
import '../../../auth/providers/auth_provider.dart';

final offresProvider = StreamProvider.autoDispose<List<ProjectModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('projets')
      .where('statut', isEqualTo: 'en_recherche_entreprise')
      .snapshots()
      .map((snapshot) {
    final projets = snapshot.docs.map((doc) => ProjectModel.fromJson(doc.data())).toList();
    // Tri local pour éviter d'avoir besoin d'un index composite Firebase
    projets.sort((a, b) => b.dateDebut.compareTo(a.dateDebut));
    return projets;
  });
});

class CandidatureController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CandidatureController(this.ref) : super(const AsyncData(null));

  Future<void> accepterProjet(String projectId) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception("Utilisateur non connecté");

      final firestore = FirebaseFirestore.instance;
      final candidatureId = firestore.collection('candidatures').doc().id;

      final candidature = CandidatureModel(
        id: candidatureId,
        projectId: projectId,
        entrepriseId: user.uid,
        dateCandidature: DateTime.now(),
        statut: 'en_attente',
      );

      await firestore.collection('candidatures').doc(candidatureId).set(candidature.toJson());
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
