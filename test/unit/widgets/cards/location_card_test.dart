import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/cards/location_card.dart';

void main() {
  group('LocationCard', () {
    testWidgets('displays coordinates with 5 decimal places', (t) async {
      await t.pumpWidget(
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

    testWidgets('displays timestamp when provided', (t) async {
      final timestamp = DateTime(2026, 5, 10, 14, 30, 45);

      await t.pumpWidget(
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

    testWidgets('displays placeholder when timestamp is null', (t) async {
      await t.pumpWidget(
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

    testWidgets('uses monospace font for coordinates', (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationCard(
              latitude: 39.49127,
              longitude: -105.09501,
            ),
          ),
        ),
      );

      final textWidget = t.widget(find.text('39.49127, -105.09501'));
      expect((textWidget as Text).style?.fontFamily, equals('monospace'));
    });

    testWidgets('timestamp has smaller font than coordinates', (t) async {
      final timestamp = DateTime.now();

      await t.pumpWidget(
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

      final coordText = t.widget(find.text('39.49127, -105.09501')) as Text;
      final timestampText = t.widget(find.textContaining('Updated:')) as Text;

      expect(coordText.style?.fontSize, equals(16));
      expect(timestampText.style?.fontSize, equals(12));
    });
  });
}