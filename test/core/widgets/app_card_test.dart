import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chantier_track/core/widgets/app_card.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders child correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () {
                pressed = true;
              },
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppCard));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('renders without GestureDetector when onTap is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: const Text('No Tap'),
            ),
          ),
        ),
      );

      final gestureDetector = find.descendant(
        of: find.byType(AppCard),
        matching: find.byType(GestureDetector),
      );

      // It shouldn't have a GestureDetector wrapping the content if onTap is null
      expect(gestureDetector, findsNothing);
    });
  });
}
