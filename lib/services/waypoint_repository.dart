import 'package:isar_community/isar.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/models/waypoint_set.dart';
import 'package:waypoint_alert_app/services/isar_service.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';

class WaypointRepository {
  final IsarService isarService;
  final SettingsService settingsService;

  WaypointRepository({
    required this.settingsService,
    required this.isarService,
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
        .findAll();
        // .sortByDistance();
  }

  Future<void> updateWaypoint(Waypoint waypoint) async {
    await _db.writeTxn(() => _db.waypoints.put(waypoint));
  }

  Future<void> deleteWaypoint(int id) async {
    await _db.writeTxn(() => _db.waypoints.delete(id));
  }


}