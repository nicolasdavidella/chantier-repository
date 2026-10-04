import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/models/tache_model.dart';
import '../../../../data/models/devis_model.dart';
import '../../../../data/models/rapport_avancement_model.dart';
import '../../../../data/models/membre_equipe_model.dart';
import '../../../../data/models/entreprise_model.dart';
import '../../../../data/repositories/entreprise_dashboard_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../chat/providers/chat_providers.dart';

// ─── Profil Entreprise courant (stream) ───────────
final currentEntrepriseStreamProvider = StreamProvider.autoDispose<EntrepriseModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('entreprises')
      .where('userId', isEqualTo: user.uid)
      .limit(1)
      .snapshots()
      .map((snap) {
    if (snap.docs.isEmpty) return null;
    final data = snap.docs.first.data();
    data['id'] = snap.docs.first.id;
    return EntrepriseModel.fromJson(data);
  });
});

// ─── Mes Chantiers (tous statuts) ──────────────────
final mesChantierStreamProvider = StreamProvider.autoDispose<List<ProjectModel>>((ref) {
  final entreprise = ref.watch(currentEntrepriseStreamProvider).value;
  if (entreprise == null) return const Stream.empty();
  return ref
      .watch(entrepriseDashboardRepositoryProvider)
      .watchAllEntrepriseProjects(entreprise.id);
});

// ─── Appels d'offres ouverts ────────────────────────
final appelsOffresStreamProvider = StreamProvider.autoDispose<List<ProjectModel>>((ref) {
  return ref.watch(entrepriseDashboardRepositoryProvider).watchOpenProjects();
});

// ─── Tâches d'un projet ─────────────────────────────
final tachesProjectStreamProvider =
    StreamProvider.autoDispose.family<List<TacheModel>, String>((ref, projectId) {
  return ref
      .watch(entrepriseDashboardRepositoryProvider)
      .watchProjectTaches(projectId);
});

// ─── Devis de l'entreprise ──────────────────────────
final mesDevisStreamProvider = StreamProvider.autoDispose<List<DevisModel>>((ref) {
  final entreprise = ref.watch(currentEntrepriseStreamProvider).value;
  if (entreprise == null) return const Stream.empty();
  return ref
      .watch(entrepriseDashboardRepositoryProvider)
      .watchEntrepriseDevis(entreprise.id);
});

// ─── Rapports d'un projet ───────────────────────────
final rapportsProjectStreamProvider =
    StreamProvider.autoDispose.family<List<RapportAvancementModel>, String>((ref, projectId) {
  return ref
      .watch(entrepriseDashboardRepositoryProvider)
      .watchRapportsForProject(projectId);
});

// ─── Membres de l'équipe ────────────────────────────
final membresEquipeStreamProvider = StreamProvider.autoDispose<List<MembreEquipeModel>>((ref) {
  final entreprise = ref.watch(currentEntrepriseStreamProvider).value;
  if (entreprise == null) return const Stream.empty();
  return ref
      .watch(entrepriseDashboardRepositoryProvider)
      .watchMembresEquipe(entreprise.id);
});

// ─── Controller Tâches ──────────────────────────────
class TacheController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  TacheController(this.ref) : super(const AsyncData(null));

  Future<void> createTache(TacheModel tache) async {
    state = const AsyncLoading();
    try {
      await ref.read(entrepriseDashboardRepositoryProvider).createTache(tache);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateStatut(String projectId, String tacheId, String statut) async {
    await ref
        .read(entrepriseDashboardRepositoryProvider)
        .updateTacheStatut(projectId, tacheId, statut);
  }
}

final tacheControllerProvider =
    StateNotifierProvider<TacheController, AsyncValue<void>>(
        (ref) => TacheController(ref));

// ─── Controller Devis ───────────────────────────────
class DevisController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  DevisController(this.ref) : super(const AsyncData(null));

  Future<void> submitDevis(DevisModel devis) async {
    state = const AsyncLoading();
    try {
      await ref.read(entrepriseDashboardRepositoryProvider).createDevis(devis);
      
      // Send a chat message with the devis
      try {
        final projectDoc = await FirebaseFirestore.instance.collection('projects').doc(devis.projectId).get();
        if (projectDoc.exists) {
          final clientId = projectDoc.data()?['clientId'] as String?;
          if (clientId != null) {
            final chatRepo = ref.read(chatRepositoryProvider);
            final conv = await chatRepo.getOrCreateConversation(
              currentUserId: devis.entrepriseId,
              targetUserId: clientId,
              currentUserName: 'Entreprise',
              targetUserName: 'Client',
              projectId: devis.projectId,
            );
            
            await chatRepo.sendMessage(
              conv.id,
              'Délai : ${devis.delaiEstime}\n${devis.description}',
              devis.entrepriseId,
              type: 'quote',
              metadata: {
                'quoteAmount': devis.montant,
                'quoteStatus': 'pending',
                'devisId': devis.id,
              },
            );
          }
        }
      } catch (e) {
        print('Error sending quote message: $e');
      }
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final devisControllerProvider =
    StateNotifierProvider<DevisController, AsyncValue<void>>(
        (ref) => DevisController(ref));

// ─── Controller Membres ─────────────────────────────
class MembreController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  MembreController(this.ref) : super(const AsyncData(null));

  Future<void> addMembre(MembreEquipeModel membre) async {
    state = const AsyncLoading();
    try {
      await ref.read(entrepriseDashboardRepositoryProvider).addMembre(membre);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> toggleStatut(String membreId, String currentStatut) async {
    final newStatut = currentStatut == 'actif' ? 'inactif' : 'actif';
    await ref
        .read(entrepriseDashboardRepositoryProvider)
        .updateMembreStatut(membreId, newStatut);
  }
}

final membreControllerProvider =
    StateNotifierProvider<MembreController, AsyncValue<void>>(
        (ref) => MembreController(ref));

// ─── Controller Profil Entreprise ───────────────────
class EntrepriseProfileController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  EntrepriseProfileController(this.ref) : super(const AsyncData(null));

  Future<void> updateProfile(String entrepriseId, Map<String, dynamic> fields) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(entrepriseDashboardRepositoryProvider)
          .updateEntrepriseProfile(entrepriseId, fields);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final entrepriseProfileControllerProvider =
    StateNotifierProvider<EntrepriseProfileController, AsyncValue<void>>(
        (ref) => EntrepriseProfileController(ref));
