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
}

class LocationUpdate {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracy; // meters, null if unknown

  const LocationUpdate({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
  });
}