// test/unit/services/waypoint_service_test.dart

import 'dart:math' as math;

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

  // First 32 waypoints from CT segments 01-02 (27+ miles)
  final segment01_02Waypoints = [
    Waypoint(id: 1, setId: 1, name: '01-000TH', latitude: 39.49127, longitude: -105.09501, type: 'trailhead', alerts: []),
    Waypoint(id: 2, setId: 1, name: '01-100WT', latitude: 39.41021, longitude: -105.13074, type: 'water', alerts: []),
    Waypoint(id: 3, setId: 1, name: '01-033WT', latitude: 39.47043, longitude: -105.1353, type: 'water', alerts: []),
    Waypoint(id: 4, setId: 1, name: '01-066XT', latitude: 39.43476, longitude: -105.12306, type: 'crossing', alerts: []),
    Waypoint(id: 5, setId: 1, name: '01-068OP', latitude: 39.43364, longitude: -105.12059, type: 'other', alerts: []),
    Waypoint(id: 6, setId: 1, name: '01-070XR', latitude: 39.43065, longitude: -105.11882, type: 'crossing', alerts: []),
    Waypoint(id: 7, setId: 1, name: '01-071XT', latitude: 39.42876, longitude: -105.11957, type: 'crossing', alerts: []),
    Waypoint(id: 8, setId: 1, name: '01-082XT', latitude: 39.42407, longitude: -105.12075, type: 'crossing', alerts: []),
    Waypoint(id: 9, setId: 1, name: '01-083FT', latitude: 39.42404, longitude: -105.12089, type: 'trail', alerts: []),
    Waypoint(id: 10, setId: 1, name: '01-091WT', latitude: 39.41959, longitude: -105.12433, type: 'water', alerts: []),
    Waypoint(id: 11, setId: 1, name: '01-099XT', latitude: 39.41334, longitude: -105.12566, type: 'crossing', alerts: []),
    Waypoint(id: 12, setId: 1, name: '01-105XT', latitude: 39.40783, longitude: -105.12981, type: 'crossing', alerts: []),
    Waypoint(id: 13, setId: 1, name: '01-112RT', latitude: 39.4112, longitude: -105.13418, type: 'trail', alerts: []),
    Waypoint(id: 14, setId: 1, name: '01-131RT', latitude: 39.40581, longitude: -105.15287, type: 'trail', alerts: []),
    Waypoint(id: 15, setId: 1, name: '01-999XT', latitude: 39.40051, longitude: -105.16767, type: 'crossing', alerts: []),
    Waypoint(id: 16, setId: 1, name: '02-000TH', latitude: 39.40018, longitude: -105.16831, type: 'trailhead', alerts: []),
    Waypoint(id: 17, setId: 1, name: '02-001XR', latitude: 39.40021, longitude: -105.16831, type: 'crossing', alerts: []),
    Waypoint(id: 18, setId: 1, name: '02-020XL', latitude: 39.40021, longitude: -105.18549, type: 'trail', alerts: []),
    Waypoint(id: 19, setId: 1, name: '02-041XT', latitude: 39.40553, longitude: -105.21392, type: 'crossing', alerts: []),
    Waypoint(id: 20, setId: 1, name: '02-058XT', latitude: 39.40051, longitude: -105.23238, type: 'crossing', alerts: []),
    Waypoint(id: 21, setId: 1, name: '02-062XL', latitude: 39.39921, longitude: -105.23433, type: 'trail', alerts: []),
    Waypoint(id: 22, setId: 1, name: '02-072XT', latitude: 39.38683, longitude: -105.24017, type: 'crossing', alerts: []),
    Waypoint(id: 23, setId: 1, name: '02-080XT', latitude: 39.37951, longitude: -105.2393, type: 'crossing', alerts: []),
    Waypoint(id: 24, setId: 1, name: '02-099OP', latitude: 39.35984, longitude: -105.24556, type: 'other', alerts: []),
    Waypoint(id: 25, setId: 1, name: '02-099WT', latitude: 39.36159, longitude: -105.24496, type: 'water', alerts: []),
    Waypoint(id: 26, setId: 1, name: '02-099XL', latitude: 39.35984, longitude: -105.24556, type: 'trail', alerts: []),
    Waypoint(id: 27, setId: 1, name: '02-100XX', latitude: 39.35867, longitude: -105.2457, type: 'crossing', alerts: []),
    Waypoint(id: 28, setId: 1, name: '02-100XX', latitude: 39.35627, longitude: -105.24644, type: 'crossing', alerts: []),
    Waypoint(id: 29, setId: 1, name: '02-102XT', latitude: 39.35627, longitude: -105.24644, type: 'crossing', alerts: []),
    Waypoint(id: 30, setId: 1, name: '02-105XL', latitude: 39.35678, longitude: -105.25073, type: 'trail', alerts: []),
    Waypoint(id: 31, setId: 1, name: '02-106MS', latitude: 39.3561, longitude: -105.25136, type: 'trail', alerts: []),
    Waypoint(id: 32, setId: 1, name: '02-115TH', latitude: 39.34585, longitude: -105.257, type: 'trailhead', alerts: []),
  ];


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

  });

  group('getUpcomingWaypoints', () {
    setUp(() {
      when(() => mockRepository.getWaypointsForSet(1))
        .thenAnswer((_) async => segment01_02Waypoints);
    });

    test('returns waypoints ahead only, not behind', () async {
      // position roughly at mile 5
      final testLat = 39.45045;
      final testLon = -105.12248;

      final result = await waypointService.getUpcomingWaypoints(1, testLat, testLon);

      // verify we get waypoints
      expect(result, isNotEmpty);

      // verify we DON'T get waypoints behind us
      final resultNames = result.map((wp) => wp.name).toList();
      expect(resultNames, isNot(contains('01-000TH')));
      expect(resultNames, isNot(contains('01-033WT')));

      // verify the first result is the next waypoint ahead
      expect(result.first.name, equals('01-066XT'));
    });

    test('respects maxDistance parameter', () async {
      // position near start of trail
      final testLat = 39.49;
      final testLon = -105.096;
      // small distance
      final testMaxDist = 2000;

      final result = await waypointService.getUpcomingWaypoints(
        1, testLat, testLon, maxDistance: testMaxDist
      );

      // verify all results are within testMaxDist
      for (final wp in result) {
        final distance = _calculateDistance(
          testLat, testLon, wp.latitude, wp.longitude,
        );
        expect(distance, lessThanOrEqualTo(testMaxDist));
      }
    });

    test('returns empty list when past last waypoint', () async {
      // position past the end of the last waypoint (02-115TH)
      final testLat = 39.34;
      final testLon = -105.26;

      final result = await waypointService.getUpcomingWaypoints(1, testLat, testLon);

      expect(result, isEmpty);
    });

    test('returns empty list when no waypoints for set', () async {
      when(() => mockRepository.getWaypointsForSet(99)).thenAnswer((_) async => []);

      final result = await waypointService.getUpcomingWaypoints(99, 39.45, -105.13,);
      
      expect(result, isEmpty);
    });

    test('includes waypoints up to maxDistance boundary', () async {
      // position just past start of trail
      final testLat = 39.48845;
      final testLon = -105.09739;
      final testMaxDist = 10000;  // contains 12 waypoints

      final result = await waypointService.getUpcomingWaypoints(1, testLat, testLon, maxDistance: testMaxDist);

      expect(result, isNotEmpty);

      expect(result.first.name, equals('01-033WT'));
      expect(result.length, equals(12));

      // verify everything is within max distance
      for (final wp in result) {
        final distance = _calculateDistance(testLat, testLon, wp.latitude, wp.longitude);
        expect(distance, lessThanOrEqualTo(testMaxDist));
      }

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
      when(() => mockSettingsService.getActiveSetId()).thenAnswer((_) => null);

      await waypointService.deleteSet(5);

      verify(() => mockRepository.deleteSet(5)).called(1);
    });

    test('clears active set ID if deleted set was active', () async {
      when(() => mockRepository.getWaypointsForSet(5)).thenAnswer((_) async => []);
      when(() => mockRepository.deleteSet(5)).thenAnswer((_) async => {});
      when(() => mockSettingsService.getActiveSetId()).thenAnswer((_) => 5);
      when(() => mockSettingsService.setActiveSetId(null)).thenAnswer((_) async => {});

      await waypointService.deleteSet(5);

      verify(() => mockSettingsService.setActiveSetId(null)).called(1);
    });

    test('does not clear active ID if different set was deleted', () async {
      when(() => mockRepository.getWaypointsForSet(5)).thenAnswer((_) async => []);
      when(() => mockRepository.deleteSet(5)).thenAnswer((_) async => {});
      when(() => mockSettingsService.getActiveSetId()).thenAnswer((_) => 3);

      await waypointService.deleteSet(5);

      verifyNever(() => mockSettingsService.setActiveSetId(any()));
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

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => testWaypoints);
      when(() => mockSettingsService.getMaxSearchDistanceM()).thenReturn(5000);


      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      // Should return 01-066XT or 01-068OP (whichever is closer)
      expect(result!.name, isIn(['01-066XT', '01-068OP']));
    });
    test('handles clustered waypoints correctly', () async {
      // Position near the 01-066XT through 01-071XT cluster
      final testLat = 39.43200;
      final testLon = -105.12100;

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => testWaypoints);
      when(() => mockSettingsService.getMaxSearchDistanceM()).thenReturn(5000);

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

  group('getNextWaypoint - comprehensive positioning tests', () {
        test('returns first waypoint when user is before all waypoints', () async {
      // Position north/west of 01-000TH (before the trail starts)
      final testLat = 39.50000;
      final testLon = -105.10000;

      when(() => mockSettingsService.getMaxSearchDistanceM()).thenReturn(5000);
      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => segment01_02Waypoints);

      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      expect(result!.name, equals('01-000TH')); // First in trail order
    });

    test('returns closest waypoint when user is between two waypoints', () async {
      // Position roughly halfway between 01-010WT and 01-033WT
      final testLat = 39.48565;
      final testLon = -105.11750;

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => segment01_02Waypoints);

      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      // Should be whichever is closer - 01-010WT or 01-033WT
      expect(result!.name, equals('01-033WT'));
    });

    test('handles clustered waypoints correctly', () async {
      // Use the 01-066XT through 01-071XT cluster
      final clusterWaypoints = segment01_02Waypoints.where((wp) => 
        wp.name.startsWith('01-06') || wp.name.startsWith('01-07')
      ).toList();

      // Position in the middle of the cluster
      final testLat = 39.43298;
      final testLon = -105.12079;

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => clusterWaypoints);

      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      // Should return the closest one in the cluster
      expect(result!.name, equals('01-070XR'));
    });

    test('sorts by trail order (name) correctly across segments', () async {
      // Test segment boundary: 01-999 → 02-000
      final segmentBoundaryWaypoints = [
        Waypoint(id: 1, setId: 1, name: '01-999XT', latitude: 39.50000, longitude: -105.10000, type: 'crossing', alerts: []),
        Waypoint(id: 2, setId: 1, name: '02-000TH', latitude: 39.50100, longitude: -105.10100, type: 'trailhead', alerts: []),
        Waypoint(id: 3, setId: 1, name: '02-010WT', latitude: 39.50200, longitude: -105.10200, type: 'water', alerts: []),
      ];

      // Verify the sort order
      final sorted = List<Waypoint>.from(segmentBoundaryWaypoints)
        ..sort((a, b) => a.name.compareTo(b.name));

      expect(sorted[0].name, equals('01-999XT'));
      expect(sorted[1].name, equals('02-000TH'));
      expect(sorted[2].name, equals('02-010WT'));
    });

    test('user movement simulation - next waypoint updates correctly', () async {
      

      when(() => mockSettingsService.getMaxSearchDistanceM()).thenReturn(5000);
      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => segment01_02Waypoints);

      // Position 1: Near 01-000TH
      final result1 = await waypointService.getNextWaypoint(1, 39.49127, -105.09501);
      expect(result1!.name, equals('01-000TH'));

     
      // Position 2: Near 01-033WT
      final result2 = await waypointService.getNextWaypoint(1, 39.4749, -105.12963);
      expect(result2!.name, equals('01-033WT'));

      // Position 3: Near 01-066XT
      final result3 = await waypointService.getNextWaypoint(1,  39.43924, -105.12577);
      expect(result3!.name, equals('01-066XT'));
    });
  });

  group('getNextWaypoint - further comprehensive positioning tests', () {
    
    test('returns first waypoint when user is before all waypoints', () async {
      // Position north of 01-000TH (before trail starts)
      final testLat = 39.50000;
      final testLon = -105.10000;

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => segment01_02Waypoints);

      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      expect(result!.name, equals('01-000TH'));
    });

    test('returns waypoint when user is exactly at that waypoint', () async {
      // Position exactly at 01-066XT
      final testLat = 39.43476;
      final testLon = -105.12306;

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => segment01_02Waypoints);

      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      expect(result!.name, equals('01-066XT'));
    });

    test('returns closest waypoint when user is between two waypoints', () async {
      // Position roughly halfway between 01-000TH and 01-033WT
      final testLat = 39.48565;
      final testLon = -105.11750;

      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => segment01_02Waypoints);

      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      expect(result!.name, equals('01-033WT'));
    });

    test('handles clustered waypoints correctly', () async {
      // Test the 01-066XT through 01-071XT cluster (4 waypoints within ~500m)
      // Location between 01-068OP and 01-070XR
      final testLat = 39.432983;
      final testLon = -105.120729;

      when(() => mockSettingsService.getMaxSearchDistanceM()).thenReturn(5000);
      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => segment01_02Waypoints);

      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      // Should return 01-070XR
      expect(result!.name, equals('01-070XR'));
    });

    test('sorts by trail order correctly across segment boundary', () async {
      // Verify 01-999XT comes before 02-000TH in trail order
      final boundaryWaypoints = segment01_02Waypoints
          .where((wp) => wp.name.startsWith('01-99') || wp.name.startsWith('02-00'))
          .toList();

      final sorted = List<Waypoint>.from(boundaryWaypoints)
        ..sort((a, b) => a.name.compareTo(b.name));

      expect(sorted[0].name, equals('01-999XT'));
      expect(sorted[1].name, equals('02-000TH'));
      expect(sorted[2].name, equals('02-001XR'));
    });

    test('user movement simulation - progresses through waypoints correctly', () async {
      when(() => mockSettingsService.getMaxSearchDistanceM()).thenReturn(5000);
      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => segment01_02Waypoints);

      // Position 1: At Waterton Canyon Trailhead
      final result1 = await waypointService.getNextWaypoint(1, 39.49127, -105.09501);
      expect(result1!.name, equals('01-000TH'));

      // Position 2: Near Small water source (01-010WT)
      // final result2 = await waypointService.getNextWaypoint(1, 39.41021, -105.13074);
      // expect(result2!.name, equals('01-010WT'));

      // Position 3: Near Dam on Platte River (01-033WT)
      final result3 = await waypointService.getNextWaypoint(1, 39.47043, -105.1353);
      expect(result3!.name, equals('01-033WT'));

      // Position 4: At segment 1/2 boundary
      final result4 = await waypointService.getNextWaypoint(1, 39.40051, -105.16767);
      expect(result4!.name, equals('01-999XT'));

      // Position 5: Just into segment 2
      final result5 = await waypointService.getNextWaypoint(1, 39.40018, -105.16831);
      expect(result5!.name, equals('02-000TH'));
    });

    test('handles duplicate waypoint names correctly', () async {
      // 02-099OP, 02-099WT, 02-099XL all have same mile marker
      // 02-100XX appears twice at slightly different locations
      final testLat = 39.36000;
      final testLon = -105.24500;

      when(() => mockSettingsService.getMaxSearchDistanceM()).thenReturn(5000);
      when(() => mockRepository.getWaypointsForSet(1)).thenAnswer((_) async => segment01_02Waypoints);

      final result = await waypointService.getNextWaypoint(1, testLat, testLon);

      expect(result, isNotNull);
      // Should return one of the 02-099x or 02-100xx waypoints
      expect(result!.name, contains('02-099'));
    });
  });

  group('getWaterInfo', () {
    setUp(() {
      when(() => mockRepository.getWaypointsForSet(1))
        .thenAnswer((_) async => segment01_02Waypoints);
    });

    test('returns closest water ahead when user is before it', () async {
      // position before the first water waypoint (01-033WT)
      final testLat = 39.4749;
      final testLon = -105.12963;

      final result = await waypointService.getWaterInfo(1, testLat, testLon);

      expect(result.closestWater, isNotNull);
      expect(result.closestWater!.name, equals('01-033WT'));
      expect(result.isClosestBehind, isFalse);
      expect(result.nextWaterAhead, isNull);
      expect(result.closestBearing, isNotNull);
      expect(result.closestBearing, greaterThanOrEqualTo(0));
      expect(result.closestBearing, lessThan(360));
    });

    test('returns closest water behind and next water ahead', () async {
      // position past 01-033WT and before 01-091WT and closer to 01-033WT
      final testLat = 39.45054;
      final testLon = -105.12248;

      final result = await waypointService.getWaterInfo(1, testLat, testLon);

      // closest water should be behind at 01-033WT
      expect(result.closestWater, isNotNull);
      expect(result.isClosestBehind, isTrue);
      expect(result.closestWater!.name, equals('01-033WT'));
      // next water ahead should be 01-091WT
      expect(result.nextWaterAhead, isNotNull);
      expect(result.nextWaterBearing, isNotNull);
      expect(result.nextWaterAhead!.name, equals('01-091WT'));
      expect(result.nextWaterBearing, greaterThanOrEqualTo(0));
      expect(result.nextWaterBearing, lessThan(360));
    });

    test('returns null when no water waypoints available', () async {
      when(() => mockRepository.getWaypointsForSet(99))
        .thenAnswer((_) async => []);

      final result = await waypointService.getWaterInfo(99, 39.45, -105.13);

      expect(result.closestWater, isNull);
      expect(result.closestDitanceMeters, isNull);
      expect(result.closestBearing, isNull);
      expect(result.isClosestBehind, isFalse);
      expect(result.nextWaterAhead, isNull);
      expect(result.nextWaterDistanceMeters, isNull);
      expect(result.nextWaterBearing, isNull);
    });

    test('returns only closest water when it is the last water waypoint', () async {
      // position past all water waypoints
      final testLat = 39.34197;
      final testLon = -105.26961;

      final result = await waypointService.getWaterInfo(1, testLat, testLon);

      expect(result.closestWater, isNotNull);
      expect(result.isClosestBehind, isTrue);
      expect(result.nextWaterAhead, isNull);
    });

    test('bearing is 90 degrees (due east) when waypoint is directly east', () async {
      // tests the "x=0" edge case indirectly
      final testWaypoints = [
        Waypoint(id: 1, setId: 90, name: 'TEST-WATER', latitude: 39.45, longitude: -105.12, type: 'water', alerts: []),
      ];

      when(() => mockRepository.getWaypointsForSet(90))
        .thenAnswer((_) async => testWaypoints);

      // user is directly west of the waypoint
      final result = await waypointService.getWaterInfo(90, 39.45, -105.13);

      expect(result.closestWater, isNotNull);
      expect(result.closestBearing, closeTo(90.0, 0.01));
    });

    test('bearing is 270 degrees (due west) when waypoint is directly west', () async {
      // tests the "x=0" edge case indirectly
      final testWaypoints = [
        Waypoint(id: 1, setId: 90, name: 'TEST-WATER', latitude: 39.45, longitude: -105.12, type: 'water', alerts: []),
      ];

      when(() => mockRepository.getWaypointsForSet(90))
        .thenAnswer((_) async => testWaypoints);

      // user is directly west of the waypoint
      final result = await waypointService.getWaterInfo(90, 39.45, -105.11);

      expect(result.closestWater, isNotNull);
      expect(result.closestBearing, closeTo(270.0, 0.01));
    });

  });
}

/// Calculate distance between two coordinates using Haversine formula
/// Returns distance in meters
/// DUPLICATE of the function in waypoint_service.dart since we can't use that one directly
double _calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadius = 6371000; // meters

  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
      math.cos(_toRadians(lat2)) *
      math.sin(dLon / 2) *
      math.sin(dLon / 2);

  final c = 2 * math.asin(math.sqrt(a));
  return earthRadius * c;
}

double _toRadians(double degrees) => degrees * (3.141592653589793 / 180.0);
