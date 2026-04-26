import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/models/app_settings.dart';
import 'package:waypoint_alert_app/services/settings_service.dart';
import 'package:waypoint_alert_app/widgets/cards/setting_card.dart';
import 'package:waypoint_alert_app/constants/app_constants.dart';
import 'package:waypoint_alert_app/widgets/dialogs/setting_edit_dialogs.dart';
import 'package:waypoint_alert_app/widgets/screens/home_screen.dart';

class FirstRunSettingsScreen extends StatefulWidget {
  final SettingsService settingsService;

  const FirstRunSettingsScreen({super.key, required this.settingsService});

  @override State<FirstRunSettingsScreen> createState() => _FirstRunSettingScreenState();
}

class _FirstRunSettingScreenState extends State<FirstRunSettingsScreen> {

  // Default values
  int? _checkIntervalSeconds;
  int? _walkingSpeedMetersPerMinute;
  int? _defaultAlertDistanceMeters;

  @override Widget build(BuildContext context) {
    AppSettings appSettings = widget.settingsService.getSettings();

    _checkIntervalSeconds = appSettings.gpsPingInterval;
    _walkingSpeedMetersPerMinute = appSettings.walkingSpeedMpm;
    _defaultAlertDistanceMeters = appSettings.defaultAlertDistanceM;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Review'),
        automaticallyImplyLeading: false,
      ),
      body: 
        SingleChildScrollView(child:
        Padding (
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
                key: Key(AppConstants.keyGpsPingInterval),
                title: 'GPS Check Interval (seconds)',
                value: '$_checkIntervalSeconds',
                subtitle: 'How often to check your location',
                onEdit: () => _editCheckInterval(context),
              ),

              const SizedBox(height: 16),

              // Walking Speed
              SettingCard(
                key: Key(AppConstants.keyWalkingSpeedMpm),
                title: 'Walking Speed (m/min)', 
                value: '$_walkingSpeedMetersPerMinute', 
                subtitle: 'Average walking speed. Used for dynamic check intervals', 
                onEdit: () => _editWalkingSpeed(context)
              ),

              const SizedBox(height: 16),

              // Alert Distance
              SettingCard(
                key: Key(AppConstants.keyDefaultAlertDistanceM),
                title: 'Default Alert Distance (meters)', 
                value: '$_defaultAlertDistanceMeters', 
                subtitle: 'Distance at which to trigger alerts', 
                onEdit: () => _editAlertDistance(context),
              ),

              const SizedBox(height: 16),
  
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
      ),
    );
  }

  void _editCheckInterval(BuildContext context) async {
    final newValue = await showIntSettingDialog(
      context: context, 
      title: 'GPS Check Interval', 
      currentValue: _checkIntervalSeconds ?? AppConstants.defaultGpsPingInterval, 
      minValue: AppConstants.minGpsPingInterval, 
      maxValue: AppConstants.maxGpsPingInterval, 
      suffix: 'seconds',
    );

    if (newValue != null && newValue != _checkIntervalSeconds) {
      setState(() => _checkIntervalSeconds = newValue);
      await widget.settingsService.setGpsPingInterval(newValue);
    }
  }

  void _editWalkingSpeed(BuildContext context) async {
 final newValue = await showIntSettingDialog(
      context: context, 
      title: 'Walking Speed', 
      currentValue: _walkingSpeedMetersPerMinute ?? AppConstants.defaultWalkingSpeedMpm, 
      minValue: AppConstants.minWalkingSpeedMpm, 
      maxValue: AppConstants.maxWalkingSpeedMpm, 
      suffix: 'm/min',
    );

    if (newValue != null && newValue != _walkingSpeedMetersPerMinute) {
      setState(() => _walkingSpeedMetersPerMinute = newValue);
      await widget.settingsService.setWalkingSpeedMpm(newValue);
    }  }

  void _editAlertDistance(BuildContext context) async {
 final newValue = await showIntSettingDialog(
      context: context, 
      title: 'Default Alert Distance', 
      currentValue: _defaultAlertDistanceMeters ?? AppConstants.defaultAlertDistanceM, 
      minValue: AppConstants.minAlertDistanceM, 
      maxValue: AppConstants.maxAlertDistanceM, 
      suffix: 'meters',
    );

    if (newValue != null && newValue != _defaultAlertDistanceMeters) {
      setState(() => _defaultAlertDistanceMeters = newValue);
      await widget.settingsService.setDefaultAlertDistanceM(newValue);
    }  }

  void _onContinue(BuildContext context) async {
    await widget.settingsService.setFirstRunComplete();
    // Navigate to HomeScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(settingsService: widget.settingsService)
      ),
    );
  }
}