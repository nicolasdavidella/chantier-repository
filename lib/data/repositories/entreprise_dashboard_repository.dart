import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tache_model.dart';
import '../models/devis_model.dart';
import '../models/rapport_avancement_model.dart';
import '../models/membre_equipe_model.dart';
import '../models/project_model.dart';

final entrepriseDashboardRepositoryProvider = Provider<EntrepriseDashboardRepository>((ref) {
  return EntrepriseDashboardRepository(FirebaseFirestore.instance);
});

class EntrepriseDashboardRepository {
  final FirebaseFirestore _db;
  EntrepriseDashboardRepository(this._db);

  // ─── PROJETS ─────────────────────────────────────
  /// Tous les projets d'une entreprise (tous statuts)
  Stream<List<ProjectModel>> watchAllEntrepriseProjects(String entrepriseId, [String? userId]) {
    return _db.collection('projects').snapshots().map((snap) {
      return snap.docs
          .map((d) {
            final data = d.data();
            data['id'] = d.id;
            return ProjectModel.fromJson(data);
          })
          .where((p) =>
              p.entrepriseId == entrepriseId ||
              (userId != null && p.entrepriseId == userId))
          .toList();
    });
  }

  /// Projets ouverts (en recherche d'entreprise = appels d'offres)
  Stream<List<ProjectModel>> watchOpenProjects() {
    return _db
        .collection('projects')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) {
              final data = d.data();
              data['id'] = d.id;
              return ProjectModel.fromJson(data);
            })
            .where((p) =>
                (p.statut == 'en_recherche_entreprise' ||
                    p.statut == 'plan_valide' ||
                    p.isMarketplacePublished == true) &&
                p.statut != 'en_cours' &&
                p.statut != 'termine')
            .toList());
  }

  // ─── TÂCHES ──────────────────────────────────────
  Stream<List<TacheModel>> watchProjectTaches(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('taches')
        .orderBy('ordre')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return TacheModel.fromJson(data);
            }).toList());
  }

  Future<void> createTache(TacheModel tache) async {
    final ref = _db.collection('projects').doc(tache.projectId).collection('taches').doc();
    final data = tache.toJson();
    data['id'] = ref.id;
    await ref.set(data);
  }

  Future<void> updateTacheStatut(String projectId, String tacheId, String statut) async {
    await _db
        .collection('projects')
        .doc(projectId)
        .collection('taches')
        .doc(tacheId)
        .update({'statut': statut});
  }

  // ─── DEVIS ───────────────────────────────────────
  Stream<List<DevisModel>> watchEntrepriseDevis(String entrepriseId, [String? userId]) {
    final activeId = (userId != null && userId.isNotEmpty) ? userId : entrepriseId;
    if (activeId.isNotEmpty) {
      _syncQuotesFromConversations(activeId);
    }

    return _db
        .collection('devis')
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return DevisModel.fromJson(data);
          }).where((d) {
            if (entrepriseId.isEmpty && (userId == null || userId.isEmpty)) {
              return true;
            }
            // Real devis belonging to user or created by/for user
            final matchesEntreprise = entrepriseId.isNotEmpty && d.entrepriseId == entrepriseId;
            final matchesUser = userId != null && userId.isNotEmpty && d.entrepriseId == userId;
            final matchesClient = (userId != null && userId.isNotEmpty && d.clientId == userId) ||
                (entrepriseId.isNotEmpty && d.clientId == entrepriseId);
            final isLocalOrMe = d.entrepriseId == 'me' || d.entrepriseId.isEmpty;
            final isTargetClient = (d.clientName?.toLowerCase().contains('nicolas') ?? false) ||
                (d.clientName?.toLowerCase().contains('ella') ?? false);

            return matchesEntreprise || matchesUser || matchesClient || isLocalOrMe || isTargetClient;
          }).toList();
          list.sort((a, b) => b.dateEnvoi.compareTo(a.dateEnvoi));
          return list;
        });
  }

  void _syncQuotesFromConversations(String currentUserId) async {
    try {
      final convsSnap = await _db
          .collection('conversations')
          .where('participantsIds', arrayContains: currentUserId)
          .get();

      for (final convDoc in convsSnap.docs) {
        final convData = convDoc.data();
        final projectId = convData['projectId']?.toString() ?? '';
        final participantNames = (convData['participantNames'] as Map<String, dynamic>?) ?? {};
        final participants = (convData['participantsIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final otherId = participants.firstWhere((p) => p != currentUserId, orElse: () => '');
        final clientName = participantNames[otherId]?.toString() ?? 'Client';

        final msgsSnap = await convDoc.reference
            .collection('messages')
            .where('type', isEqualTo: 'quote')
            .get();

        for (final mDoc in msgsSnap.docs) {
          final mData = mDoc.data();
          final metadata = (mData['metadata'] as Map<String, dynamic>?) ?? {};
          final devisId = metadata['devisId']?.toString() ?? mDoc.id;
          final expediteurId = mData['expediteurId']?.toString() ?? currentUserId;

          final amountNum = metadata['quoteAmount'] ?? 0;
          final amount = (amountNum is num)
              ? amountNum.toDouble()
              : (double.tryParse(amountNum.toString()) ?? 0.0);
          final delay = metadata['quoteDelay']?.toString() ?? mData['contenu']?.toString() ?? '';
          final desc = metadata['quoteDescription']?.toString() ?? mData['contenu']?.toString() ?? 'Proposition de devis';
          final statusRaw = metadata['quoteStatus']?.toString() ?? 'pending';
          final statut = statusRaw == 'accepted' ? 'accepte' : (statusRaw == 'rejected' ? 'refuse' : 'en_attente');
          final pTitle = metadata['projectTitle']?.toString() ?? 'Devis pour $clientName';

          DateTime parseMsgDate(dynamic d) {
            if (d is Timestamp) return d.toDate();
            if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
            return DateTime.now();
          }

          final devisRef = _db.collection('devis').doc(devisId);
          final existing = await devisRef.get();
          if (!existing.exists) {
            final devisModel = DevisModel(
              id: devisId,
              projectId: projectId,
              entrepriseId: expediteurId,
              montant: amount,
              delaiEstime: delay,
              description: desc,
              dateEnvoi: parseMsgDate(mData['dateEnvoi']),
              statut: statut,
              projectTitle: pTitle,
              clientName: clientName,
              clientId: otherId,
            );
            await devisRef.set(devisModel.toJson());
          }
        }
      }
    } catch (_) {}
  }

  Future<void> createDevis(DevisModel devis) async {
    final ref = _db.collection('devis').doc();
    final data = devis.toJson();
    data['id'] = ref.id;
    await ref.set(data);
    // Notifie le client en mettant un flag sur le projet
    await _db.collection('projects').doc(devis.projectId).update({
      'devisEnvoyeParEntreprise': devis.entrepriseId,
      'statut': 'devis_recu',
    });
  }

  // ─── RAPPORTS ────────────────────────────────────
  Stream<List<RapportAvancementModel>> watchRapportsForProject(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('rapports')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return RapportAvancementModel.fromJson(data);
            }).toList());
  }

  // ─── MEMBRES ÉQUIPE ──────────────────────────────
  Stream<List<MembreEquipeModel>> watchMembresEquipe(String entrepriseId) {
    return _db
        .collection('membres_equipe')
        .where('entrepriseId', isEqualTo: entrepriseId)
        .orderBy('dateAjout', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return MembreEquipeModel.fromJson(data);
            }).toList());
  }

  Future<void> addMembre(MembreEquipeModel membre) async {
    final ref = _db.collection('membres_equipe').doc();
    final data = membre.toJson();
    data['id'] = ref.id;
    await ref.set(data);
  }

  Future<void> updateMembreStatut(String membreId, String statut) async {
    await _db.collection('membres_equipe').doc(membreId).update({'statut': statut});
  }

  Future<void> updateMembre(MembreEquipeModel membre) async {
    await _db.collection('membres_equipe').doc(membre.id).update(membre.toJson());
  }

  // ─── ENTREPRISE PROFILE ──────────────────────────
  Future<void> updateEntrepriseProfile(String entrepriseId, Map<String, dynamic> fields) async {
    await _db.collection('entreprises').doc(entrepriseId).set(fields, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> watchEntrepriseProfile(String entrepriseId) {
    return _db.collection('entreprises').doc(entrepriseId).snapshots().map((d) {
      if (!d.exists) return null;
      final data = d.data()!;
      data['id'] = d.id;
      return data;
    });
  }
}
