import 'dart:async';

/// Abstract interface for location services
/// Allows swapping between mock (dev) and real GPS (production) implementations.
abstract class LocationService {
  /// Current latitude
  double get latitude;

  /// Current longitude
  double get longitude;

  /// Stream of location updates (for real GPS tracking)
  Stream<LocationUpdate> get locationStream;

  /// Whether location services are available and enabled
  Future<bool> isLocationEnabled();

  /// Request location permission (returns true if granted)
  Future<bool> requestPermission();

  /// Start location tracking (turn on GPS hardware)
  /// Call when user enables monitoring
  Future<void> start();

  /// Stop location tracking (turn off GPS hardware to save power)
  /// Call when user disables monitoring or app is backgrounded
  Future<void> stop();

  /// Adjust GPS ping interval (e.g. near critical waypoints)
  void updatePingInterval(Duration newInterval);

}

class LocationUpdate {
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final double? accuracy; // meters, null if unknown
  final bool hasValidFix;

  const LocationUpdate({
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.accuracy,
    this.hasValidFix = true,
  });
}