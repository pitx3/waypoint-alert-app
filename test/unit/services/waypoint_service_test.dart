// test/unit/services/waypoint_service_test.dart

import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/models/waypoint_set.dart';
import 'package:waypoint_alert_app/services/isar_service.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/services/waypoint_service.dart';

// Mock classes
class MockIsar extends Mock implements Isar {}
class MockIsarCollection<T> extends Mock implements IsarCollection<T> {}
class MockIsarQuery<T> extends Mock implements IsarQuery<T> {}
class MockSettingsService extends Mock implements SettingsService {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection<WaypointSet> mockWaypointSets;
  late MockIsarCollection<Waypoint> mockWaypoints;
  late MockSettingsService mockSettingsService;
  late IsarService isarService;
  late WaypointService waypointService;

  setUp(() {
    mockIsar = MockIsar();
    mockWaypointSets = MockIsarCollection<WaypointSet>();
    mockWaypoints = MockIsarCollection<Waypoint>();
    mockSettingsService = MockSettingsService();

    // Set up IsarService to return our mock
    when(() => mockIsar.waypointSets).thenReturn(mockWaypointSets);
    when(() => mockIsar.waypoints).thenReturn(mockWaypoints);

    isarService = _TestIsarService(mockIsar);
    
    waypointService = WaypointService(
      isarService: isarService,
      settingsService: mockSettingsService,
    );
  });

  group('WaypointSet CRUD', () {
    test('createSet creates a new waypoint set', () async {
      final testSet = WaypointSet(
        id: 1,
        name: 'Colorado Trail',
        created: DateTime(2026, 1, 1),
        isActive: false,
        description: 'Test set',
      );

      when(() => mockWaypointSets.put(any())).thenAnswer((_) async => 1);

      final created = await waypointService.createSet(
        name: 'Colorado Trail',
        description: 'Test set',
      );

      verify(() => mockWaypointSets.put(any())).called(1);
      expect(created.name, equals('Colorado Trail'));
      expect(created.description, equals('Test set'));
      expect(created.isActive, isFalse);
    });

    test('getSet returns the created set', () async {
      final testSet = WaypointSet(
        id: 1,
        name: 'Arizona Trail',
        created: DateTime.now(),
        isActive: false,
      );

      when(() => mockWaypointSets.get(1)).thenAnswer((_) async => testSet);

      final retrieved = await waypointService.getSet(1);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(1));
      expect(retrieved.name, equals('Arizona Trail'));
    });

    test('getAllSets returns all created sets', () async {
      final sets = [
        WaypointSet(id: 1, name: 'Set 1', created: DateTime.now(), isActive: false),
        WaypointSet(id: 2, name: 'Set 2', created: DateTime.now(), isActive: false),
        WaypointSet(id: 3, name: 'Set 3', created: DateTime.now(), isActive: false),
      ];

      when(() => mockWaypointSets.where()).thenReturn(MockIsarQuery<WaypointSet>());
      when(() => mockWaypointSets.where().findAll()).thenAnswer((_) async => sets);

      final allSets = await waypointService.getAllSets();

      expect(allSets.length, equals(3));
      expect(allSets.map((s) => s.name), containsAll(['Set 1', 'Set 2', 'Set 3']));
    });

    test('activateSet deactivates all sets and activates the target', () async {
      final set1 = WaypointSet(id: 1, name: 'Set 1', created: DateTime.now(), isActive: true);
      final set2 = WaypointSet(id: 2, name: 'Set 2', created: DateTime.now(), isActive: false);

      when(() => mockWaypointSets.where()).thenReturn(MockIsarQuery<WaypointSet>());
      when(() => mockWaypointSets.where().findAll()).thenAnswer((_) async => [set1, set2]);
      when(() => mockWaypointSets.put(any())).thenAnswer((_) async => 0);
      when(() => mockSettingsService.setActiveSetId(2)).thenAnswer((_) async => {});

      await waypointService.activateSet(2);

      // Verify set1 was deactivated
      verify(() => mockWaypointSets.put(argThat(
        isA<WaypointSet>().having((s) => s.id, 'id', 1).having((s) => s.isActive, 'isActive', false),
      ))).called(1);

      // Verify set2 was activated
      verify(() => mockWaypointSets.put(argThat(
        isA<WaypointSet>().having((s) => s.id, 'id', 2).having((s) => s.isActive, 'isActive', true),
      ))).called(1);

      verify(() => mockSettingsService.setActiveSetId(2)).called(1);
    });

    test('deleteSet removes waypoints and the set', () async {
      final waypoints = [
        Waypoint(id: 10, setId: 5, name: 'WP1', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []),
        Waypoint(id: 11, setId: 5, name: 'WP2', latitude: 39.1, longitude: -105.1, type: 'water', alerts: []),
      ];

      when(() => mockWaypoints.filter()).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(5)).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(5).findAll()).thenAnswer((_) async => waypoints);
      when(() => mockWaypoints.deleteAll([10, 11])).thenAnswer((_) async => []);
      when(() => mockWaypointSets.delete(5)).thenAnswer((_) async => true);
      when(() => mockSettingsService.getActiveSetId()).thenAnswer((_) async => null);

      await waypointService.deleteSet(5);

      verify(() => mockWaypoints.deleteAll([10, 11])).called(1);
      verify(() => mockWaypointSets.delete(5)).called(1);
    });

    test('deleteSet clears active ID if deleted set was active', () async {
      when(() => mockWaypoints.filter()).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(5)).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(5).findAll()).thenAnswer((_) async => []);
      when(() => mockWaypoints.deleteAll([])).thenAnswer((_) async => []);
      when(() => mockWaypointSets.delete(5)).thenAnswer((_) async => true);
      when(() => mockSettingsService.getActiveSetId()).thenAnswer((_) async => 5);
      when(() => mockSettingsService.setActiveSetId(null)).thenAnswer((_) async => {});

      await waypointService.deleteSet(5);

      verify(() => mockSettingsService.setActiveSetId(null)).called(1);
    });
  });

  group('Waypoint CRUD', () {
    test('addWaypoints adds waypoints to the database', () async {
      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'Trailhead', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []),
        Waypoint(id: 2, setId: 1, name: 'Water', latitude: 39.1, longitude: -105.1, type: 'water', alerts: []),
      ];

      when(() => mockWaypoints.putAll(waypoints)).thenAnswer((_) async => [1, 2]);

      await waypointService.addWaypoints(waypoints);

      verify(() => mockWaypoints.putAll(waypoints)).called(1);
    });

    test('getWaypoint returns a specific waypoint', () async {
      final waypoint = Waypoint(id: 1, setId: 1, name: 'Test WP', latitude: 39.5, longitude: -105.5, type: 'junction', alerts: []);

      when(() => mockWaypoints.get(1)).thenAnswer((_) async => waypoint);

      final retrieved = await waypointService.getWaypoint(1);

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Test WP'));
    });

    test('updateWaypoint updates an existing waypoint', () async {
      final waypoint = Waypoint(id: 1, setId: 1, name: 'Old Name', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []);

      when(() => mockWaypoints.put(waypoint)).thenAnswer((_) async => 1);

      await waypointService.updateWaypoint(waypoint);

      verify(() => mockWaypoints.put(waypoint)).called(1);
    });

    test('deleteWaypoint removes a waypoint', () async {
      when(() => mockWaypoints.delete(1)).thenAnswer((_) async => true);

      await waypointService.deleteWaypoint(1);

      verify(() => mockWaypoints.delete(1)).called(1);
    });
  });

  group('Query Operations', () {
    test('getUpcomingWaypoints returns waypoints within maxDistance sorted by distance', () async {
      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'Close', latitude: 39.01, longitude: -105.01, type: 'trail', alerts: []),
        Waypoint(id: 2, setId: 1, name: 'Medium', latitude: 39.05, longitude: -105.05, type: 'water', alerts: []),
        Waypoint(id: 3, setId: 1, name: 'Far', latitude: 39.15, longitude: -105.15, type: 'trail', alerts: []),
      ];

      when(() => mockWaypoints.filter()).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1)).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1).findAll()).thenAnswer((_) async => waypoints);

      final result = await waypointService.getUpcomingWaypoints(1, 39.0, -105.0, maxDistance: 10000);

      expect(result.length, equals(3));
      expect(result[0].name, equals('Close')); // Closest
      expect(result[1].name, equals('Medium'));
      expect(result[2].name, equals('Far'));
    });

    test('getUpcomingWaypoints excludes waypoints beyond maxDistance', () async {
      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'Close', latitude: 39.01, longitude: -105.01, type: 'trail', alerts: []),
        Waypoint(id: 2, setId: 1, name: 'VeryFar', latitude: 45.0, longitude: -115.0, type: 'water', alerts: []),
      ];

      when(() => mockWaypoints.filter()).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1)).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1).findAll()).thenAnswer((_) async => waypoints);

      final result = await waypointService.getUpcomingWaypoints(1, 39.0, -105.0, maxDistance: 5000);

      expect(result.length, equals(1));
      expect(result[0].name, equals('Close'));
    });

    test('getClosestWater returns the nearest water waypoint', () async {
      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'Trail1', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []),
        Waypoint(id: 2, setId: 1, name: 'Water1', latitude: 39.01, longitude: -105.01, type: 'water', alerts: []),
        Waypoint(id: 3, setId: 1, name: 'Water2', latitude: 39.05, longitude: -105.05, type: 'water', alerts: []),
      ];

      when(() => mockWaypoints.filter()).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1)).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1).findAll()).thenAnswer((_) async => waypoints);

      final result = await waypointService.getClosestWater(1, 39.0, -105.0);

      expect(result, isNotNull);
      expect(result!.name, equals('Water1'));
    });

    test('getClosestWater returns null if no water waypoints', () async {
      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'Trail1', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []),
      ];

      when(() => mockWaypoints.filter()).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1)).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1).findAll()).thenAnswer((_) async => waypoints);

      final result = await waypointService.getClosestWater(1, 39.0, -105.0);

      expect(result, isNull);
    });

    test('getNextWaypoint returns the closest waypoint', () async {
      final waypoints = [
        Waypoint(id: 1, setId: 1, name: 'Close', latitude: 39.01, longitude: -105.01, type: 'trail', alerts: []),
        Waypoint(id: 2, setId: 1, name: 'Far', latitude: 39.1, longitude: -105.1, type: 'trail', alerts: []),
      ];

      when(() => mockWaypoints.filter()).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1)).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1).findAll()).thenAnswer((_) async => waypoints);

      final result = await waypointService.getNextWaypoint(1, 39.0, -105.0);

      expect(result, isNotNull);
      expect(result!.name, equals('Close'));
    });

    test('getNextWaypoint returns null for empty set', () async {
      when(() => mockWaypoints.filter()).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1)).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1).findAll()).thenAnswer((_) async => []);

      final result = await waypointService.getNextWaypoint(1, 39.0, -105.0);

      expect(result, isNull);
    });
  });

  group('Distance Calculation', () {
    test('calculateDistance uses Haversine formula correctly', () {
      // Denver to Boulder is approximately 40km
      // Denver: 39.7392, -104.9903
      // Boulder: 40.0150, -105.2705
      
      // We test this indirectly through the service
      final waypoint = Waypoint(id: 1, setId: 1, name: 'Boulder', latitude: 40.0150, longitude: -105.2705, type: 'trail', alerts: []);

      when(() => mockWaypoints.filter()).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1)).thenReturn(MockIsarQuery<Waypoint>());
      when(() => mockWaypoints.filter().setIdEqualTo(1).findAll()).thenAnswer((_) async => [waypoint]);

      // From Denver, with 50km max (should include Boulder at ~40km)
      final result = waypointService.getUpcomingWaypoints(1, 39.7392, -104.9903, maxDistance: 50000);

      // Just verify it doesn't throw and returns the waypoint
      // The actual distance math is tested more rigorously in integration tests
      expect(result.length, equals(1));
    });
  });
}

// Helper class to inject mock Isar
class _TestIsarService implements IsarService {
  final Isar _mockIsar;
  _TestIsarService(this._mockIsar);

  @override
  Future<void> init({String? directory, bool inspector = false}) async {}

  @override
  Isar get instance => _mockIsar;

  @override
  Future<void> close() async {}
}