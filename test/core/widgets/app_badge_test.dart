import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chantier_track/core/widgets/app_badge.dart';

void main() {
  group('AppBadge', () {
    testWidgets('renders text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBadge(
              label: 'Test Badge',
            ),
          ),
        ),
      );

      expect(find.text('Test Badge'), findsOneWidget);
    });

    testWidgets('renders correct icon for inProgress status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBadge(
              label: 'En cours',
              status: AppBadgeStatus.inProgress,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });
    
    testWidgets('renders correct icon for delayed status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBadge(
              label: 'En retard',
              status: AppBadgeStatus.delayed,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('does not render icon when hasIcon is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBadge(
              label: 'No Icon',
              status: AppBadgeStatus.completed,
              hasIcon: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(find.text('No Icon'), findsOneWidget);
    });
  });
}
