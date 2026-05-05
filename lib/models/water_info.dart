import 'package:waypoint_alert_app/models/waypoint.dart';

class WaterInfo {
  final Waypoint? closestWater;
  final double? closestDitanceMeters;
  final double? closestBearing;
  final bool isClosestBehind; // true if closest water is behind us
  final Waypoint? nextWaterAhead; // only populated if closest is behind
  final double? nextWaterDistanceMeters;
  final double? nextWaterBearing;

  WaterInfo({
    required this.closestWater,
    required this.closestDitanceMeters,
    required this.closestBearing,
    this.isClosestBehind = false,
    this.nextWaterAhead,
    this.nextWaterDistanceMeters,
    this.nextWaterBearing,
  });
}