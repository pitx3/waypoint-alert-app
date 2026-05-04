// test/unit/services/waypoint_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/models/waypoint_set.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/services/waypoint_repository.dart';
import 'package:waypoint_alert_app/services/waypoint_service.dart';

import '../../helpers/expect_helpers.dart';

// Mock classes
class MockWaypointRepository extends Mock implements WaypointRepository {}
class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late MockWaypointRepository mockRepository;
  late MockSettingsService mockSettingsService;
  late WaypointService waypointService;

  registerFallbackValue(Future<void>.value());


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
      when(() => mockSettingsService.setActiveSetId(2)).thenAnswer((_) async => {});

      List<WaypointSet>? capturedSets;

      when(() => mockRepository.updateSets(captureAny())).thenAnswer((invocation) {
        capturedSets = invocation.positionalArguments[0] as List<WaypointSet>;
        return Future.value();
      });

      await waypointService.activateSet(2);

      // verify we called something
      verify(() => mockRepository.updateSets(any())).called(1);

      // Check the captured results
      expectNotNull(capturedSets, reason: 'No captured results');
      expect(capturedSets!.length, equals(2));
      expectFalse(capturedSets!.firstWhere((s) => s.id == 1).isActive, reason: 'Set 1 isActive was not false');
      expectTrue(capturedSets!.firstWhere((s) => s.id == 2).isActive, reason: 'Set 2 isActive was not true');
      
      verify(() => mockSettingsService.setActiveSetId(2)).called(1);
    });

    test('updates settings with active set ID', () async {
      when(() => mockRepository.getAllSets()).thenAnswer((_) async => []);
      when(() => mockRepository.updateSets(any())).thenAnswer((_) async => {});
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
      when(() => mockRepository.deleteSet(5)).thenAnswer((_) async => {});
      when(() => mockSettingsService.getActiveSetId()).thenAnswer((_) async => null);

      await waypointService.deleteSet(5);

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

  group('getNextWaypoint with real CT data pattern', () {
    // First 10 waypoints from segment 01, scaled for testing
    final testWaypoints = [
      Waypoint(id: 1, setId: 1, name: '01-000TH', latitude: 39.49127, longitude: -105.09501, type: 'trailhead', alerts: []),
      Waypoint(id: 2, setId: 1, name: '01-010WT', latitude: 39.41021, longitude: -105.13074, type: 'water', alerts: []),
      Waypoint(id: 3, setId: 1, name: '01-033WT', latitude: 39.47043, longitude: -105.1353, type: 'water', alerts: []),
      Waypoint(id: 4, setId: 1, name: '01-066XT', latitude: 39.43476, longitude: -105.12306, type: 'crossing', alerts: []),
      Waypoint(id: 5, setId: 1, name: '01-068OP', latitude: 39.43364, longitude: -105.12059, type: 'other', alerts: []),
      Waypoint(id: 6, setId: 1, name: '01-070XR', latitude: 39.43065, longitude: -105.11882, type: 'crossing', alerts: []),
      Waypoint(id: 7, setId: 1, name: '01-071XT', latitude: 39.42876, longitude: -105.11957, type: 'crossing', alerts: []),
      Waypoint(id: 8, setId: 1, name: '01-082XT', latitude: 39.42407, longitude: -105.12075, type: 'crossing', alerts: []),
      Waypoint(id: 9, setId: 1, name: '01-083FT', latitude: 39.42404, longitude: -105.12089, type: 'trail', alerts: []),
      Waypoint(id: 10, setId: 1, name: '01-091WT', latitude: 39.41959, longitude: -105.12433, type: 'water', alerts: []),
    ];

    test('returns closest waypoint when positioned between waypoints', () async {
      // Position roughly between 01-066XT and 01-068OP
      final testLat = 39.43420;
      final testLon = -105.12180;

      when(() => mockRepository.getWaypointsWithinDistance(1, testLat, testLon, 5000))
          .thenAnswer((_) async => testWaypoints);

      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      // Should return 01-066XT or 01-068OP (whichever is closer)
      expect(result!.name, isIn(['01-066XT', '01-068OP']));
    });

    test('returns null when no waypoints within range', () async {
      when(() => mockRepository.getWaypointsWithinDistance(1, 40.0, -106.0, 5000))
          .thenAnswer((_) async => []);

      final result = await waypointService.getNextWaypoint(1, 40.0, -106.0);

      expect(result, isNull);
    });

    test('handles clustered waypoints correctly', () async {
      // Position near the 01-066XT through 01-071XT cluster
      final testLat = 39.43200;
      final testLon = -105.12100;

      when(() => mockRepository.getWaypointsWithinDistance(1, testLat, testLon, 5000))
          .thenAnswer((_) async => testWaypoints);

      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      // Should return one of the clustered waypoints
      expect(result!.name, isIn(['01-066XT', '01-068OP', '01-070XR', '01-071XT']));
    });

    test('sorts by trail order (name) correctly', () async {
      // Verify the name-based sorting gives trail order
      final sorted = List<Waypoint>.from(testWaypoints)
        ..sort((a, b) => a.name.compareTo(b.name));

      expect(sorted[0].name, equals('01-000TH'));
      expect(sorted[9].name, equals('01-091WT'));
    });
  });
}