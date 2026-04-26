import 'package:flutter/material.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/widgets/first_run_settings_screen.dart';

import 'widgets/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsService = await SettingsService.create();
  runApp(WaypointAlertApp(settingsService: settingsService));
}

class WaypointAlertApp extends StatelessWidget {
  final SettingsService settingsService;

  const WaypointAlertApp({super.key, required this.settingsService});

  @override Widget build (BuildContext context) {
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

      home: _buildHome(settingsService),
    );
  }

  Widget _buildHome(SettingsService settingsService) {
    if (settingsService.isFirstRun) {
      return FirstRunSettingsScreen(settingsService: settingsService);
    }
    return HomeScreen(settingsService: settingsService);
  }
}