import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: WaypointAlertApp(),
    ),
  );
}

class WaypointAlertApp extends StatelessWidget {
  const WaypointAlertApp({super.key});

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

      home: const HomeScreen(),
    );
  }
}