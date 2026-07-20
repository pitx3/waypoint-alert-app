import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:waypoint_alert_app/services/location_service.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';

class GeolocatorLocationSerivce implements LocationService {

  final SettingsService _settingsService;

  Duration? _gpsTimeout;
  Duration? _pingInterval;

  GeolocatorLocationSerivce(this._settingsService) {
    _gpsTimeout = Duration(seconds: _settingsService.getGpsTimeoutSeconds());
    _pingInterval = Duration(seconds: _settingsService.getGpsPingInterval());
  }

  late final LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: _gpsTimeout,
  );

  double _currentLat = 0.0;
  double _currentLon = 0.0;
  DateTime? _lastUpdate;
  StreamController<LocationUpdate>? _streamController;
  Timer? _timer;
  bool _isRunning = false;

  @override
  double get latitude => _currentLat;

  @override
  double get longitude => _currentLon;

  @override
  Stream<LocationUpdate> get locationStream {
    _streamController ??= StreamController<LocationUpdate>.broadcast();
    return _streamController!.stream;
  }

  @override
  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
  }

  @override
  Future<void> start() async {
    if (_isRunning) return;

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    _isRunning = true;

    // Get initial position (GPS on -> fix -> off)
    await _emitCurrentPosition();

    // Start timer for periodic pings (GPS off between pings)
    _startTimer();
  }

  /// Get a GPS fix, emit it, then GPS hardware goes back to sleep
  Future<void> _emitCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );

      _currentLat = position.latitude;
      _currentLon = position.longitude;
      _lastUpdate = DateTime.now();

      _streamController?.add(LocationUpdate(
        latitude: _currentLat,
        longitude: _currentLon,
        timestamp: _lastUpdate!,
        accuracy: position.accuracy,
      ));
    } catch (e) {
      // TODO: Exception handling for failure to get GPS position
    }  
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  @override
  void updatePingInterval(Duration newInterval) {
    _pingInterval = newInterval;
    if (!_isRunning) return; 
    _startTimer();
  }

  /// Cancel any existing timer and start a new one
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_pingInterval!, (_) async {
      await _emitCurrentPosition();
    });
  }

}