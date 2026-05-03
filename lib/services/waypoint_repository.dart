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

  Future<void> updateSets(List<WaypointSet> sets) async {
    await _db.writeTxn(() => _db.waypointSets.putAll(sets));
  }

  Future<void> deleteSet(int setId) async {
    await _db.writeTxn(() async {
      final waypoints = await _db.waypoints
        .filter()
        .setIdEqualTo(setId)
        .findAll();
      await _db.waypoints.deleteAll(waypoints.map((w) => w.id).toList());
      await _db.waypointSets.delete(setId);
    });
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