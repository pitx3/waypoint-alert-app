// lib/services/waypoint_service.dart

import 'package:isar_community/isar.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/models/waypoint_set.dart';
import 'package:waypoint_alert_app/services/isar_service.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';

class WaypointService {
  final IsarService isarService;
  final SettingsService settingsService;

  WaypointService({
    required this.isarService,
    required this.settingsService,
  });

  Isar get _db => isarService.instance;

  // ==================== WaypointSet Operations ====================

  Future<WaypointSet> createSet({
    required String name,
    String? description,
  }) async {
    final waypointSet = WaypointSet(
      name: name,
      created: DateTime.now(),
      isActive: false,
      description: description,
    );

    await _db.writeTxn(() => _db.waypointSets.put(waypointSet));
    return waypointSet;
  }

  Future<void> activateSet(int setId) async {
    // Deactivate all sets first
    final allSets = await _db.waypointSets.where().findAll();
    await _db.writeTxn(() async {
      for (final set in allSets) {
        set.isActive = (set.id == setId);
        await _db.waypointSets.put(set);
      }
    });

    // Update the active set ID in settings
    await settingsService.setActiveSetId(setId);
  }

  Future<void> deleteSet(int setId) async {
    await _db.writeTxn(() async {
      // Delete all waypoints in this set first
      final waypoints = await _db.waypoints
          .filter()
          .setIdEqualTo(setId)
          .findAll();
      await _db.waypoints.deleteAll(waypoints.map((w) => w.id).toList());

      // Delete the set
      await _db.waypointSets.delete(setId);
    });

    // Clear active set ID if we deleted the active set
    final currentActiveId = await settingsService.getActiveSetId();
    if (currentActiveId == setId) {
      await settingsService.setActiveSetId(null);
    }
  }

  Future<WaypointSet?> getSet(int setId) async {
    return _db.waypointSets.get(setId);
  }

  Future<List<WaypointSet>> getAllSets() async {
    return _db.waypointSets.where().findAll();
  }

  Future<WaypointSet?> getActiveSet() async {
    final activeId = await settingsService.getActiveSetId();
    if (activeId == null) return null;
    return getSet(activeId);
  }

  // ==================== Waypoint Operations ====================

  Future<void> addWaypoints(List<Waypoint> waypoints) async {
    if (waypoints.isEmpty) return;
    await _db.writeTxn(() => _db.waypoints.putAll(waypoints));
  }

  Future<Waypoint?> getWaypoint(int id) async {
    return _db.waypoints.get(id);
  }

  Future<List<Waypoint>> getWaypointsForSet(int setId) async {
    return _db.waypoints
        .filter()
        .setIdEqualTo(setId)
        .sortByDistance();
  }

  Future<void> updateWaypoint(Waypoint waypoint) async {
    await _db.writeTxn(() => _db.waypoints.put(waypoint));
  }

  Future<void> deleteWaypoint(int id) async {
    await _db.writeTxn(() => _db.waypoints.delete(id));
  }

  // ==================== Query Operations for GPS Monitoring ====================

  /// Returns the next waypoint ahead on the trail (closest waypoint in front)
  /// This is a simplified version - assumes waypoints are ordered by distance
  /// A more sophisticated version would use bearing to determine "ahead"
  Future<Waypoint?> getNextWaypoint(
    int setId,
    double currentLat,
    double currentLon,
  ) async {
    final waypoints = await getWaypointsForSet(setId);
    if (waypoints.isEmpty) return null;

    Waypoint? closest;
    double minDistance = double.infinity;

    for (final waypoint in waypoints) {
      final distance = _calculateDistance(
        currentLat,
        currentLon,
        waypoint.latitude,
        waypoint.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closest = waypoint;
      }
    }

    return closest;
  }

  /// Returns the closest water waypoint within maxDistance meters
  Future<Waypoint?> getClosestWater(
    int setId,
    double currentLat,
    double currentLon, {
    double maxDistance = 10000,
  }) async {
    final waypoints = await getWaypointsForSet(setId);
    final waterWaypoints = waypoints.where((w) => w.type.toLowerCase() == 'water');

    if (waterWaypoints.isEmpty) return null;

    Waypoint? closest;
    double minDistance = double.infinity;

    for (final waypoint in waterWaypoints) {
      final distance = _calculateDistance(
        currentLat,
        currentLon,
        waypoint.latitude,
        waypoint.longitude,
      );

      if (distance < minDistance && distance <= maxDistance) {
        minDistance = distance;
        closest = waypoint;
      }
    }

    return closest;
  }

  /// Returns waypoints within maxDistance meters, sorted by distance
  Future<List<Waypoint>> getUpcomingWaypoints(
    int setId,
    double currentLat,
    double currentLon, {
    double maxDistance = 5000,
  }) async {
    final waypoints = await getWaypointsForSet(setId);
    final upcoming = <Waypoint, double>{};

    for (final waypoint in waypoints) {
      final distance = _calculateDistance(
        currentLat,
        currentLon,
        waypoint.latitude,
        waypoint.longitude,
      );

      if (distance <= maxDistance) {
        upcoming[waypoint] = distance;
      }
    }

    // Sort by distance and return just the waypoints
    final sorted = upcoming.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sorted.map((e) => e.key).toList();
  }

  // ==================== Utility ====================

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in meters
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000; // meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        _toRadians(lat1).cos() *
            _toRadians(lat2).cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();

    final c = 2 * (a.sqrt().asin());
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.141592653589793 / 180.0);
}