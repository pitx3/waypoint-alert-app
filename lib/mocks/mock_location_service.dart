import 'dart:async';
import 'package:waypoint_alert_app/services/location_service.dart';

typedef LatLon = ({double lat, double lon});

/// Mock location service for development/testing
/// 
/// **TO CHANGE LOCATION:** Edit the currentLocationName string
class MockLocationService implements LocationService {
  // ========== EDIT THIS NAME ==================
  static const String currentLocationName = 'nearSection1End';
  // ========== END EDIT SECTION ================

  static const Map<String, LatLon> _locations = {
    'segment01Start': (lat: 39.49127, lon: -105.09501),
    'pastFirstWater': (lat: 39.46894, lon: -105.13403),
    'nearSection1End': (lat: 39.40195, lon: -105.16482),
  };


  @override
  double get latitude => _locations[currentLocationName]!.lat;

  @override
  double get longitude => _locations[currentLocationName]!.lon;

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