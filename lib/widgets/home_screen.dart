import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/widgets/first_run_settings_screen.dart';

class HomeScreen extends StatefulWidget {
	const HomeScreen({super.key});

	@override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	// TODO: Replace with actual settings check
	final bool isFirstRun = true;

  @override Widget build(BuildContext context) {
    if (isFirstRun) {
      return const FirstRunSettingsScreen();
    }

    return _buildMainDashboard(context);
  }

	Widget _buildMainDashboard(BuildContext context) {
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
						Text(
							'Not First Run',
							style: Theme.of(context).textTheme.headlineMedium,
						),
						const SizedBox(height: 16),
						Text (
							'Waypoints loaded and ready',
							style: Theme.of(context).textTheme.bodyLarge,
						),
					],
				),
			),
		);
	}
}