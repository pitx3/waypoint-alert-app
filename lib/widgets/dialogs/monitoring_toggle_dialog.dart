import 'package:flutter/material.dart';

Future<bool?> showMonitoringToggleDialog({
  required BuildContext context,
  required bool isMonitoring,
}) async {
  final willStart = !isMonitoring;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(willStart ? 'Start Monitoring?' : 'Stop Monitoring?'),
      content: Text(
        willStart
        ? 'This will continuously track your GPS location and trigger alerts when approaching waypoints. Battery usage will increase.'
        : 'You will no longer receive waypoint alerts. Your GPS will not be actively monitored.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, !isMonitoring),
          child: Text(willStart ? 'Start' : 'Stop'),
        ),
      ],
    ),
  );

  return result;
}