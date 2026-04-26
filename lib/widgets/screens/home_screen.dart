import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/constants/app_constants.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';

class HomeScreen extends StatefulWidget {
  final SettingsService settingsService;

	const HomeScreen({super.key, required this.settingsService});

	@override State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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
						Text (
							'Waypoints loaded and ready',
							style: Theme.of(context).textTheme.bodyLarge,
						),
            // if (AppConstants.debugResetFirstRun) {
            //   ElevatedButton(
            //     onPressed: () {},
            //     child: const Text('[DEBUG] Reset First Run'),
            //   ),
            // },

					],
				),
			),
		);
	}
}