import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chantier_track/core/widgets/app_button.dart';
import 'package:chantier_track/core/widgets/app_card.dart';
import 'package:chantier_track/core/widgets/app_badge.dart';

void main() {
  group('Design System - AppButton', () {
    testWidgets('affiche le texte et repond au tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Cliquez-moi',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Vérifie l'affichage du texte
      expect(find.text('Cliquez-moi'), findsOneWidget);

      // Tap le bouton
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('affiche un spinner quand isLoading est true et ne repond pas', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Chargement',
              isLoading: true,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Vérifie que le spinner est là
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Tap le bouton
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });

  group('Design System - AppCard', () {
    testWidgets('rend les enfants correctement', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: Text('Contenu de la carte'),
            ),
          ),
        ),
      );

      expect(find.text('Contenu de la carte'), findsOneWidget);
    });
  });

  group('Design System - AppBadge', () {
    testWidgets('affiche le label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBadge(
              label: 'Nouveau',
            ),
          ),
        ),
      );

      expect(find.text('Nouveau'), findsOneWidget);
    });
  });
}
