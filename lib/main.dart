
import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/constants/app_constants.dart';
import 'package:waypoint_alert_app/mocks/mock_location_service.dart';
import 'package:waypoint_alert_app/services/isar_service.dart';
import 'package:waypoint_alert_app/services/location_service.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/services/waypoint_repository.dart';
import 'package:waypoint_alert_app/services/waypoint_service.dart';
import 'package:waypoint_alert_app/widgets/screens/first_run_settings_screen.dart';
import 'package:waypoint_alert_app/widgets/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final isarService = IsarService();
  await isarService.init();
  
  final settingsService = await SettingsService.create();
  final repository = WaypointRepository(isarService: isarService, settingsService: settingsService);
  final waypointService = WaypointService(
    repository: repository,
    settingsService: settingsService,
  );
  // TODO: Switch this for a real location service for production use
  final locationService = MockLocationService();

  // TODO: Remove this once we're no longer testing
  //Future.microtask(() => _seedDatabaseIfEmpty(repository));
  
  runApp(WaypointAlertApp(
    isarService: isarService,
    settingsService: settingsService,
    waypointService: waypointService,
    locationService: locationService,
    repository: repository,
  ));


 
}

class WaypointAlertApp extends StatelessWidget {
  final IsarService isarService;
  final SettingsService settingsService;
  final WaypointService waypointService;
  final LocationService locationService;
  final WaypointRepository repository;
  
  const WaypointAlertApp({
    super.key,
    required this.isarService,
    required this.settingsService,
    required this.waypointService,
    required this.locationService,
    required this.repository,
  });
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waypoint Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.teal,
          secondary: Colors.blue,
          surface: const Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      ),
      home: _buildHome(),
    );
  }
  
  Widget _buildHome() {
    if (settingsService.isFirstRun || AppConstants.debugResetFirstRun) {
      return FirstRunSettingsScreen(
        settingsService: settingsService,
        waypointService: waypointService,
        locationService: locationService,
        repository: repository,
      );
    }
    return HomeScreen(
      settingsService: settingsService,
      waypointService: waypointService,
      locationService: locationService,
    );
  }
}


