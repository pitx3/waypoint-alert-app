import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/widgets/banners/monitoring_banner.dart';
import 'package:waypoint_alert_app/widgets/cards/active_set_card.dart';
import 'package:waypoint_alert_app/widgets/cards/closest_water_card.dart';
import 'package:waypoint_alert_app/widgets/cards/next_waypoint_card.dart';
import 'package:waypoint_alert_app/widgets/cards/upcoming_waypoints_list.dart';

class HomeScreen extends StatefulWidget {
  final SettingsService settingsService;

	const HomeScreen({super.key, required this.settingsService});

	@override State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // TODO: Replace with actual state from database/service
  bool _isMonitoring = false;

  // Mock data for UI development
  final _mockWaypoints = [
    const UpcomingWaypoint(name: 'Water Source - Wet Creek', distanceKm: 2.1, type: 'water', alertCount: 3),
    const UpcomingWaypoint(name: 'Hope Pass Trailhead', distanceKm: 5.4, type: 'trailhead', alertCount: 2),
    const UpcomingWaypoint(name: 'Critical Junction', distanceKm: 6.4, type: 'junction', alertCount: 0),
  ];

  @override Widget build(BuildContext context) {
   	return Scaffold(
			appBar: AppBar(
				title: const Text('Waypoint Alert'),
				actions: [
					// Hamburger menu - top right
					IconButton(
						icon: const Icon(Icons.menu),
						onPressed: () {
							// TODO: Open menu
						},
					),
				],
			),
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
            // Monitoring Status Banner
						MonitoringBanner(isMonitoring: _isMonitoring, onToggle: _toggleMonitoring),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActiveSetCard(
                      setName: 'Colorado Trail 2026', 
                      waypointCount: 47,
                      onTap: () => _showHamburgerMenu(context),
                    ),
                    const SizedBox(height: 16),
                    NextWaypointCard(name: 'Next Waypoint!', distanceKm: 0.8, bearing: null),
                    const SizedBox(height: 16),
                    const ClosestWaterCard(
                      waterName: 'Clear Creek Crossing',
                      distanceKm: 2.1,
                      //bearing: 112,
                    ),
                    const SizedBox(height: 16),
                    UpcomingWaypointsList(
                      waypoints: _mockWaypoints, 
                      maxDistanceKm: 10.0
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
    setState(() { _isMonitoring = !_isMonitoring; });
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