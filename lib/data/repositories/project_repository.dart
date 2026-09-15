import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(FirebaseFirestore.instance);
});

class ProjectRepository {
  final FirebaseFirestore _firestore;

  ProjectRepository(this._firestore);

  // Stream des projets d'un client (temps réel)
  Stream<List<ProjectModel>> watchClientProjects(String clientId) {
    return _firestore
        .collection('projects')
        .where('clientId', isEqualTo: clientId)
        .orderBy('dateDebut', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return ProjectModel.fromJson(data);
            }).toList());
  }

  // Stream des projets actifs d'une entreprise (temps réel)
  Stream<List<ProjectModel>> watchEntrepriseProjects(String entrepriseId) {
    return _firestore
        .collection('projects')
        .where('entrepriseId', isEqualTo: entrepriseId)
        .where('statut', isEqualTo: 'en_cours')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return ProjectModel.fromJson(data);
            }).toList());
  }

  // Stream des demandes ouvertes (en recherche d'entreprise)
  Stream<List<ProjectModel>> watchOpenRequests() {
    return _firestore
        .collection('projects')
        .where('statut', isEqualTo: 'en_recherche_entreprise')
        .orderBy('dateDebut', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return ProjectModel.fromJson(data);
            }).toList());
  }

  // Lire un projet par son id
  Future<ProjectModel?> getById(String id) async {
    final doc = await _firestore.collection('projects').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return ProjectModel.fromJson(data);
  }

  // Créer un nouveau projet
  Future<String> create(ProjectModel project) async {
    final ref = await _firestore.collection('projects').add(project.toJson());
    return ref.id;
  }

  // Mettre à jour un projet
  Future<void> update(ProjectModel project) async {
    await _firestore
        .collection('projects')
        .doc(project.id)
        .update(project.toJson());
  }

  // Mettre à jour uniquement le statut
  Future<void> updateStatus(String projectId, String statut) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .update({'statut': statut});
  }
}
