import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chantier_track/features/client/create_project/presentation/project_creation_wizard.dart';

void main() {
  group('ProjectCreationWizardScreen', () {
    testWidgets('affiche la première étape (Détails) au lancement', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectCreationWizardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Vérifie que le titre de l'app bar est correct
      expect(find.text('Nouveau projet'), findsOneWidget);
      
      // La première étape demande le titre du projet
      expect(find.text('Titre du projet'), findsOneWidget);
    });

    testWidgets('le bouton "Continuer" ne passe pas si le formulaire est vide', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectCreationWizardScreen(),
          ),
        ),
      );

      // On tente de cliquer sur Continuer
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      // On devrait voir des messages d'erreur de validation car le champ titre est vide
      expect(find.text('Le titre est requis'), findsWidgets);
      
      // On est toujours à l'étape 1
      expect(find.text('Titre du projet'), findsOneWidget);
    });
  });
}
