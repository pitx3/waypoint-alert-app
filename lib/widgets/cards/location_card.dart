import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocationCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  final DateTime? lastUpdated;

  const LocationCard({
    super.key,
    required this.latitude,
    required this.longitude,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
              style: const TextStyle(
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
                color: Colors.grey[400],
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