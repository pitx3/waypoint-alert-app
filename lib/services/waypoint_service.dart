// lib/services/waypoint_service.dart

import 'dart:math' as math;

import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/services/waypoint_repository.dart';

class WaypointService {
  final SettingsService settingsService;
  final WaypointRepository repository;

  WaypointService({
    required this.repository,
    required this.settingsService,
  });



  /// Calculate distance between two waypoints by name
  double getDistanceBetweenWaypoints(
    List<Waypoint> allWaypoints,
    String waypointName1,
    String waypointName2,
  ) {
    final wp1 = allWaypoints.firstWhere((wp) => wp.name == waypointName1);
    final wp2 = allWaypoints.firstWhere((wp) => wp.name == waypointName2);
    
    return _calculateDistance(
      wp1.latitude,
      wp1.longitude,
      wp2.latitude,
      wp2.longitude,
    );
  }
 
  // ==================== Query Operations for GPS Monitoring ====================

  /// Get the closest waypoint by distance
  Future<Waypoint?> getClosestWaypoint(
    int setId,
    double currentLat,
    double currentLon,
  ) async {
    final allWaypoints = await repository.getWaypointsForSet(setId);
    
    if (allWaypoints.isEmpty) return null;
    
    Waypoint? closest;
    double minDistance = double.infinity;
    
    for (final wp in allWaypoints) {
      final distance = _calculateDistance(
        currentLat,
        currentLon,
        wp.latitude,
        wp.longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        closest = wp;
      }
    }
    
    return closest;
  }


  /// Get the next waypoint ahead on the trail
  Future<Waypoint?> getNextWaypoint(
    int setId,
    double currentLat,
    double currentLon,
  ) async {
    final allWaypoints = await repository.getWaypointsForSet(setId);
    
    if (allWaypoints.isEmpty) return null;
    
    // Sort by trail order (name)
    allWaypoints.sort((a, b) => a.name.compareTo(b.name));
    
    // Find closest waypoint (B)
    final closestB = await getClosestWaypoint(setId, currentLat, currentLon);
    if (closestB == null) return null;
    
    // Find index of closest waypoint
    final bIndex = allWaypoints.indexWhere((wp) => wp.id == closestB.id);
    if (bIndex == -1) return null;
    
    // Get before (A) and after (C) waypoints
    final waypointA = bIndex > 0 ? allWaypoints[bIndex - 1] : null;
    final waypointC = bIndex < allWaypoints.length - 1 ? allWaypoints[bIndex + 1] : null;
    
    // Calculate distances from current location
    // final distToB = _calculateDistance(currentLat, currentLon, closestB.latitude, closestB.longitude);
    final distToA = waypointA != null 
      ? _calculateDistance(currentLat, currentLon, waypointA.latitude, waypointA.longitude)
      : double.infinity;
    final distToC = waypointC != null
      ? _calculateDistance(currentLat, currentLon, waypointC.latitude, waypointC.longitude)
      : double.infinity;
    
    // Calculate distances between waypoints
    final distAB = waypointA != null 
      ? getDistanceBetweenWaypoints(allWaypoints, waypointA.name, closestB.name)
      : double.infinity;
    final distBC = waypointC != null
      ? getDistanceBetweenWaypoints(allWaypoints, closestB.name, waypointC.name)
      : double.infinity;
    
    // Triangle inequality test:
    // If distToA < distAB, we're before B (approaching from A's direction)
    // If distToC < distBC, we're after B (approaching C)
    final beforeB = distToA < distAB;
    final afterB = distToC < distBC;

    // Edge case: no C means we're past the end of the trail
    if (waypointC == null) {
      if (!beforeB) return null;
      return closestB;
    }

    // Edge case: no A means we're before the start of the trail
    if (waypointA == null) {
      if (afterB) return waypointC;
      return closestB;
    }
    
    // Determine which waypoint we're approaching
    if (beforeB && !afterB) {
      // We're between A and B, approaching B
      return closestB;
    } else if (afterB && !beforeB) {
      // We're between B and C, approaching C
      return waypointC;
    } else if (!beforeB && !afterB) {
      // We're at or very close to B
      return closestB;
    } else {
      // Both true or both false = ambiguous (off trail or weird geometry)
      // Default to returning closest
      return closestB;
    }
  }


  /// Get closest water waypoint (no distance limit)
  Future<Waypoint?> getClosestWater(
    int setId,
    double currentLat,
    double currentLon,
  ) async {
    final allWaypoints = await repository.getWaypointsForSet(setId);
    
    final waterWaypoints = allWaypoints.where((wp) => 
      wp.type.toLowerCase() == 'water'
    ).toList();
    
    if (waterWaypoints.isEmpty) return null;
    
    Waypoint? closestWater;
    double minDistance = double.infinity;
    
    for (final wp in waterWaypoints) {
      final distance = _calculateDistance(
        currentLat,
        currentLon,
        wp.latitude,
        wp.longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        closestWater = wp;
      }
    }
    
    return closestWater;
  }

  /// Get next water waypoint ahead on trail
  Future<Waypoint?> getNextWater(
    int setId,
    double currentLat,
    double currentLon,
  ) async {
    final nextWaypoint = await getNextWaypoint(setId, currentLat, currentLon);
    final allWaypoints = await repository.getWaypointsForSet(setId);

    if (allWaypoints.isEmpty) return null;

    allWaypoints.sort((a,b) => a.name.compareTo(b.name));

    List<Waypoint> aheadWaypoints;
    if (nextWaypoint != null) {
      aheadWaypoints = allWaypoints
        .where((wp) => wp.name.compareTo(nextWaypoint.name) >= 0)
        .toList();
    } else {
      return null;
    }
    
    final waterAhead = aheadWaypoints
      .where((wp) => wp.type.toLowerCase() == 'water')
      .toList();
    
    if (waterAhead.isEmpty) return null;
    
    return waterAhead.first;
  }

  /// Returns waypoints within maxDistance meters, sorted by distance
  Future<List<Waypoint>> getUpcomingWaypoints(
    int setId,
    double currentLat,
    double currentLon, {
    int maxDistance = 5000,    // TODO: Remove 'magic number'
  }) async {
    final allWaypoints = await repository.getWaypointsForSet(setId);
    if (allWaypoints.isEmpty) return [];

    // sort by name (trail order)
    allWaypoints.sort((a, b) => a.name.compareTo(b.name));

    // find the first waypoint ahead on the trail
    final nextWaypoint = await getNextWaypoint(setId, currentLat, currentLon);
    if (nextWaypoint == null) return [];

    // find the index of the next waypoint on the sorted list
    final startIndex = allWaypoints.indexWhere((wp) => wp.id == nextWaypoint.id);
    if (startIndex == -1) return [];

    // walk forward through waypoints, collecting those within maxDistance
    final upcoming = <Waypoint>[];
    for (var i = startIndex; i < allWaypoints.length; i++) {
      final waypoint = allWaypoints[i];
      final distance = _calculateDistance(currentLat, currentLon, waypoint.latitude, waypoint.longitude);

      if (distance <= maxDistance) {
        upcoming.add(waypoint);
      } else {
        // once we exceed maxDistance, stop (waypoints are in trail order)
        break;
      }
    }

    return upcoming;    
  }

  // ==== Waypoint Set Operations ==== //
  Future<void> activateSet(int setId) async {
    // Deactivate all sets first
    final allSets = await repository.getAllSets();
    for (final set in allSets) {
      set.isActive = (set.id == setId);
    }
    await repository.updateSets(allSets);

    // Update the active set ID in settings
    await settingsService.setActiveSetId(setId);
  }

  Future<void> deleteSet(int setId) async {
    await repository.deleteSet(setId);

    // Clear active set ID if we deleted the active set
    final currentActiveId = settingsService.getActiveSetId();
    if (currentActiveId == setId) {
      await settingsService.setActiveSetId(null);
    }
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