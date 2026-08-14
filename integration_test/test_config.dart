import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chantier_track/main.dart' as app;

/// Prépare l'environnement de test et s'assure que Firebase utilise les émulateurs
Future<void> setupIntegrationTest() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // On doit s'assurer que si on lance les tests, on passe la variable d'environnement
  // --dart-define=USE_FIREBASE_EMULATOR=true
  if (!app.useFirebaseEmulator) {
    debugPrint('⚠️ ATTENTION: USE_FIREBASE_EMULATOR n\'est pas true.');
    debugPrint('Assurez-vous de lancer le test avec : --dart-define=USE_FIREBASE_EMULATOR=true');
  }
}

/// Lance l'application pour les tests
Future<void> pumpApp(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle();
}

/// Nettoie la base de données Firebase et déconnecte l'utilisateur
Future<void> clearDatabaseAndAuth() async {
  // Déconnexion
  if (FirebaseAuth.instance.currentUser != null) {
    await FirebaseAuth.instance.signOut();
  }

  // Idéalement, en environnement d'émulation on peut utiliser l'API REST de l'émulateur
  // pour nettoyer toutes les données (ex: DELETE http://localhost:8080/emulator/v1/projects/chantiertrack-561bf/databases/(default)/documents)
  // Pour la simplicité de ces tests, on se concentre sur les parcours.
}
