import 'dart:math' as math;

/// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in meters
  double calculateDistance(
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

  double calculateBearing(
    double fromLat,
    double fromLon,
    double toLat,
    double toLon,
  ) {
    final lat1 = _toRadians(fromLat);
    final lat2 = _toRadians(toLat);
    final dLon = _toRadians(toLon - fromLon);

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    // atan2 handles x=0 gracefully
    final bearingRad = math.atan2(y, x);
    final bearingDeg = _toDegrees(bearingRad);

    // normalize to 0-360 and return
    return (bearingDeg + 360) % 360;
  }


  double _toRadians(double degrees) => degrees * (math.pi / 180.0);
  double _toDegrees(double radians) => radians * (180.0 / math.pi);