import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirestoreErrorHandler {
  static Future<T> execute<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      throw _translateFirebaseError(e);
    } on SocketException {
      throw 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    } catch (e) {
      throw 'Une erreur inattendue est survenue. Veuillez réessayer plus tard.';
    }
  }

  static String _translateFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Vous n\'avez pas les droits nécessaires pour effectuer cette action.';
      case 'unavailable':
        return 'Le service est temporairement indisponible (mode hors-ligne).';
      case 'not-found':
        return 'La ressource demandée est introuvable.';
      case 'already-exists':
        return 'Ce document existe déjà.';
      case 'deadline-exceeded':
        return 'Le délai d\'attente a expiré. Veuillez vérifier votre connexion.';
      default:
        return 'Une erreur serveur est survenue (Code: ${e.code}).';
    }
  }

  static void showSnackBarError(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
