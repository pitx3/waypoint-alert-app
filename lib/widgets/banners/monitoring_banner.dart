import 'package:flutter/material.dart';
import 'package:waypoint_alert_app/widgets/dialogs/monitorring_toggle_dialog.dart';

class MonitoringBanner extends StatelessWidget {
  final bool isMonitoring;
  final VoidCallback onToggle;

  const MonitoringBanner({
    super.key,
    required this.isMonitoring,
    required this.onToggle,  
  });

  @override
  Widget build(BuildContext context) {
    final color = isMonitoring ? Colors.green : Colors.red;
    final statusText = isMonitoring ? 'ALERTS ACTIVE' : 'MONITORING OFF';
    final actionText = isMonitoring ? 'STOP' : 'START';

    return GestureDetector(
      onTap: () async {
        final confirmed = await showMonitoringToggleDialog(context: context, isMonitoring: isMonitoring);
        if (confirmed != null) {onToggle();}
      },
      child: Container(
        width: double.infinity,
        color: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMonitoring ? Icons.location_on : Icons.location_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$statusText - Tap to $actionText',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}