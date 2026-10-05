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
  Stream<List<ProjectModel>> watchAllEntrepriseProjects(String entrepriseId) {
    return _db
        .collection('projects')
        .where('entrepriseId', isEqualTo: entrepriseId)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return ProjectModel.fromJson(data);
            }).toList());
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
  Stream<List<DevisModel>> watchEntrepriseDevis(String entrepriseId) {
    return _db
        .collection('devis')
        .where('entrepriseId', isEqualTo: entrepriseId)
        .orderBy('dateEnvoi', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return DevisModel.fromJson(data);
            }).toList());
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
