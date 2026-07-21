import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/models/water_info.dart';
import 'package:waypoint_alert_app/services/location_service.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/services/waypoint_service.dart';
import 'package:waypoint_alert_app/widgets/banners/monitoring_banner.dart';
import 'package:waypoint_alert_app/widgets/bottom_sheets/set_options_bottom_sheet.dart';
// import 'package:waypoint_alert_app/widgets/cards/active_set_card.dart';
// import 'package:waypoint_alert_app/widgets/cards/closest_water_card.dart';
import 'package:waypoint_alert_app/widgets/cards/empty_state_card.dart';
import 'package:waypoint_alert_app/widgets/cards/location_card.dart';
// import 'package:waypoint_alert_app/widgets/cards/next_waypoint_card.dart';
import 'package:waypoint_alert_app/widgets/cards/upcoming_waypoints_list.dart';

import 'package:waypoint_alert_app/utils/calculators.dart' as calc;
import 'package:waypoint_alert_app/widgets/cards/waypoint_display_card.dart';
import 'package:waypoint_alert_app/widgets/drawers/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  final SettingsService settingsService;
  final WaypointService waypointService;
  final LocationService locationService;

  const HomeScreen({
    super.key,
    required this.settingsService,
    required this.waypointService,
    required this.locationService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMonitoring = false;
  WaterInfo? _waterInfo;
  String? _activeSetName;
  int? _activeSetCount;
  List<UpcomingWaypoint> _upcomingWaypoints = [];
  UpcomingWaypoint? _nextWaypoint;
  double? _currentLat;
  double? _currentLon;
  DateTime? _lastLocationUpdate;
  double? _cachedLat;
  double? _cachedLon;
  DateTime? _cachedTimeStamp;
  bool _isGpsStale = false;
  StreamSubscription<LocationUpdate>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _locationSubscription = widget.locationService.locationStream.listen((update) {
      if (mounted) {
        setState(() {
          // if GPS got a fix, cache it
          if (update.hasValidFix && update.latitude != null && update.longitude != null) {
            _cachedLat = update.latitude;
            _cachedLon = update.longitude;
            _cachedTimeStamp = update.timestamp;
          }
          _currentLat = update.latitude ?? _cachedLat;
          _currentLon = update.longitude ?? _cachedLon;
          _lastLocationUpdate = _cachedTimeStamp;

          // Is this data stale?
          if (_cachedTimeStamp != null) {
            final age = DateTime.now().difference(_cachedTimeStamp!);
            _isGpsStale = age > Duration(minutes: 2);  // TODO: Use SettingsService
          } else {
            _isGpsStale = false;
          }
        });
        _loadData();
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final setId = widget.settingsService.getActiveSetId();
    if (setId == null) return;

    // Get current location from service
    final currentLat = _currentLat ?? 0.0;
    final currentLon = _currentLon ?? 0.0;
    
    // Load water info
    final waterInfo = await widget.waypointService.getWaterInfo(
      setId,
      currentLat,
      currentLon,
    );

    // Load upcoming waypoints
    final upcomingList = await widget.waypointService.getUpcomingWaypoints(
      setId,
      currentLat,
      currentLon,
    );
    final upcomingWaypoints = upcomingList.map((wp) {
      final distance = calc.calculateDistance(
        currentLat,
        currentLon,
        wp.latitude,
        wp.longitude,
      );
      final bearing = calc.calculateBearing(currentLat, currentLon, wp.latitude, wp.longitude);
      return UpcomingWaypoint(
        name: wp.name,
        distanceKm: distance / 1000,
        bearing: bearing,
        type: wp.type,
        notes: wp.notes,
        alertCount: wp.alerts.length,
      );
    }).toList();

    // Get next waypoint (if any)
    final nextWaypoint = (upcomingWaypoints.isNotEmpty) ? upcomingWaypoints[0] : null;

    // Get active set info
    final waypointSet = await widget.waypointService.repository.getSet(setId);
    final setName = waypointSet?.name ?? 'Unknown Set';
    final waypointCount = await widget.waypointService.repository
      .getWaypointsForSet(setId)
      .then((list) => list.length);

    setState(() {
      _waterInfo = waterInfo;
      _activeSetName = setName;
      _activeSetCount = waypointCount;
      _upcomingWaypoints = upcomingWaypoints;
      _nextWaypoint = nextWaypoint;
      _currentLat = currentLat;
      _currentLon = currentLon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
         onImportTap: _onImportTap,
         onSettingsTap: _onSettingsTap,
      ),
      appBar: AppBar(
        title: const Text('Waypoint Alert'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MonitoringBanner(
              isMonitoring: _isMonitoring,
              onToggle: _toggleMonitoring,
            ),
            if (_isMonitoring)
              LocationCard(
                latitude: _currentLat,
                longitude: _currentLon,
                lastUpdated: _lastLocationUpdate,
                isDataStale: _isGpsStale,
              ),
            if (_activeSetName != null)
              WaypointDisplayCard(
                setName: _activeSetName!,
                waypointCount: _activeSetCount ?? 0,
                onSetTap: () => SetOptionsBottomSheet.show(
                  context,
                  onManageSetsTap: _onManageSetsTap,
                ),
                nextWaypoint: _nextWaypoint,
                waterInfo: _waterInfo,
                upcomingWaypoints: _upcomingWaypoints,
              )
            else
              const EmptyStateCard(
                title: 'No Wapoint Set Loaded',
                subtitle: 'Import a waypoint set to get started',
                icon: Icons.folder_off,
              ),
          ],
        ),
      ),
    );
  }

  void _toggleMonitoring() async {
    final newState = !_isMonitoring;
    if (newState) {
      await widget.locationService.start();
    } else {
      await widget.locationService.stop();
    }
    setState(() {
      _isMonitoring = newState;
    });
  }

  void _onManageSetsTap() {
    // TODO: Navigate to set management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage sets coming soon!'))
    );
  }

  void _onImportTap() {
    // TODO: Navigate to import flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import Feature Coming Soon!'))
    );
  }

  void _onSettingsTap() {
    // TODO: Navigate to settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon!'))
    );
  }

}

