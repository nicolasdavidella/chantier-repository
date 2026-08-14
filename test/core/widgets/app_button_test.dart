import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chantier_track/core/widgets/app_button.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Tap Me',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled (onPressed is null)', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(pressed, isFalse);
    });

    testWidgets('shows loading indicator when isLoading is true and ignores taps', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(pressed, isFalse);
    });
  });
}
