import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
	const HomeScreen({super.key});

	@override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	// TODO: Replace with actual settings check
	final bool isFirstRun = true;

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
						Text(
							isFirstRun ? 'First Run' : 'Not First Run',
							style: Theme.of(context).textTheme.headlineMedium,
						),
						const SizedBox(height: 16),
						Text (
							isFirstRun
								? 'Settings verification needed'
								: 'Waypoints loaded and ready',
							style: Theme.of(context).textTheme.bodyLarge,
						),
					],
				),
			),
		);
	}
}