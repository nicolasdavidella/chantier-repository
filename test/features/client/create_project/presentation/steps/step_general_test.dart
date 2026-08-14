import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chantier_track/features/client/create_project/presentation/steps/step_general.dart';

void main() {
  group('StepGeneral Form Validation', () {
    testWidgets('shows validation errors when fields are empty', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StepGeneral(formKey: formKey),
            ),
          ),
        ),
      );

      // Trigger validation
      formKey.currentState?.validate();
      await tester.pumpAndSettle();

      expect(find.text('Le titre est requis'), findsOneWidget);
      expect(find.text('La description est requise'), findsOneWidget);
    });

    testWidgets('no validation errors when fields are filled', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StepGeneral(formKey: formKey),
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField).first, 'Mon Projet');
      await tester.enterText(find.byType(TextFormField).last, 'Description du projet');
      await tester.pumpAndSettle();

      // Trigger validation
      final isValid = formKey.currentState?.validate() ?? false;
      await tester.pumpAndSettle();

      expect(isValid, isTrue);
      expect(find.text('Le titre est requis'), findsNothing);
      expect(find.text('La description est requise'), findsNothing);
    });
  });
}
