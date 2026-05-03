// test/unit/services/waypoint_service_test.dart

import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/models/waypoint_set.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/services/waypoint_repository.dart';
import 'package:waypoint_alert_app/services/waypoint_service.dart';

// Mock classes
class MockWaypointRepository extends Mock implements WaypointRepository {}
class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late MockWaypointRepository mockRepository;
  late MockSettingsService mockSettingsService;
  late WaypointService waypointService;

  setUp(() {
    mockRepository = MockWaypointRepository();
    mockSettingsService = MockSettingsService();

    waypointService = WaypointService(
      repository: mockRepository,
      settingsService: mockSettingsService,
    );
  });

  group('getNextWaypoint', () {
    test('returns the closest waypoint to current location', () async {
      final currentLat = 39.0;
      final currentLon = -105.0;

      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'Far', latitude: 39.1, longitude: -105.1, type: 'trail', alerts: []),
        Waypoint(id: 2, setId: 1, name: 'Close', latitude: 39.01, longitude: -105.01, type: 'trail', alerts: []),
        Waypoint(id: 3, setId: 1, name: 'Medium', latitude: 39.05, longitude: -105.05, type: 'water', alerts: []),
      ];

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => waypoints);

      final result = await waypointService.getNextWaypoint(1, currentLat, currentLon);

      expect(result, isNotNull);
      expect(result!.name, equals('Close'));
    });

    test('returns null when no waypoints exist', () async {
      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => []);

      final result = await waypointService.getNextWaypoint(1, 39.0, -105.0);

      expect(result, isNull);
    });
  });

  group('getClosestWater', () {
    test('returns the nearest water waypoint', () async {
      final currentLat = 39.0;
      final currentLon = -105.0;

      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'Trail1', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []),
        Waypoint(id: 2, setId: 1, name: 'Water1', latitude: 39.01, longitude: -105.01, type: 'water', alerts: []),
        Waypoint(id: 3, setId: 1, name: 'Water2', latitude: 39.05, longitude: -105.05, type: 'water', alerts: []),
      ];

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => waypoints);

      final result = await waypointService.getClosestWater(1, currentLat, currentLon);

      expect(result, isNotNull);
      expect(result!.name, equals('Water1'));
      expect(result.type, equals('water'));
    });

    test('returns null if no water waypoints exist', () async {
      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'Trail1', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []),
        Waypoint(id: 2, setId: 1, name: 'Trail2', latitude: 39.1, longitude: -105.1, type: 'junction', alerts: []),
      ];

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => waypoints);

      final result = await waypointService.getClosestWater(1, 39.0, -105.0);

      expect(result, isNull);
    });

    test('respects maxDistance parameter', () async {
      final currentLat = 39.0;
      final currentLon = -105.0;

      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'CloseWater', latitude: 39.01, longitude: -105.01, type: 'water', alerts: []),
        Waypoint(id: 2, setId: 1, name: 'FarWater', latitude: 40.0, longitude: -106.0, type: 'water', alerts: []),
      ];

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => waypoints);

      // With 5km max, only CloseWater should be in range
      final result = await waypointService.getClosestWater(1, currentLat, currentLon, maxDistance: 5000);

      expect(result, isNotNull);
      expect(result!.name, equals('CloseWater'));
    });

    test('returns null if water is beyond maxDistance', () async {
      final currentLat = 39.0;
      final currentLon = -105.0;

      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'FarWater', latitude: 40.0, longitude: -106.0, type: 'water', alerts: []),
      ];

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => waypoints);

      final result = await waypointService.getClosestWater(1, currentLat, currentLon, maxDistance: 1000);

      expect(result, isNull);
    });
  });

  group('getUpcomingWaypoints', () {
    test('returns waypoints within maxDistance sorted by distance', () async {
      final currentLat = 39.0;
      final currentLon = -105.0;

      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'Far', latitude: 39.15, longitude: -105.15, type: 'trail', alerts: []),
        Waypoint(id: 2, setId: 1, name: 'Close', latitude: 39.01, longitude: -105.01, type: 'trail', alerts: []),
        Waypoint(id: 3, setId: 1, name: 'Medium', latitude: 39.05, longitude: -105.05, type: 'water', alerts: []),
        Waypoint(id: 4, setId: 1, name: 'Trail2', latitude: 39.02, longitude: -105.02, type: 'trail', alerts: []),
      ];

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => waypoints);

      final result = await waypointService.getUpcomingWaypoints(1, currentLat, currentLon, maxDistance: 10000);

      expect(result.length, equals(3)); // Far is beyond 10km
      expect(result[0].name, equals('Close')); // Closest first
      expect(result[1].name, equals('Trail2'));
      expect(result[2].name, equals('Medium'));
    });

    test('returns empty list when no waypoints within range', () async {
      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'VeryFar', latitude: 45.0, longitude: -115.0, type: 'trail', alerts: []),
      ];

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => waypoints);

      final result = await waypointService.getUpcomingWaypoints(1, 39.0, -105.0, maxDistance: 5000);

      expect(result, isEmpty);
    });
  });

  group('activateSet', () {
    test('deactivates all sets and activates the target set', () async {
      final allSets = [
        WaypointSet(id: 1, name: 'Set 1', created: DateTime.now(), isActive: true),
        WaypointSet(id: 2, name: 'Set 2', created: DateTime.now(), isActive: false),
      ];

      when(() => mockRepository.getAllSets()).thenAnswer((_) async => allSets);
      when(() => mockRepository.updateSet(any())).thenAnswer((_) async => {});
      when(() => mockSettingsService.setActiveSetId(2)).thenAnswer((_) async => {});

      await waypointService.activateSet(2);

      // Verify set 1 was deactivated
      verify(() => mockRepository.updateSet(argThat(
        isA<WaypointSet>().having((s) => s.id, 'id', 1).having((s) => s.isActive, 'isActive', false),
      ))).called(1);

      // Verify set 2 was activated
      verify(() => mockRepository.updateSet(argThat(
        isA<WaypointSet>().having((s) => s.id, 'id', 2).having((s) => s.isActive, 'isActive', true),
      ))).called(1);

      verify(() => mockSettingsService.setActiveSetId(2)).called(1);
    });

    test('updates settings with active set ID', () async {
      when(() => mockRepository.getAllSets()).thenAnswer((_) async => []);
      when(() => mockSettingsService.setActiveSetId(5)).thenAnswer((_) async => {});

      await waypointService.activateSet(5);

      verify(() => mockSettingsService.setActiveSetId(5)).called(1);
    });
  });

  group('deleteSet', () {
    test('deletes all waypoints in the set, then the set itself', () async {
      final waypoints = [
        Waypoint(id: 10, setId: 5, name: 'WP1', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []),
        Waypoint(id: 11, setId: 5, name: 'WP2', latitude: 39.1, longitude: -105.1, type: 'water', alerts: []),
      ];

      when(() => mockRepository.getWaypointsForSet(5)).thenAnswer((_) async => waypoints);
      when(() => mockRepository.deleteWaypoint(10)).thenAnswer((_) async => {});
      when(() => mockRepository.deleteWaypoint(11)).thenAnswer((_) async => {});
      when(() => mockRepository.deleteSet(5)).thenAnswer((_) async => {});
      when(() => mockSettingsService.getActiveSetId()).thenAnswer((_) async => null);

      await waypointService.deleteSet(5);

      verify(() => mockRepository.deleteWaypoint(10)).called(1);
      verify(() => mockRepository.deleteWaypoint(11)).called(1);
      verify(() => mockRepository.deleteSet(5)).called(1);
    });

    test('clears active set ID if deleted set was active', () async {
      when(() => mockRepository.getWaypointsForSet(5)).thenAnswer((_) async => []);
      when(() => mockRepository.deleteSet(5)).thenAnswer((_) async => {});
      when(() => mockSettingsService.getActiveSetId()).thenAnswer((_) async => 5);
      when(() => mockSettingsService.setActiveSetId(null)).thenAnswer((_) async => {});

      await waypointService.deleteSet(5);

      verify(() => mockSettingsService.setActiveSetId(null)).called(1);
    });

    test('does not clear active ID if different set was deleted', () async {
      when(() => mockRepository.getWaypointsForSet(5)).thenAnswer((_) async => []);
      when(() => mockRepository.deleteSet(5)).thenAnswer((_) async => {});
      when(() => mockSettingsService.getActiveSetId()).thenAnswer((_) async => 3);

      await waypointService.deleteSet(5);

      verifyNever(() => mockSettingsService.setActiveSetId(any()));
    });
  });

  group('Distance Calculation', () {
    test('correctly calculates distance using Haversine formula', () async {
      // Denver to Boulder is approximately 40km
      // Denver: 39.7392, -104.9903
      // Boulder: 40.0150, -105.2705

      final waypoint = Waypoint(
        id: 1,
        setId: 1,
        name: 'Boulder',
        latitude: 40.0150,
        longitude: -105.2705,
        type: 'trail',
        alerts: [],
      );

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => [waypoint]);

      // From Denver, with 50km max (should include Boulder at ~40km)
      final result = await waypointService.getUpcomingWaypoints(1, 39.7392, -104.9903, maxDistance: 50000);

      expect(result.length, equals(1));
      expect(result[0].name, equals('Boulder'));
    });
  });
}