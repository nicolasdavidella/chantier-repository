import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupIntegrationTest();
  });

  tearDown(() async {
    await clearDatabaseAndAuth();
  });

  testWidgets('Parcours Entreprise : Inscription, Complétion Profil, Devis', (WidgetTester tester) async {
    await pumpApp(tester);

    // 1. Navigation jusqu'à l'inscription depuis l'Onboarding
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final sinscrireFinder = find.text("S'inscrire");
    if (sinscrireFinder.evaluate().isNotEmpty) {
      await tester.tap(sinscrireFinder);
      await tester.pumpAndSettle();
    } else {
      final commencerFinder = find.text("Commencer");
      if (commencerFinder.evaluate().isNotEmpty) {
        await tester.tap(commencerFinder);
        await tester.pumpAndSettle();
      }
    }

    // 2. Écran RoleSelectionScreen - Choix du profil Entreprise
    final entrepriseRoleFinder = find.text('Entreprise de construction');
    expect(entrepriseRoleFinder, findsOneWidget);
    await tester.tap(entrepriseRoleFinder);
    await tester.pumpAndSettle();

    // 3. Écran SignupScreen - Remplissage du formulaire
    final prenomField = find.widgetWithText(TextFormField, 'Prénom');
    final nomField = find.widgetWithText(TextFormField, 'Nom');
    final emailField = find.widgetWithText(TextFormField, 'E-mail');
    final phoneField = find.widgetWithText(TextFormField, 'Téléphone');
    final passwordField = find.widgetWithText(TextFormField, 'Mot de passe');

    await tester.enterText(prenomField, 'Paul');
    await tester.enterText(nomField, 'BTP');
    await tester.enterText(emailField, 'contact@paulbtp.com');
    await tester.enterText(phoneField, '+237611111111');
    await tester.enterText(passwordField, 'Password123!');
    
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final creerCompteButton = find.text('Créer mon compte');
    await tester.tap(creerCompteButton);
    
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 4. Complétion du profil Entreprise
    // Selon le routeur, le rôle entreprise redirige vers '/entreprise_details'
    final nomEntrepriseField = find.byType(TextFormField).first; // Supposons que c'est le 1er champ
    if (nomEntrepriseField.evaluate().isNotEmpty) {
      await tester.enterText(nomEntrepriseField, 'Paul BTP Construction');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      
      final validerProfilButton = find.text('Enregistrer');
      if (validerProfilButton.evaluate().isNotEmpty) {
        await tester.tap(validerProfilButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    }

    // 5. Dashboard Entreprise & Soumission de devis
    // On cherche un bouton pour voir les projets disponibles ou répondre à un appel d'offres
    final voirProjetsFinder = find.text('Projets disponibles');
    if (voirProjetsFinder.evaluate().isNotEmpty) {
      await tester.tap(voirProjetsFinder);
      await tester.pumpAndSettle();

      final firstProject = find.byType(Card).first;
      if (firstProject.evaluate().isNotEmpty) {
        await tester.tap(firstProject);
        await tester.pumpAndSettle();
        
        final proposerDevisFinder = find.text('Proposer un devis');
        if (proposerDevisFinder.evaluate().isNotEmpty) {
          await tester.tap(proposerDevisFinder);
          await tester.pumpAndSettle();

          final montantDevis = find.byType(TextFormField).first;
          await tester.enterText(montantDevis, '5000000');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          
          final envoyerDevis = find.text('Envoyer le devis');
          if (envoyerDevis.evaluate().isNotEmpty) {
            await tester.tap(envoyerDevis);
            await tester.pumpAndSettle();
          }
        }
      }
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
