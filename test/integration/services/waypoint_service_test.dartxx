// test/integration/services/waypoint_service_test.dart

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/models/waypoint_set.dart';
import 'package:waypoint_alert_app/services/isar_service.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/services/waypoint_service.dart';

void main() {
  late Directory tempDir;
  late IsarService isarService;
  late SettingsService settingsService;
  late WaypointService waypointService;

  setUpAll(() async {
    // Create a temporary directory for test database
    tempDir = await Directory.systemTemp.createTemp('waypoint_test_');
    
    // Override path_provider for tests
    setApplicationDocumentsPath(tempDir.path);
  });

  setUp(() async {
    // Initialize Isar with temp directory
    isarService = IsarService();
    await isarService.init(directory: tempDir.path);
    
    // Initialize SharedPreferences for tests
    SharedPreferences.setMockInitialValues({});
    settingsService = await SettingsService.create();
    
    // Create waypoint service
    waypointService = WaypointService(
      isarService: isarService,
      settingsService: settingsService,
    );
  });

  tearDown(() async {
    // Clear database between tests
    await isarService.instance.writeTxn(() async {
      await isarService.instance.waypointSets.clear();
      await isarService.instance.waypoints.clear();
    });
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() async {
    // Close Isar and clean up temp directory
    await isarService.instance.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('WaypointSet CRUD', () {
    test('createSet creates a new waypoint set', () async {
      final created = await waypointService.createSet(
        name: 'Colorado Trail',
        description: 'Test set',
      );

      expect(created.id, isNot(equals(Isar.autoIncrement)));
      expect(created.name, equals('Colorado Trail'));
      expect(created.description, equals('Test set'));
      expect(created.isActive, isFalse);
      expect(created.created, isNotNull);
    });

    test('getSet returns the created set', () async {
      final created = await waypointService.createSet(
        name: 'Arizona Trail',
        description: 'AZT waypoints',
      );

      final retrieved = await waypointService.getSet(created.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(created.id));
      expect(retrieved.name, equals('Arizona Trail'));
    });

    test('getAllSets returns all created sets', () async {
      await waypointService.createSet(name: 'Set 1');
      await waypointService.createSet(name: 'Set 2');
      await waypointService.createSet(name: 'Set 3');

      final allSets = await waypointService.getAllSets();

      expect(allSets.length, equals(3));
      expect(allSets.map((s) => s.name), containsAll(['Set 1', 'Set 2', 'Set 3']));
    });

    test('activateSet activates the target set and updates settings', () async {
      final set1 = await waypointService.createSet(name: 'Set 1');
      final set2 = await waypointService.createSet(name: 'Set 2');

      await waypointService.activateSet(set2.id);

      // Check settings service has the active ID
      final activeId = await settingsService.getActiveSetId();
      expect(activeId, equals(set2.id));

      // Verify the sets in database have correct isActive state
      final retrievedSet1 = await waypointService.getSet(set1.id);
      final retrievedSet2 = await waypointService.getSet(set2.id);
      
      expect(retrievedSet1!.isActive, isFalse);
      expect(retrievedSet2!.isActive, isTrue);
    });

    test('deleteSet removes the set and clears active ID if needed', () async {
      final set1 = await waypointService.createSet(name: 'Set 1');
      await waypointService.activateSet(set1.id);
      
      await waypointService.deleteSet(set1.id);

      final retrieved = await waypointService.getSet(set1.id);
      expect(retrieved, isNull);

      final activeId = await settingsService.getActiveSetId();
      expect(activeId, isNull);
    });

    test('deleteSet removes all waypoints in the set', () async {
      final set1 = await waypointService.createSet(name: 'Set 1');
      
      final waypoints = [
        Waypoint(id: Isar.autoIncrement, setId: set1.id, name: 'WP1', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []),
        Waypoint(id: Isar.autoIncrement, setId: set1.id, name: 'WP2', latitude: 39.1, longitude: -105.1, type: 'water', alerts: []),
      ];
      await waypointService.addWaypoints(waypoints);

      await waypointService.deleteSet(set1.id);

      final remainingWaypoints = await waypointService.getWaypointsForSet(set1.id);
      expect(remainingWaypoints, isEmpty);
    });
  });

  group('Waypoint CRUD', () {
    test('addWaypoints adds waypoints to the database', () async {
      final set1 = await waypointService.createSet(name: 'Set 1');
      
      final waypoints = [
        Waypoint(id: Isar.autoIncrement, setId: set1.id, name: 'Trailhead', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: [Alert(distanceMeters: 500)]),
        Waypoint(id: Isar.autoIncrement, setId: set1.id, name: 'Water Source', latitude: 39.1, longitude: -105.1, type: 'water', alerts: []),
      ];

      await waypointService.addWaypoints(waypoints);

      final retrieved = await waypointService.getWaypointsForSet(set1.id);
      expect(retrieved.length, equals(2));
      expect(retrieved.map((w) => w.name), containsAll(['Trailhead', 'Water Source']));
    });

    test('getWaypoint returns a specific waypoint', () async {
      final set1 = await waypointService.createSet(name: 'Set 1');
      
      final waypoint = Waypoint(id: Isar.autoIncrement, setId: set1.id, name: 'Test WP', latitude: 39.5, longitude: -105.5, type: 'junction', alerts: []);
      await waypointService.addWaypoints([waypoint]);

      final retrieved = await waypointService.getWaypoint(waypoint.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Test WP'));
    });

    test('updateWaypoint updates an existing waypoint', () async {
      final set1 = await waypointService.createSet(name: 'Set 1');
      
      final waypoint = Waypoint(id: Isar.autoIncrement, setId: set1.id, name: 'Old Name', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []);
      await waypointService.addWaypoints([waypoint]);

      waypoint.name = 'Updated Name';
      waypoint.notes = 'Added notes';
      await waypointService.updateWaypoint(waypoint);

      final retrieved = await waypointService.getWaypoint(waypoint.id);
      expect(retrieved!.name, equals('Updated Name'));
      expect(retrieved.notes, equals('Added notes'));
    });

    test('deleteWaypoint removes a waypoint', () async {
      final set1 = await waypointService.createSet(name: 'Set 1');
      
      final waypoint = Waypoint(id: Isar.autoIncrement, setId: set1.id, name: 'To Delete', latitude: 39.0, longitude: -105.0, type: 'trail', alerts: []);
      await waypointService.addWaypoints([waypoint]);

      await waypointService.deleteWaypoint(waypoint.id);

      final retrieved = await waypointService.getWaypoint(waypoint.id);
      expect(retrieved, isNull);
    });
  });

  group('Query Operations', () {
    late WaypointSet testSet;

    setUp(() async {
      testSet = await waypointService.createSet(name: 'Test Set');
      
      // Create waypoints at various distances from a reference point (39.0, -105.0)
      final waypoints = [
        // Close waypoint (~1.5km away)
        Waypoint(id: Isar.autoIncrement, setId: testSet.id, name: 'Close', latitude: 39.01, longitude: -105.01, type: 'trail', alerts: []),
        // Medium waypoint (~5km away)
        Waypoint(id: Isar.autoIncrement, setId: testSet.id, name: 'Medium', latitude: 39.05, longitude: -105.05, type: 'water', alerts: []),
        // Far waypoint (~15km away)
        Waypoint(id: Isar.autoIncrement, setId: testSet.id, name: 'Far', latitude: 39.15, longitude: -105.15, type: 'water', alerts: []),
        // Another trail waypoint
        Waypoint(id: Isar.autoIncrement, setId: testSet.id, name: 'Trail2', latitude: 39.02, longitude: -105.02, type: 'trail', alerts: []),
      ];
      
      await waypointService.addWaypoints(waypoints);
    });

    test('getUpcomingWaypoints returns waypoints within maxDistance sorted by distance', () async {
      final result = await waypointService.getUpcomingWaypoints(
        testSet.id,
        39.0,
        -105.0,
        maxDistance: 10000, // 10km
      );

      // Should return Close, Trail2, and Medium (all within 10km)
      expect(result.length, equals(3));
      expect(result[0].name, equals('Close')); // Closest
      expect(result[1].name, equals('Trail2'));
      expect(result[2].name, equals('Medium'));
    });

    test('getUpcomingWaypoints excludes waypoints beyond maxDistance', () async {
      final result = await waypointService.getUpcomingWaypoints(
        testSet.id,
        39.0,
        -105.0,
        maxDistance: 3000, // 3km
      );

      // Should only return Close
      expect(result.length, equals(1));
      expect(result[0].name, equals('Close'));
    });

    test('getClosestWater returns the nearest water waypoint', () async {
      final result = await waypointService.getClosestWater(
        testSet.id,
        39.0,
        -105.0,
      );

      expect(result, isNotNull);
      expect(result!.name, equals('Medium')); // Medium is closer than Far
      expect(result.type, equals('water'));
    });

    test('getClosestWater returns null if no water within maxDistance', () async {
      final result = await waypointService.getClosestWater(
        testSet.id,
        39.0,
        -105.0,
        maxDistance: 1000, // 1km - too close to reach any water
      );

      expect(result, isNull);
    });

    test('getClosestWater returns null if no water waypoints exist', () async {
      // Create a set with only trail waypoints
      final trailOnlySet = await waypointService.createSet(name: 'Trail Only');
      await waypointService.addWaypoints([
        Waypoint(id: Isar.autoIncrement, setId: trailOnlySet.id, name: 'Trail1', latitude: 39.01, longitude: -105.01, type: 'trail', alerts: []),
      ]);

      final result = await waypointService.getClosestWater(
        trailOnlySet.id,
        39.0,
        -105.0,
      );

      expect(result, isNull);
    });

    test('getNextWaypoint returns the closest waypoint', () async {
      final result = await waypointService.getNextWaypoint(
        testSet.id,
        39.0,
        -105.0,
      );

      expect(result, isNotNull);
      expect(result!.name, equals('Close'));
    });

    test('getNextWaypoint returns null for empty set', () async {
      final emptySet = await waypointService.createSet(name: 'Empty');
      
      final result = await waypointService.getNextWaypoint(
        emptySet.id,
        39.0,
        -105.0,
      );

      expect(result, isNull);
    });
  });

  // TODO: Move this to a different test that directly tests the Haversine calculation
  group('Distance Calculation', () {
    test('calculate distance between two points', () async {
      // Test the internal distance calculation indirectly through getUpcomingWaypoints
      // Denver to Boulder is approximately 40km
      final set1 = await waypointService.createSet(name: 'Distance Test');
      await waypointService.addWaypoints([
        Waypoint(id: Isar.autoIncrement, setId: set1.id, name: 'Boulder', latitude: 40.0150, longitude: -105.2705, type: 'trail', alerts: []),
      ]);

      // From Denver (39.7392, -104.9903)
      final result = await waypointService.getUpcomingWaypoints(
        set1.id,
        39.7392,
        -104.9903,
        maxDistance: 50000, // 50km
      );

      expect(result.length, equals(1));
      expect(result[0].name, equals('Boulder'));
    });
  });
}