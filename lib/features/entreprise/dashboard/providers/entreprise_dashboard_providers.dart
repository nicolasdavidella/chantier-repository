import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
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
      .asyncMap((snap) async {
    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data();
      data['id'] = snap.docs.first.id;
      return EntrepriseModel.fromJson(data);
    }
    final directDoc = await FirebaseFirestore.instance.collection('entreprises').doc(user.uid).get();
    if (directDoc.exists && directDoc.data() != null) {
      final data = directDoc.data()!;
      data['id'] = directDoc.id;
      return EntrepriseModel.fromJson(data);
    }
    return null;
  });
});

// ─── Mes Chantiers (tous statuts) ──────────────────
final mesChantierStreamProvider = StreamProvider.autoDispose<List<ProjectModel>>((ref) {
  final entreprise = ref.watch(currentEntrepriseStreamProvider).value;
  final user = ref.watch(authStateProvider).value;
  if (entreprise == null && user == null) return const Stream.empty();
  
  final entId = entreprise?.id ?? user?.uid ?? '';
  final uId = user?.uid ?? entreprise?.userId;
  
  return ref
      .watch(entrepriseDashboardRepositoryProvider)
      .watchAllEntrepriseProjects(entId, uId);
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
  final authUser = FirebaseAuth.instance.currentUser;
  final user = ref.watch(authStateProvider).value;

  final entId = entreprise?.id ?? '';
  final uId = authUser?.uid ?? user?.uid ?? '';

  if (entId.isEmpty && uId.isEmpty) return const Stream.empty();

  return ref
      .watch(entrepriseDashboardRepositoryProvider)
      .watchEntrepriseDevis(entId, uId);
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

  Future<String?> submitDevis(
    DevisModel devis, {
    String? targetClientId,
    String? projectTitle,
  }) async {
    state = const AsyncLoading();
    String? resultConversationId;

    try {
      final authUser = FirebaseAuth.instance.currentUser;
      final user = ref.read(authStateProvider).value;
      final currentUserId = authUser?.uid ?? user?.uid ?? devis.entrepriseId;

      // 1. Sauvegarder le devis dans Firestore avec son propre ID
      final devisDocRef = FirebaseFirestore.instance.collection('devis').doc();
      final devisWithId = devis.copyWith(id: devisDocRef.id);
      
      try {
        await devisDocRef.set(devisWithId.toJson());
      } catch (e) {
        debugPrint('Note: enregistrement devis collection racine: $e');
      }

      // Également dans la sous-collection du projet pour redondance
      try {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(devis.projectId)
            .collection('devis')
            .doc(devisDocRef.id)
            .set(devisWithId.toJson());
      } catch (e) {
        debugPrint('Note: enregistrement devis sous-collection projet: $e');
      }

      // 2. Mettre à jour le projet
      try {
        await FirebaseFirestore.instance.collection('projects').doc(devis.projectId).update({
          'devisEnvoyeParEntreprise': devis.entrepriseId,
          'statut': 'devis_recu',
        });
      } catch (e) {
        debugPrint('Note: mise à jour projet: $e');
      }

      // 3. Envoyer le devis dans la discussion du client
      try {
        String? clientId = targetClientId;
        String pTitre = projectTitle ?? 'Chantier';

        if (clientId == null || clientId.isEmpty) {
          final projectDoc = await FirebaseFirestore.instance.collection('projects').doc(devis.projectId).get();
          if (projectDoc.exists && projectDoc.data() != null) {
            final pData = projectDoc.data()!;
            clientId = pData['clientId'] as String? ??
                pData['clientUserId'] as String? ??
                pData['userId'] as String?;
            final t = pData['titre'] as String?;
            if (t != null && t.isNotEmpty) pTitre = t;
          }
        }

        if (clientId != null && clientId.isNotEmpty) {
          // Nom du client
          String clientName = 'Client';
          try {
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(clientId).get();
            if (userDoc.exists && userDoc.data() != null) {
              final u = userDoc.data()!;
              final fullName = '${u['prenom'] ?? ''} ${u['nom'] ?? ''}'.trim();
              if (fullName.isNotEmpty) clientName = fullName;
            }
          } catch (_) {}

          // Nom de l'entreprise
          final entreprise = ref.read(currentEntrepriseStreamProvider).value;
          final entrepriseName = entreprise?.raisonSociale ?? 'Entreprise';

          final chatRepo = ref.read(chatRepositoryProvider);
          final conv = await chatRepo.getOrCreateConversation(
            currentUserId: currentUserId,
            targetUserId: clientId,
            currentUserName: entrepriseName,
            targetUserName: clientName,
            projectId: devis.projectId,
          );
          resultConversationId = conv.id;

          final devisMontantFormate = NumberFormat.currency(
            locale: 'fr_FR',
            symbol: 'FCFA',
            decimalDigits: 0,
          ).format(devis.montant);

          final messageContent = "📄 Proposition de Devis pour \"$pTitre\"\n\n"
              "💰 Montant : $devisMontantFormate\n"
              "⏱️ Délai estimé : ${devis.delaiEstime}\n"
              "📋 Détails des travaux :\n${devis.description}";

          await chatRepo.sendMessage(
            conv.id,
            messageContent,
            currentUserId,
            type: 'quote',
            metadata: {
              'quoteAmount': devis.montant,
              'quoteStatus': 'pending',
              'quoteDelay': devis.delaiEstime,
              'quoteDescription': devis.description,
              'devisId': devisDocRef.id,
              'projectId': devis.projectId,
              'projectTitle': pTitre,
            },
          );
        }
      } catch (e) {
        debugPrint('Erreur lors de l\'envoi du message devis au client: $e');
      }

      state = const AsyncData(null);
      return resultConversationId;
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
