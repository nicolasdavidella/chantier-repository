import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/entreprise_model.dart';

final entrepriseRepositoryProvider = Provider<EntrepriseRepository>((ref) {
  return EntrepriseRepository(FirebaseFirestore.instance);
});

class EntrepriseRepository {
  final FirebaseFirestore _firestore;

  EntrepriseRepository(this._firestore);

  // Stream de toutes les entreprises (temps réel)
  Stream<List<EntrepriseModel>> watchAll() {
    return _firestore
        .collection('entreprises')
        .orderBy('noteMoyenne', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return EntrepriseModel.fromJson(data);
            }).toList());
  }

  // Stream des entreprises recommandées (note >= 4.0)
  Stream<List<EntrepriseModel>> watchRecommended({int limit = 10}) {
    return _firestore
        .collection('entreprises')
        .where('noteMoyenne', isGreaterThanOrEqualTo: 4.0)
        .orderBy('noteMoyenne', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return EntrepriseModel.fromJson(data);
            }).toList());
  }

  // Stream filtrée par ville
  Stream<List<EntrepriseModel>> watchByVille(String ville) {
    return _firestore
        .collection('entreprises')
        .where('zoneIntervention', arrayContains: ville)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return EntrepriseModel.fromJson(data);
            }).toList());
  }

  // Stream filtrée par spécialité
  Stream<List<EntrepriseModel>> watchBySpecialite(String specialite) {
    return _firestore
        .collection('entreprises')
        .where('specialites', arrayContains: specialite)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return EntrepriseModel.fromJson(data);
            }).toList());
  }

  // Lire une entreprise par son userId
  Future<EntrepriseModel?> getByUserId(String userId) async {
    final snap = await _firestore
        .collection('entreprises')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final data = snap.docs.first.data();
    data['id'] = snap.docs.first.id;
    return EntrepriseModel.fromJson(data);
  }

  // Lire une entreprise par son id
  Future<EntrepriseModel?> getById(String id) async {
    final doc = await _firestore.collection('entreprises').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return EntrepriseModel.fromJson(data);
  }

  // Créer ou mettre à jour une entreprise
  Future<void> save(EntrepriseModel entreprise) async {
    await _firestore
        .collection('entreprises')
        .doc(entreprise.id)
        .set(entreprise.toJson(), SetOptions(merge: true));
  }
}
