// lib/services/moving_mock_location_service.dart

import 'dart:async';
import 'package:waypoint_alert_app/services/location_service.dart';

typedef LatLon = ({double lat, double lon});

/// Mock location service that simulates movement along a route
/// 
/// Useful for testing location update handling without real GPS.
/// Starts emitting updates when [start] is called, stops when [stop] is called.
class MovingMockLocationService implements LocationService {
  /// Route segments to simulate (in order)
  final List<LatLon> route;
  
  /// Interval between location updates (default: 3 seconds for testing)
  final Duration updateInterval;
  
  /// Whether to loop the route when reaching the end
  final bool loop;

  double _currentLat = 0.0;
  double _currentLon = 0.0;
  int _currentIndex = 0;
  StreamController<LocationUpdate>? _streamController;
  Timer? _timer;

  MovingMockLocationService({
    required this.route,
    this.updateInterval = const Duration(seconds: 8),
    this.loop = true,
  }) {
    if (route.isNotEmpty) {
      _currentLat = route.first.lat;
      _currentLon = route.first.lon;
    }
  }

  @override
  double get latitude => _currentLat;

  @override
  double get longitude => _currentLon;

  @override
  Stream<LocationUpdate> get locationStream {
    _streamController ??= StreamController<LocationUpdate>.broadcast();
    return _streamController!.stream;
  }

  /// Start emitting location updates
  @override
  Future<void> start() async {
    if (_timer != null) return; // Already running

    _timer = Timer.periodic(updateInterval, (_) {
      _moveToNextPoint();
    });
  }

  /// Stop emitting location updates
  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  void _moveToNextPoint() {
    if (route.isEmpty) return;
    print('Current Index: {$_currentIndex}');

    _currentIndex++;
    if (_currentIndex >= route.length) {
      if (loop) {
        _currentIndex = 0;
      } else {
        _currentIndex = route.length - 1;
      }
    }

    _currentLat = route[_currentIndex].lat;
    _currentLon = route[_currentIndex].lon;

    _streamController?.add(LocationUpdate(
      latitude: _currentLat,
      longitude: _currentLon,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<bool> isLocationEnabled() async => true;

  @override
  Future<bool> requestPermission() async => true;

  // @override
  // void dispose() {
  //   stop();
  //   _streamController?.close();
  // }
}