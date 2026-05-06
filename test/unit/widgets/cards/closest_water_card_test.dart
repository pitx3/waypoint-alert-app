import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint_alert_app/models/water_info.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/widgets/cards/closest_water_card.dart';

void main() {
  group('ClosestWaterCard', () {
    testWidgets('shows no water message when closestWater is null', (tester) async {
      final waterInfo = WaterInfo(
        closestWater: null,
        closestDistanceMeters: null,
        closestBearing: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClosestWaterCard(waterInfo: waterInfo),
          ),
        ),
      );

      expect(find.text('Closest Water'), findsOneWidget);
      expect(find.text('No water waypoints available'), findsOneWidget);
    });

    testWidgets('shows closest water ahead with forward arrow', (tester) async {
      final waypoint = Waypoint(
        id: 1,
        setId: 1,
        name: '01-033WT',
        latitude: 39.47043,
        longitude: -105.1353,
        type: 'water',
        alerts: [],
      );

      final waterInfo = WaterInfo(
        closestWater: waypoint,
        closestDistanceMeters: 1500,
        closestBearing: 180,
        isClosestBehind: false,
        nextWaterAhead: null,
        nextWaterDistanceMeters: null,
        nextWaterBearing: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClosestWaterCard(waterInfo: waterInfo),
          ),
        ),
      );

      expect(find.text('Closest Water'), findsOneWidget);
      expect(find.text('01-033WT'), findsOneWidget);
      expect(find.text('1.5km'), findsOneWidget);
      expect(find.text('180°'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.text('Next Ahead'), findsNothing);
    });

    testWidgets('shows closest water behind with back arrow and next ahead', (tester) async {
      final closestWaypoint = Waypoint(
        id: 1,
        setId: 1,
        name: '01-033WT',
        latitude: 39.47043,
        longitude: -105.1353,
        type: 'water',
        alerts: [],
      );

      final nextWaypoint = Waypoint(
        id: 2,
        setId: 1,
        name: '01-091WT',
        latitude: 39.41959,
        longitude: -105.12433,
        type: 'water',
        alerts: [],
      );

      final waterInfo = WaterInfo(
        closestWater: closestWaypoint,
        closestDistanceMeters: 800,
        closestBearing: 270,
        isClosestBehind: true,
        nextWaterAhead: nextWaypoint,
        nextWaterDistanceMeters: 2500,
        nextWaterBearing: 135,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClosestWaterCard(waterInfo: waterInfo),
          ),
        ),
      );

      // Closest water (behind)
      expect(find.text('01-033WT'), findsOneWidget);
      expect(find.text('800m behind'), findsOneWidget);
      expect(find.text('270°'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Next ahead section
      expect(find.text('Next Ahead'), findsOneWidget);
      expect(find.text('01-091WT'), findsOneWidget);
      expect(find.text('2.5km'), findsOneWidget);
      expect(find.text('135°'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

      // Should be two arrow_forward icons (one for next ahead, none for closest)
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('formats distance correctly', (tester) async {
      final waypoint = Waypoint(
        id: 1,
        setId: 1,
        name: 'TEST',
        latitude: 39.0,
        longitude: -105.0,
        type: 'water',
        alerts: [],
      );

      // Test meters (< 1000)
      final waterInfoMeters = WaterInfo(
        closestWater: waypoint,
        closestDistanceMeters: 450,
        closestBearing: 90,
        isClosestBehind: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClosestWaterCard(waterInfo: waterInfoMeters),
          ),
        ),
      );

      expect(find.text('450m'), findsOneWidget);

      // Test kilometers (>= 1000)
      final waterInfoKm = WaterInfo(
        closestWater: waypoint,
        closestDistanceMeters: 3200,
        closestBearing: 90,
        isClosestBehind: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClosestWaterCard(waterInfo: waterInfoKm),
          ),
        ),
      );

      expect(find.text('3.2km'), findsOneWidget);
    });

  });
}