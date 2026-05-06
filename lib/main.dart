import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waypoint_alert_app/constants/app_constants.dart';
import 'package:waypoint_alert_app/mocks/mock_location_service.dart';
import 'package:waypoint_alert_app/services/isar_service.dart';
import 'package:waypoint_alert_app/services/location_service.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/services/waypoint_parser.dart';
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
  await _seedDatabaseIfEmpty(repository);
  
  runApp(WaypointAlertApp(
    isarService: isarService,
    settingsService: settingsService,
    waypointService: waypointService,
    locationService: locationService,
  ));


 
}

class WaypointAlertApp extends StatelessWidget {
  final IsarService isarService;
  final SettingsService settingsService;
  final WaypointService waypointService;
  final LocationService locationService;
  
  const WaypointAlertApp({
    super.key,
    required this.isarService,
    required this.settingsService,
    required this.waypointService,
    required this.locationService,
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
      );
    }
    return HomeScreen(
      settingsService: settingsService,
      waypointService: waypointService,
      locationService: locationService,
    );
  }
}


// TODO: REMOVE ALL CODE FROM HERE TO "END" LINE ONCE WE'RE NO LONGER TESTING
Future<void> _seedDatabaseIfEmpty(WaypointRepository repository) async {
  final existingSets = await repository.getAllSets();
  if (existingSets.isNotEmpty) return;  // Already seeded or has real data

  print('Database empty - seeding with sample data...');

  final jsonString = await rootBundle.loadString(
    'assets/data-samples/ct-segments-1-and-2.json',
  );
print('SEED: here 1...');
  // Decode once to get the Map
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
print('SEED: here 2...');

  // Parse waypoint set
  final waypointSet = WaypointParser.parseWaypointSetFromJson(json);
print('SEED: here 3...');

  if (waypointSet == null) {
    print ('Failed to parse waypoint set');
    return;
  }

  // Insert waypointSet into database
  final storedSet = await repository.createSet(name: waypointSet.name);
print('SEED: here 4...');

  // Parse waypoints (uses the setId from the set)
  final waypoints = WaypointParser.parseFromString(jsonString, storedSet.id);
print('SEED: here 5...');

  // Insert waypoints into database
  await repository.addWaypoints(waypoints);

  print('Seeded ${waypoints.length} waypoints');
  print('Waypoint Set: ${storedSet.name} (ID: ${storedSet.id}');
}

// TODO: ====== END ======
