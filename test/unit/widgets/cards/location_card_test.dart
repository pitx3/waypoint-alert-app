import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/widgets/cards/location_card.dart';

import '../../../helpers/expect.dart';
import '../../../helpers/widget_helpers.dart';


// ----------------------------------
// Mocks and Fakes
// ----------------------------------
LocationCard testCard({
  double? latitude = 39.49120,
  double? longitude = -105.09501,
  DateTime? lastUpdated,
  bool isDataStale = false,

}) {
  LocationCard card = LocationCard(
    latitude: latitude,
    longitude: longitude,
    lastUpdated: lastUpdated ?? DateTime.now(),
    isDataStale: isDataStale,  
  );
  return card;
}


// ----------------------------------
// Tests
// ----------------------------------

void main() {
  group('LocationCard', () {
    testWidgets('displays coordinates with 5 decimal places', (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationCard(
              latitude: 39.49120,
              longitude: -105.09501,
            ),
          ),
        ),
      );

      expect(find.text('39.49120, -105.09501'), findsOneWidget);
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
  
    testWidgets('oragne background when data is stale', (t) async {
      Widget w = testCard(isDataStale: true, lastUpdated: DateTime.now().subtract(const Duration(minutes:20)));
      await t.pumpWidget(w.withMaterial());
      t.oneExists<Card>().hasColor(Colors.orange[400]);
    });

    testWidgets('normal background when data is fresh', (t) async {
      Widget w = testCard();
      await t.pumpWidget(w.withMaterial());
      t.oneExists<Card>().hasColor(null);
    });

    testWidgets('black text when data is stale', (t) async {
      double latitude = 40.0;
      double longitude = -105.0;
      String testString = '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
      Widget w = testCard(latitude: latitude, longitude: longitude, isDataStale: true);
      await t.pumpWidget(w.withMaterial());
      t.exists<Text>(testString).hasColor(Colors.black);
    });
    
  });
}