import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:waypoint_alert_app/widgets/cards/location_card.dart';

void main() {
  group('LocationCard', () {
    testWidgets('displays coordinates with 5 decimal places', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationCard(
              latitude: 39.49127,
              longitude: -105.09501,
            ),
          ),
        ),
      );

      expect(find.text('39.49127, -105.09501'), findsOneWidget);
    });

    testWidgets('displays timestamp when provided', (tester) async {
      final timestamp = DateTime(2026, 5, 10, 14, 30, 45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationCard(
              latitude: 39.49127,
              longitude: -105.09501,
              lastUpdated: timestamp,
            ),
          ),
        ),
      );

      expect(find.text('Updated: 14:30:45'), findsOneWidget);
    });

    testWidgets('displays placeholder when timestamp is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationCard(
              latitude: 39.49127,
              longitude: -105.09501,
            ),
          ),
        ),
      );

      expect(find.text('Updated: --:--:--'), findsOneWidget);
    });

    testWidgets('uses monospace font for coordinates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationCard(
              latitude: 39.49127,
              longitude: -105.09501,
            ),
          ),
        ),
      );

      final textWidget = tester.widget(find.text('39.49127, -105.09501'));
      expect((textWidget as Text).style?.fontFamily, equals('monospace'));
    });

    testWidgets('timestamp has smaller font than coordinates', (tester) async {
      final timestamp = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationCard(
              latitude: 39.49127,
              longitude: -105.09501,
              lastUpdated: timestamp,
            ),
          ),
        ),
      );

      final coordText = tester.widget(find.text('39.49127, -105.09501')) as Text;
      final timestampText = tester.widget(find.textContaining('Updated:')) as Text;

      expect(coordText.style?.fontSize, equals(16));
      expect(timestampText.style?.fontSize, equals(12));
    });
  });
}