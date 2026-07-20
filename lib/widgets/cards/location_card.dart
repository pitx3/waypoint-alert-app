import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waypoint_alert_app/widgets/cards/empty_state_card.dart';

class LocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final DateTime? lastUpdated;
  final bool isDataStale;

  const LocationCard({
    super.key,
    required this.latitude,
    required this.longitude,
    this.lastUpdated,
    this.isDataStale = false,
  });

  @override
  Widget build(BuildContext context) {
    if (latitude == null || longitude == null) {
      return EmptyStateCard(title: "Waiting for GPS...", subtitle: '');
    }
    return Card(
      color: isDataStale ? Colors.orange[400] : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${latitude?.toStringAsFixed(5)}, ${longitude?.toStringAsFixed(5)}',
              style: TextStyle(
                color: isDataStale ? Colors.black : null,
                fontSize: 16,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Updated: ${_formatTimestamp(lastUpdated)}',
              style: TextStyle(
                fontSize: 12,
                color: isDataStale ? Colors.black : Colors.grey[400],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '--:--:--';
    return DateFormat('HH:mm:ss').format(timestamp);
  }
}