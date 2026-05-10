import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/models/water_info.dart';
import 'package:waypoint_alert_app/services/location_service.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/services/waypoint_service.dart';
import 'package:waypoint_alert_app/widgets/banners/monitoring_banner.dart';
import 'package:waypoint_alert_app/widgets/cards/active_set_card.dart';
import 'package:waypoint_alert_app/widgets/cards/closest_water_card.dart';
import 'package:waypoint_alert_app/widgets/cards/next_waypoint_card.dart';
import 'package:waypoint_alert_app/widgets/cards/upcoming_waypoints_list.dart';

import 'package:waypoint_alert_app/utils/calculators.dart' as calc;

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final setId = widget.settingsService.getActiveSetId();
    if (setId == null) return;

    // Get current location from service
    final currentLat = widget.locationService.latitude;
    final currentLon = widget.locationService.longitude;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waypoint Alert'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _showHamburgerMenu(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MonitoringBanner(
              isMonitoring: _isMonitoring,
              onToggle: _toggleMonitoring,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_activeSetName != null)
                      ActiveSetCard(
                        setName: _activeSetName!,
                        waypointCount: _activeSetCount ?? 0,
                        onTap: () => _showHamburgerMenu(context),
                      )
                    else
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No active waypoint set'),
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (_nextWaypoint != null)
                      NextWaypointCard(
                        name: _nextWaypoint!.name,
                        type: _nextWaypoint!.type,
                        distanceKm: _nextWaypoint!.distanceKm,
                        bearing: _nextWaypoint!.bearing,
                        notes: _nextWaypoint!.notes,
                      )
                    else
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No next waypoint'),
                        ),
                      ),
                    const SizedBox(height: 2),
                    if (_waterInfo != null)
                      ClosestWaterCard(waterInfo: _waterInfo!)
                    else
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Loading water info...'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    UpcomingWaypointsList(
                      waypoints: _upcomingWaypoints,
                      maxDistanceKm: 10.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMonitoring() {
    setState(() {
      _isMonitoring = !_isMonitoring;
    });
  }

  void _showHamburgerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Manage Waypoint Sets'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to set management screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

