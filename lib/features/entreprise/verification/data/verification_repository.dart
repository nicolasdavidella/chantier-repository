import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/verification_request_model.dart';
import '../../../../data/models/verification_document_model.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

class VerificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  VerificationRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  // Obtenir ou créer une demande en brouillon pour une entreprise
  Future<VerificationRequestModel> getOrCreateDraftRequest(String entrepriseId) async {
    final querySnapshot = await _firestore
        .collection('verification_requests')
        .where('entrepriseId', isEqualTo: entrepriseId)
        .where('status', isEqualTo: 'DRAFT')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return VerificationRequestModel.fromJson(querySnapshot.docs.first.data());
    }

    // Créer un nouveau brouillon
    final docRef = _firestore.collection('verification_requests').doc();
    final newRequest = VerificationRequestModel(
      id: docRef.id,
      entrepriseId: entrepriseId,
      status: 'DRAFT',
      createdAt: DateTime.now(),
    );

    await docRef.set(newRequest.toJson());
    return newRequest;
  }

  // Téléverser un document vers Firebase Storage
  Future<String> uploadDocument(String entrepriseId, String requestId, String docType, File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _storage.ref().child('verification_documents/$entrepriseId/$requestId/$docType/$fileName');
    
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  // Ajouter un document à la demande
  Future<void> addDocumentToRequest(String requestId, VerificationDocumentModel document) async {
    final requestRef = _firestore.collection('verification_requests').doc(requestId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(requestRef);
      if (!snapshot.exists) throw Exception("Demande non trouvée");
      
      final request = VerificationRequestModel.fromJson(snapshot.data()!);
      final updatedDocs = List<VerificationDocumentModel>.from(request.documents);
      
      // Remplacer si existe déjà, sinon ajouter
      final index = updatedDocs.indexWhere((d) => d.type == document.type);
      if (index != -1) {
        updatedDocs[index] = document;
      } else {
        updatedDocs.add(document);
      }
      
      transaction.update(requestRef, {
        'documents': updatedDocs.map((e) => e.toJson()).toList(),
      });
    });
  }

  // Soumettre la demande
  Future<void> submitRequest(String requestId, String entrepriseId) async {
    await _firestore.collection('verification_requests').doc(requestId).update({
      'status': 'SUBMITTED',
      'submittedAt': FieldValue.serverTimestamp(),
    });

    // Mettre à jour le statut de l'entreprise
    await _firestore.collection('entreprises').doc(entrepriseId).update({
      'verificationStatus': 'SUBMITTED',
    });
  }

  // Récupérer la demande active pour l'entreprise (non approuvée)
  Stream<VerificationRequestModel?> watchActiveRequest(String entrepriseId) {
    return _firestore
        .collection('verification_requests')
        .where('entrepriseId', isEqualTo: entrepriseId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return VerificationRequestModel.fromJson(snapshot.docs.first.data());
    });
  }
}
