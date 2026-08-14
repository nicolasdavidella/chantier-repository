import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chantier_track/features/client/create_project/presentation/steps/step_budget_dates.dart';

void main() {
  group('StepBudgetDates Form Validation', () {
    testWidgets('shows validation errors when budget is empty or invalid', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StepBudgetDates(formKey: formKey),
            ),
          ),
        ),
      );

      // Trigger validation with empty budget
      formKey.currentState?.validate();
      await tester.pumpAndSettle();

      expect(find.text('Le budget est requis'), findsOneWidget);

      // Trigger validation with invalid number
      await tester.enterText(find.byType(TextFormField).first, 'abc');
      formKey.currentState?.validate();
      await tester.pumpAndSettle();

      expect(find.text('Entrez un nombre valide'), findsOneWidget);
      
      // Trigger validation with 0 or negative
      await tester.enterText(find.byType(TextFormField).first, '-100');
      formKey.currentState?.validate();
      await tester.pumpAndSettle();

      expect(find.text('Le budget doit être supérieur à 0'), findsOneWidget);
    });

    testWidgets('no validation errors when budget is valid', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StepBudgetDates(formKey: formKey),
            ),
          ),
        ),
      );

      // Enter valid budget
      await tester.enterText(find.byType(TextFormField).first, '15000000');
      await tester.pumpAndSettle();

      // Trigger validation
      final isValid = formKey.currentState?.validate() ?? false;
      await tester.pumpAndSettle();

      expect(isValid, isTrue);
      expect(find.text('Le budget est requis'), findsNothing);
      expect(find.text('Entrez un nombre valide'), findsNothing);
      expect(find.text('Le budget doit être supérieur à 0'), findsNothing);
    });
  });
}
