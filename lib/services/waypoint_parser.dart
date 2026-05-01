import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:waypoint_alert_app/models/waypoint.dart';
import 'package:waypoint_alert_app/models/waypoint_set.dart';

class WaypointParser {
  /// Parses a JSON file from assets and returns waypoints
  /// 
  /// [assetPath] - Path to the JSON file (e.g., 'assets/data-samples/waypoint-sample.json)
  /// [setId] - The waypoint set ID to assigne to all parsed waypoints
  static Future<List<Waypoint>> parseFromFile({
    required String assetPath,
    required int setId,
  }) async {
    final jsonString = await rootBundle.loadString(assetPath);
    return parseFromString(jsonString, setId);
  }

  /// Parses a JSON string and returns waypoints
  static List<Waypoint> parseFromString(
    String jsonString,
    int setId,
  ) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final waypointsJson = json['waypoints'] as List;

    return waypointsJson
      .map((wp) => Waypoint.fromJson(wp as Map<String, dynamic>).copyWith(setId: setId))
      .toList();
  }

  /// Parses a waypoint set from JSON (if your JSON includes set metadata)
  static WaypointSet? parseWaypointSetFromJson(Map<String, dynamic> json) {
    if (json.containsKey('waypointSet')) {
      return WaypointSet.fromJson(json['waypointSet'] as Map<String, dynamic>);
    }
    return null;
  }
}