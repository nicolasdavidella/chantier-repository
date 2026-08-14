import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/entreprise_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }
  
  Future<void> createEntreprise(EntrepriseModel entreprise) async {
    await _firestore.collection('entreprises').doc(entreprise.id).set(entreprise.toJson());
  }
}
