import 'dart:async';
import 'package:waypoint_alert_app/services/location_service.dart';

/// Mock location service for development/testing
/// 
/// **TO CHANGE LOCATION:** Edit the hardcoded coordinates below and hot reload
/// // Current location: CT Segment 01 start (default)
class MockLocationService implements LocationService {
  // =========== EDIT THESE VALUES ==============
  static const double mockLatitude = 39.49127;
  static const double mockLongitude = -105.09501;
  // =========== END EDITABLE SECTION ===========

  @override
  double get latitude => mockLatitude;

  @override
  double get longitude => mockLongitude;

  @override
  Stream<LocationUpdate> get locationStream {
    // for mock, we don't stream updates - caller triggers realod via hot reload
    return const Stream.empty();
  }

  @override
  Future<bool> isLocationEnabled() async => true;

  @override
  Future<bool> requestPermission() async => true;
}