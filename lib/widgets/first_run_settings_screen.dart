import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/widgets/cards/setting_card.dart';

class FirstRunSettingsScreen extends StatefulWidget {
  const FirstRunSettingsScreen({super.key});

  @override State<FirstRunSettingsScreen> createState() => _FirstRunSettingScreenState();
}

class _FirstRunSettingScreenState extends State<FirstRunSettingsScreen> {
  // Default values
  // TODO: pull from settings service (later)
  int _checkIntervalSeconds = 60;
  int _walkingSpeedMetersPerMinute = 150;
  int _defaultAlertDistanceMeters = 300;

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Review'),
        automaticallyImplyLeading: false,
      ),
      body: Padding (
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to Waypoint Alert',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please review default settings',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Check Interval
            SettingCard (
              title: 'GPS Check Interval (seconds)',
              value: '$_checkIntervalSeconds',
              subtitle: 'How often to check your location',
              onEdit: () => _editCheckInterval(context),
            ),

            const SizedBox(height: 16),

            // Walking Speed
            SettingCard(
              title: 'Walking Speed (m/min)', 
              value: '$_walkingSpeedMetersPerMinute', 
              subtitle: 'Average walking speed. Used for dynamic check intervals', 
              onEdit: () => _editWalkingSpeed(context)
            ),

            const SizedBox(height: 16),

            // Alert Distance
            SettingCard(
              title: 'Default Alert Distance (meters)', 
              value: '$_defaultAlertDistanceMeters', 
              subtitle: 'Distance at which to trigger alerts', 
              onEdit: () => _editAlertDistance(context),
            ),

            const Spacer(),

            // Continue Button
            ElevatedButton(
              onPressed: ()=> _onContinue(context), 
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16),
              ),
            ),

          ],
        ),
      ),
    );
  }

  void _editCheckInterval(BuildContext context) {
    // TODO: Show dialog to edit value
  }

  void _editWalkingSpeed(BuildContext context) {
    // TODO: Show dialog to edit value
  }

  void _editAlertDistance(BuildContext context) {
    // TODO: Show dialog to edit value
  }

  void _onContinue(BuildContext context) {
    // TODO: Show dialog to edit value
  }
}