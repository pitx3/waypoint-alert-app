import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

//
enum WaypointType {
  unknown,
  water,
  trailhead,
  camp,
  junction;

  String get displayName{
    switch (this) {
      case WaypointType.unknown: return 'Unknown';
      case WaypointType.water: return 'Water';
      case WaypointType.trailhead: return 'Trailhead';
      case WaypointType.camp: return 'Camp';
      case WaypointType.junction: return 'Junction';
    }
  }

  IconData get icon {
    switch (this) {
      case WaypointType.unknown: return Icons.help_outline;
      case WaypointType.water: return Icons.water_drop;
      case WaypointType.trailhead: return Icons.hiking;
      case WaypointType.camp: return MdiIcons.tent;
      case WaypointType.junction: return Icons.signpost;
    }
  }

  Color get color {
    switch (this) {
      case WaypointType.unknown: return Colors.grey;
      case WaypointType.water: return Colors.lightBlue;
      case WaypointType.trailhead: return Colors.green;
      case WaypointType.camp: return Colors.orange;
      case WaypointType.junction: return Colors.purple;
    }  
  }

  static WaypointType? fromString(String value) {
    final normalized = value.trim().toLowerCase();
    try {
      return WaypointType.values.byName(normalized);
    } catch (_) {
      return null;
    }
  }

}