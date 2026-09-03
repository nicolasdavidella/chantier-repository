import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance);
});

class StorageService {
  final FirebaseStorage _storage;

  StorageService(this._storage);

  /// Uploads a file to a specific path in Firebase Storage and returns its download URL.
  /// The path should include the file name and extension (e.g., 'profile_pictures/uid/image.jpg').
  Future<String> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur lors de l\'upload du fichier : $e');
    }
  }

  /// Uploads data (bytes) to a specific path in Firebase Storage and returns its download URL.
  /// This is safe for Web where dart:io File is not supported.
  Future<String> uploadData(String path, Uint8List data, {String? contentType}) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = contentType != null ? SettableMetadata(contentType: contentType) : null;
      final uploadTask = metadata != null ? ref.putData(data, metadata) : ref.putData(data);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur lors de l\'upload des données : $e');
    }
  }


  /// Uploads a file with progress tracking. 
  /// Provide an onProgress callback to track the upload percentage (0.0 to 1.0).
  Future<String> uploadFileWithProgress(String path, File file, void Function(double) onProgress) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur lors de l\'upload du fichier : $e');
    }
  }

  /// Deletes a file from Firebase Storage.
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      // Ignorer si le fichier n'existe pas
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      throw Exception('Erreur lors de la suppression du fichier : $e');
    }
  }

  /// Deletes a file given its download URL.
  Future<void> deleteFileFromUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      throw Exception('Erreur lors de la suppression du fichier : $e');
    }
  }
}
