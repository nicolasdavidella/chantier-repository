import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/project_model.dart';
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
  
  // Stream diffusions for this enterprise with status 'envoye'
  return firestore
      .collection('diffusions_projet')
      .where('entrepriseId', isEqualTo: user.uid)
      .where('statut', isEqualTo: 'envoye')
      .snapshots()
      .asyncMap((snapshot) async {
    
    List<ProjectDiffusion> result = [];
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final projectId = data['projectId'] as String;
      
      // Fetch the actual project
      final projectDoc = await firestore.collection('projects').doc(projectId).get();
      if (projectDoc.exists) {
        final project = ProjectModel.fromJson(projectDoc.data()!);
        // Only show if the project is still searching
        if (project.statut == 'en_recherche_entreprise') {
          result.add(ProjectDiffusion(
            diffusionId: doc.id,
            project: project,
          ));
        }
      }
    }
    
    result.sort((a, b) => b.project.dateDebut.compareTo(a.project.dateDebut));
    return result;
  });
});

class CandidatureController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CandidatureController(this.ref) : super(const AsyncData(null));

  Future<void> accepterProjet(String diffusionId, ProjectModel project) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception("Utilisateur non connecté");

      final firestore = FirebaseFirestore.instance;
      
      await firestore.runTransaction((transaction) async {
        final diffRef = firestore.collection('diffusions_projet').doc(diffusionId);
        final diffSnapshot = await transaction.get(diffRef);
        
        if (!diffSnapshot.exists) {
          throw Exception("Diffusion introuvable");
        }
        
        if (diffSnapshot.data()?['statut'] != 'envoye') {
          throw Exception("Cette offre a déjà été acceptée ou n'est plus disponible.");
        }
        
        // 1. Mettre à jour la diffusion
        transaction.update(diffRef, {
          'statut': 'accepte',
          'dateAcceptation': FieldValue.serverTimestamp(),
        });

        // 2. Récupérer les infos de l'entreprise pour la notification
        final entRef = firestore.collection('entreprises').doc(user.uid);
        final entSnapshot = await transaction.get(entRef);
        final nomEntreprise = entSnapshot.exists ? (entSnapshot.data()?['raisonSociale'] ?? 'Une entreprise') : 'Une entreprise';
        final note = entSnapshot.exists ? (entSnapshot.data()?['noteGlobale'] ?? 'N/A') : 'N/A';
        final logo = entSnapshot.exists ? (entSnapshot.data()?['logoUrl'] ?? '') : '';

        // 3. Notifier le client instantanément
        final notifRef = firestore.collection('notifications').doc();
        transaction.set(notifRef, {
          'userId': project.clientId,
          'titre': "Nouvelle entreprise intéressée !",
          'message': "$nomEntreprise peut réaliser votre projet. Note: $note",
          'logoUrl': logo,
          'entrepriseId': user.uid,
          'projectId': project.id,
          'isRead': false,
          'type': 'entreprise_accepte',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

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
