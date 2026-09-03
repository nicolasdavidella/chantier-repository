import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/project_model.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(FirebaseFirestore.instance);
});

class ProjectRepository {
  final FirebaseFirestore _firestore;

  ProjectRepository(this._firestore);

  /// Récupère en temps réel les projets créés par un client spécifique
  Stream<List<ProjectModel>> getClientProjects(String clientId) {
    return _firestore
        .collection('projets')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      final projects = snapshot.docs.map((doc) => ProjectModel.fromJson(doc.data())).toList();
      // Tri local pour éviter de nécessiter un index composite Firestore
      projects.sort((a, b) => b.dateDebut.compareTo(a.dateDebut));
      return projects;
    });
  }

  /// Récupère un projet spécifique en temps réel
  Stream<ProjectModel?> getProjectById(String projectId) {
    return _firestore.collection('projets').doc(projectId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return ProjectModel.fromJson(doc.data()!);
      }
      return null;
    });
  }
}
