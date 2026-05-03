// lib/services/waypoint_service.dart

import 'dart:math' as math;

import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/services/waypoint_repository.dart';

class WaypointService {
  final SettingsService settingsService;
  final WaypointRepository waypointRepository;

  WaypointService({
    required this.waypointRepository,
    required this.settingsService,
  });

 
  // ==================== Query Operations for GPS Monitoring ====================

  /// Returns the next waypoint ahead on the trail (closest waypoint in front)
  /// This is a simplified version - assumes waypoints are ordered by distance
  /// A more sophisticated version would use bearing to determine "ahead"
  Future<Waypoint?> getNextWaypoint(
    int setId,
    double currentLat,
    double currentLon,
  ) async {
    final waypoints = await waypointRepository.getWaypointsForSet(setId);
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
    final waypoints = await waypointRepository.getWaypointsForSet(setId);
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
    final waypoints = await waypointRepository.getWaypointsForSet(setId);
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

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
        math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) *
        math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.141592653589793 / 180.0);
}